```@raw html
<img class="display-light-only" src="assets/logo-full.svg" alt="MadNLP logo"/>
<img class="display-dark-only" src="assets/logo-full-dark.svg" alt="MadNLP logo"/>
```

!!! warning
    This documentation is under construction.	
	
MadNLP is a [nonlinear programming](https://en.wikipedia.org/wiki/Nonlinear_programming) (NLP) solver, purely implemented in [Julia](https://julialang.org/). MadNLP can solve NLPs that can be expressed in the following form:
```math
\begin{aligned}
\min_{x}\; &f(x)\\
\text{s.t.}\;
&x_L \leq x\leq x_U\\
&g_L \leq g(x) \leq g_U,
\end{aligned}
```
where ``x,x_L,x_U\in\mathbb{R}^{n}``, ``g_L,g_U\in\mathbb{R}^{m}``, and ``f:\mathbb{R}^{n}\rightarrow\mathbb{R}`` and ``g:\mathbb{R}^{n}\rightarrow\mathbb{R}^{m}`` are nonlinear, nonconvex.
MadNLP implements a filter line-search [interior point method](https://en.wikipedia.org/wiki/Interior-point_method), as that used in [Ipopt](https://github.com/coin-or/Ipopt). 
