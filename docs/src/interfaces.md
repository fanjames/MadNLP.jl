# Interfaces

MadNLP is interfaced with modeling packages: 
- [JuMP](https://github.com/jump-dev/JuMP.jl)
- [Plasmo](https://github.com/zavalab/Plasmo.jl)
- [NLPModels](https://github.com/JuliaSmoothOptimizers/NLPModels.jl).
Users can pass various options to MadNLP also through the modeling packages. The interface-specific syntaxes are shown below. To see the list of MadNLP solver options, check [options](options.html).

## JuMP interface
```julia
using MadNLP, JuMP

model = Model(()->MadNLP.Optimizer(print_level=MadNLP.INFO,max_iter=100))
@variable(model, x, start = 0.0)
@variable(model, y, start = 0.0)
@NLobjective(model, Min, (1 - x)^2 + 100 * (y - x^2)^2)

optimize!(model)

```

## NLPModels interface
```julia
using MadNLP, CUTEst
model = CUTEstModel("PRIMALC1")
madnlp(model,print_level=MadNLP.WARN,max_wall_time=3600)
```

## Plasmo interface (requires extension `MadNLPGraph`)
```julia
using MadNLP, MadNLPGraph, Plasmo

graph = OptiGraph()
@optinode(graph,n1)
@optinode(graph,n2)
@variable(n1,0 <= x <= 2)
@variable(n1,0 <= y <= 3)
@constraint(n1,x+y <= 4)
@objective(n1,Min,x)
@variable(n2,x)
@NLnodeconstraint(n2,exp(x) >= 2)
@linkconstraint(graph,n1[:x] == n2[:x])

MadNLP.optimize!(graph;print_level=MadNLP.DEBUG,max_iter=100)

```
