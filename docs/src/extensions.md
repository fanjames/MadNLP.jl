# Interfaces

## Linear Solvers
MadNLP is interfaced with non-Julia sparse/dense linear solvers:
- [Umfpack](https://people.engr.tamu.edu/davis/suitesparse.html)
- [MKL-Pardiso](https://software.intel.com/content/www/us/en/develop/documentation/mkl-developer-reference-fortran/top/sparse-solver-routines/intel-mkl-pardiso-parallel-direct-sparse-solver-interface.html)
- [MKL-Lapack](https://software.intel.com/content/www/us/en/develop/documentation/mkl-developer-reference-fortran/top/lapack-routines.html)
- [HSL solvers](http://www.hsl.rl.ac.uk/ipopt/) (requires extension)
- [Pardiso](https://www.pardiso-project.org/) (requires extension)
- [Mumps](http://mumps.enseeiht.fr/)  (requires extension)
- [cuSOLVER](https://docs.nvidia.com/cuda/cusolver/index.html) (requires extension)

Each linear solver in MadNLP is a julia module, and the `linear_solver` option should be specified by the actual module. Note that the linear solver modules are always exported to `Main`.

### Built-in Solvers: Umfpack, PardisoMKL, LapackCPU
```julia
using MadNLP, JuMP
# ...
model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPUmfpack)) # default
model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPPardisoMKL))
model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPLapackCPU))
```

### HSL (requires extension `MadNLPHSL`)
```julia
using MadNLP, MadNLPHSL, JuMP
# ...
model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPMa27))
model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPMa57))
model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPMa77))
model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPMa86))
model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPMa97))
```

### Mumps (requires extension `MadNLPMumps`)
```julia
using MadNLP, MadNLPMumps, JuMP
# ...
model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPMumps))
```

### Pardiso (requires extension `MadNLPPardiso`)
```julia
using MadNLP, MadNLPPardiso, JuMP
# ...
model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPPardiso))
```

### LapackGPU (requires extension `MadNLPGPU`)
```julia
using MadNLP, MadNLPGPU, JuMP
# ...
model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPLapackGPU))
```


### Schur and Schwarz (requires extension `MadNLPGraph`)
```julia
using MadNLP, MadNLPGraph, JuMP
# ...
model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPSchwarz))
model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPSchur))
```
The solvers in `MadNLPGraph` (`Schur` and `Schwawrz`) use multi-thread parallelism; thus, julia session should be started with `-t` flag.
```sh
julia -t 16 # to use 16 threads
```
