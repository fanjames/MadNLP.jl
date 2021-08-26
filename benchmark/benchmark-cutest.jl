include("config.jl")

function get_status(code::Symbol)
    if code == :first_order
        return 1
    elseif code == :acceptable
        return 2
    else
        return 3
    end
end

@everywhere using CUTEst

if SOLVER == "master"
    @everywhere solver = nlp -> madnlp(nlp,linear_solver=MadNLPMa57,max_wall_time=900.,tol=1e-6, print_level=PRINT_LEVEL)
    @everywhere using MadNLP, MadNLPHSL
elseif SOLVER == "current"
    @everywhere solver = nlp -> madnlp(nlp,linear_solver=MadNLPMa57,max_wall_time=900.,tol=1e-6, print_level=PRINT_LEVEL)
    @everywhere using MadNLP, MadNLPHSL
elseif SOLVER == "ipopt"
    @everywhere solver = nlp -> ipopt(nlp,linear_solver="ma57",max_cpu_time=900.,tol=1e-6, print_level=PRINT_LEVEL)
    @everywhere using NLPModelsIpopt
elseif SOLVER == "knitro"
    # TODO
else
    error("Proper SOLVER should be given")
end


@everywhere function decodemodel(name)
    println("Decoding $name")
    finalize(CUTEstModel(name))
end

@everywhere function evalmodel(name,solver;gcoff=false)
    println("Solving $name")
    nlp = CUTEstModel(name; decode=false)
    try
        gcoff && GC.enable(false);
        mem = @allocated begin
            t = @elapsed begin
                retval = solver(nlp)
            end
        end
        gcoff && GC.enable(true);
        retval.elapsed_time = t
        retval.solver_specific[:mem] = mem
        finalize(nlp)
        return retval
    catch e
        finalize(nlp)
        throw(e)
    end
end

function benchmark(solver,probs;warm_up_probs = [])
    println("Warming up (forcing JIT compile)")
    broadcast(decodemodel,warm_up_probs)
    [remotecall_fetch.(prob->evalmodel(prob,solver;gcoff=GCOFF),i,warm_up_probs) for i in procs() if i!= 1]

    println("Decoding problems")
    broadcast(decodemodel,probs)

    println("Solving problems")
    retvals = pmap(prob->evalmodel(prob,solver),probs)
    time   = [retval.elapsed_time for retval in retvals]
    status = [get_status(retval.status) for retval in retvals]
    mem    = [retval.solver_specific[:mem] for retval in retvals]
    time,status,mem
end

exclude = [
    "PFIT1","PFIT2","PFIT4","DENSCHNE","SPECANNE","DJTL", "EG3","OET7",
    "PRIMAL3","TAX213322","TAXR213322","TAX53322","TAXR53322","HIMMELP2","MOSARQP2","LUKVLE11",
    "CYCLOOCT","CYCLOOCF","LIPPERT1","GAUSSELM","A2NSSSSL",
    "YATP1LS","YATP2LS","YATP1CLS","YATP2CLS","BA-L52LS","BA-L73LS","BA-L21LS","CRESC132"
]


