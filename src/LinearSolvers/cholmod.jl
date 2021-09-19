# MadNLP.jl
# Created by Sungho Shin (sungho.shin@wisc.edu)

module MadNLPCholmod

import ..MadNLP:
    @kwdef, Logger, @debug, @warn, @error,
    SubVector, StrideOneVector, SparseMatrixCSC, get_tril_to_full,
    SymbolicException,FactorizationException,SolveException,InertiaException,
    AbstractOptions, AbstractLinearSolver, set_options!, CHOLMOD,
    introduce, factorize!, solve!, mul!, improve!, is_inertia, inertia

const INPUT_MATRIX_TYPE = :csc

const cholmod_default_ctrl = copy(CHOLMOD.umf_ctrl)
const cholmod_default_info = copy(CHOLMOD.umf_info)

@kwdef mutable struct Options <: AbstractOptions
    cholmod_pivtol::Float64 = 1e-4
    cholmod_pivtolmax::Float64 = 1e-1
    cholmod_sym_pivtol::Float64 = 1e-3
    cholmod_block_size::Float64 = 16
    cholmod_strategy::Float64 = 2.
end

mutable struct Solver <: AbstractLinearSolver
    inner::CHOLMOD.CholmodLU
    tril::SparseMatrixCSC{Float64}
    full::SparseMatrixCSC{Float64}
    tril_to_full_view::SubVector{Float64}

    p::Vector{Float64}

    tmp::Vector{Ptr{Cvoid}}
    ctrl::Vector{Float64}
    info::Vector{Float64}

    opt::Options
    logger::Logger
end

cholmod_di_numeric(colptr::StrideOneVector{Int32},rowval::StrideOneVector{Int32},
                   nzval::StrideOneVector{Float64},symbolic::Ptr{Nothing},
                   tmp::Vector{Ptr{Nothing}},ctrl::Vector{Float64},
                   info::Vector{Float64}) = ccall(
                       (:cholmod_di_numeric,:libcholmod),
                       Int32,
                       (Ptr{Int32},Ptr{Int32},Ptr{Float64},Ptr{Cvoid},Ptr{Cvoid},
                        Ptr{Float64},Ptr{Float64}),
                       colptr,rowval,nzval,symbolic,tmp,ctrl,info)
cholmod_di_solve(typ,colptr,rowval,nzval,x,b,numeric,ctrl,info) = ccall(
    (:cholmod_di_solve,:libcholmod),
    Int32,
    (Int32, Ptr{Int32}, Ptr{Int32}, Ptr{Float64},Ptr{Float64},
     Ptr{Float64}, Ptr{Cvoid}, Ptr{Float64},Ptr{Float64}),
    typ,colptr,rowval,nzval,x,b,numeric,ctrl,info)



function Solver(csc::SparseMatrixCSC;
                option_dict::Dict{Symbol,Any}=Dict{Symbol,Any}(),
                opt=Options(),logger=Logger(),
                kwargs...)

    set_options!(opt,option_dict,kwargs)

    p = Vector{Float64}(undef,csc.n)
    full,tril_to_full_view = get_tril_to_full(csc)

    full.colptr.-=1; full.rowval.-=1

    inner = CHOLMOD.CholmodLU(C_NULL,C_NULL,full.n,full.n,full.colptr,full.rowval,full.nzval,0)
    CHOLMOD.finalizer(CHOLMOD.cholmod_free_symbolic,inner)
    CHOLMOD.cholmod_symbolic!(inner)
    ctrl = copy(cholmod_default_ctrl)
    info = copy(cholmod_default_info)
    ctrl[4]=opt.cholmod_pivtol
    ctrl[12]=opt.cholmod_sym_pivtol
    ctrl[5]=opt.cholmod_block_size
    ctrl[6]=opt.cholmod_strategy
    
    tmp = Vector{Ptr{Cvoid}}(undef, 1)

    return Solver(inner,csc,full,tril_to_full_view,p,tmp,ctrl,info,opt,logger)
end

function factorize!(M::Solver)
    CHOLMOD.cholmod_free_numeric(M.inner)
    M.full.nzval.=M.tril_to_full_view
    status = cholmod_di_numeric(M.inner.colptr,M.inner.rowval,M.inner.nzval,M.inner.symbolic,M.tmp,M.ctrl,M.info)
    M.inner.numeric = M.tmp[]

    M.inner.status = status
    return M
end
function solve!(M::Solver,rhs::StrideOneVector{Float64})
    status = cholmod_di_solve(1,M.inner.colptr,M.inner.rowval,M.inner.nzval,M.p,rhs,M.inner.numeric,M.ctrl,M.info)
    rhs .= M.p
    return rhs
end
is_inertia(::Solver) = false
inertia(M::Solver) = throw(InertiaException())

function improve!(M::Solver)
    if M.ctrl[4] == M.opt.cholmod_pivtolmax
        @debug(M.logger,"improve quality failed.")
        return false
    end
    M.ctrl[4] = min(M.opt.cholmod_pivtolmax,M.ctrl[4]^.75)
    @debug(M.logger,"improved quality: pivtol = $(M.ctrl[4])")
    return true

    return false
end
introduce(::Solver)="cholmod"

end # module
