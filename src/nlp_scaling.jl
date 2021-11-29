
abstract type AbstractScaling end

struct MaxScaler{VT, MT} <: AbstractScaling
    g::VT
    jac::MT
    max_gradient::Float64
end

function _set_con_scale!(con_scale::AbstractVector, jac::SparseMatrixCOO, nlp_scaling_max_gradient)
    @simd for i in 1:nnz(jac)
        row = @inbounds jac.I[i]
        @inbounds con_scale[row] = max(con_scale[row], abs(jac.V[i]))
    end
    con_scale .= min.(1.0, nlp_scaling_max_gradient ./ con_scale)
end
function _set_con_scale!(con_scale::AbstractVector, jac::Matrix, nlp_scaling_max_gradient)
    for row in 1:size(jac, 1)
        for col in 1:size(jac, 2)
            @inbounds con_scale[row] = max(con_scale[row], abs(jac[row, col]))
        end
    end
    con_scale .= min.(1.0, nlp_scaling_max_gradient ./ con_scale)
end

function set_constraints_scaling!(con_scale::AbstractVector, nlp::AbstractNLPModel, scaler::MaxScaler)
    _set_con_scale!(con_scale, scaler.jac, scaler.max_gradient)
end

function get_objective_scaling(nlp::AbstractNLPModel, scaler::MaxScaler)
    return min(1, scaler.max_gradient / norm(scaler.g, Inf))
end