if QUICK
    probs = ["PRIMALC1", "DIXMAANI", "HIER13", "LUKVLI7", "GAUSS2", "LUKSAN13LS", "CHARDIS1", "A5NSDSIL", "QPCBOEI1", "POLAK4", "DUAL2", "EXPFITA", "VAREIGVL", "MPC2", "BLOWEYA", "DECONVB", "MSS1", "POWELLBC", "ACOPP57", "WALL50", "FBRAIN2", "ACOPP300", "AUG2D", "HS106", "GMNCASE2", "LUKVLE8", "READING2", "MAXLIKA", "CHEBYQAD", "HYDROELM", "GULFNE", "CLEUVEN4", "HAIFAL", "JUDGENE", "DITTERT", "TRIGON1NE", "OBSTCLAE", "READING6", "SBRYBND", "ARGLINC", "CVXQP2", "TABLE8", "NINENEW", "STEENBRA", "BA-L1SP", "EXPFITNE", "LUKSAN17", "DUALC5", "STCQP1", "DEGENQP", "DEGDIAG", "LEUVEN7", "DALLASM", "READING8", "HS101", "GENROSEBNE", "EIGENALS", "READING7", "OET3", "CHANDHEQ", "YATP1LS", "OSCIPATH", "SEMICN2U", "MODBEALENE", "JANNSON4", "DTOC1NC", "KSS", "TABLE1", "DRCAV2LQ", "MGH17SLS", "BRAINPC2", "PROBPENL", "MGH17S", "DIAGPQB", "DEMBO7", "HS119", "PORTSNQP", "YATP1CNE", "THURBER", "VESUVIOU", "TAX213322", "NGONE", "MRIBASIS", "EXPFITC", "FBRAINNE", "LINVERSENE", "HYDCAR6LS", "GMNCASE4", "ZAMB2-11", "ALJAZZAF", "HIMMELBK", "WOODSNE", "LUKVLI10", "CHANNEL", "ORBIT2", "EIGENA2", "ACOPP118", "CHNRSNBM", "LHAIFAM", "NASH", "CYCLIC3LS", "CYCLIC3", "BA-L49LS", "HS99", "CATENA", "CHWIRUT1", "OPTPRLOC", "HYDROELL", "BIGBANK", "OSORIO", "SPINLS", "MNISTS0", "ANTWERP", "PORTFL4", "PDE1", "CURLY20", "DEGENLPA", "LUBRIFC", "MANCINONE", "DALE", "HATFLDC", "INTEGREQ", "NET1", "LUKSAN12", "UBH5", "AGG", "WATSONNE", "TAX13322", "PRIMAL1", "10FOLDTR", "QPCBLEND", "CYCLOOCT", "FIVE20B", "HUESTIS", "TWIRISM1", "DMN37142", "LIARWHDNE", "COOLHANS", "MSS3", "BDRY2", "TRO5X5", "MSS2", "TAX53322", "CORE1", "LINSPANH", "ZAMB2-9", "KSIP", "CHAINWOONE", "DEGTRIDL", "LINCONT", "TWIRIBG1", "POWER", "DMN37143", "PRIMAL3", "EIGENBCO", "TRIMLOSS", "SPANHYD", "OPTCNTRL", "ROSEPETAL", "SANTALS", "PRIMALC8", "SPECANNE", "READING5", "EXPQUAD", "ARGLCLE", "CHNRSBNE", "MODBEALE", "EIGENC", "ARGTRIG", "STATIC3", "CRESC132", "CHANDHEU", "KISSING2", "EXPLIN", "GILBERT", "GPP", "LUKVLI9", "RES", "LCH", "MUONSINE", "BA-L73", "TRO21X5", "SSEBNLN", "ELATTAR", "TWOD", "PRIMAL4", "COATING", "WALL100", "MSQRTA", "PRIMAL2", "ODNAMUR", "GENROSENE", "TRIGON2NE", "CHARDIS0", "SPMSQRT", "QING", "SMMPSF", "NUFFIELD", "GOFFIN", "ELEC", "BA-L16LS", "SYNPOP24", "ZIGZAG", "SSEBLIN", "BA-L1", "FCCU", "CONT5-QP", "QPNBAND", "AIRPORT", "FEEDLOC", "KISSING", "FERRISDC", "MAKELA4", "VANDANIUMS", "AVION2", "BROWNALE", "ROSEPETAL2", "DEGENQPC", "DRUGDISE", "QINGNE", "BA-L52LS", "JANNSON3", "NONMSQRTNE", "DECONVC", "BA-L52", "WALL10", "MODEL", "OPTMASS", "ORTHREGF"]
else
    probs = CUTEst.select()
end

filter!(e->!(e in exclude),probs)

time,status,mem = benchmark(solver,probs;warm_up_probs = ["EIGMINA"])

writedlm("name-cutest.csv",probs,',')
writedlm("time-cutest-$(SOLVER).csv",time,',')
writedlm("status-cutest-$(SOLVER).csv",status),','
writedlm("mem-cutest-$(SOLVER).csv",mem,',')
