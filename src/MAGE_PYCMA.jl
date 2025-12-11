module MAGE_PYCMA
using PythonCall
using Logging

const cma::Ref{Py} = Ref{Py}()

"""
"""
function get_cma()
    if !isassigned(cma) || cma[] === nothing
        @info "Loading for the first time CMA"
        cma[] = pyimport("cma")
    end
    @info "CMA was already loaded"
    return cma[]
end

# UTILS --- ############
function get_cma_options()::Vector{String}
    cma = get_cma()
    options = @pyeval (cma = cma,) => "cma.options_parameters.CMAOptions.versatile_options()"
    return pyconvert(Vector{String}, options)
end

# CMA ES --- ############
abstract type AbstractCMAEvolutionStrategyWrapper end
struct CMAEvolutionStrategyWrapper
    wrapped::Py
end
function _create_cma_es(initial_values::AbstractArray{Float64, 1}, sigma::Float64, options::Dict, popsize::Int)
    @assert popsize > 1 "Population has to be > 1"
    cma = get_cma()
    py_options = cma.options_parameters.CMAOptions()
    for (k, v) in options
        py_options.set(k, v)
    end
    py_options.set("popsize", popsize)
    @info "Setting popsize to $popsize"
    return CMAEvolutionStrategyWrapper(cma.CMAEvolutionStrategy(initial_values, sigma, py_options))

end

"""

Default sigma is 0.2
"""
function create_cma_es(initial_values::AbstractArray{Float64, 1}; popsize::Int)
    return _create_cma_es(initial_values, 0.2, Dict(), popsize)
end
function create_cma_es(initial_values::AbstractArray{Float64, 1}, sigma::Float64; popsize::Int)
    return _create_cma_es(initial_values, sigma, Dict(), popsize)
end
function create_cma_es(initial_values::AbstractArray{Float64, 1}, sigma::Float64, options::Dict; popsize::Int)
    return _create_cma_es(initial_values, sigma, options, popsize)
end

# ASK --- ############

function ask(cma::CMAEvolutionStrategyWrapper)
    return pyconvert(Vector{Vector{Float64}}, cma.wrapped.ask())
end

# TELL --- ############

function tell(cma::CMAEvolutionStrategyWrapper, sampled::T, fitness::Z) where {Z <: AbstractVector{Float64}, T <: AbstractVector{<:Z}}
    n_pop = length(sampled)
    n_fit = length(fitness)
    @assert n_pop == get_popsize(cma) == n_fit "There has to be the same number of population, samples and fitness values. currently $(get_popsize(cma)), $(n_pop), $(n_fit)"
    return cma.wrapped.tell(sampled, fitness)
end

# UTILS
get_popsize(cma::CMAEvolutionStrategyWrapper) = pyconvert(Int, cma.wrapped.popsize)
is_stop(cma::CMAEvolutionStrategyWrapper) = @pyeval (es = cma.wrapped,) => "len(es.stop()) > 0" => Bool
disp(cma::CMAEvolutionStrategyWrapper) = cma.wrapped.disp()
log_add(cma::CMAEvolutionStrategyWrapper) = cma.wrapped.logger.add()
results_pretty(cma::CMAEvolutionStrategyWrapper) = cma.wrapped.result_pretty()
plot_cma(cma::CMAEvolutionStrategyWrapper) = cma.wrapped.plot()
function plot_and_save_cma(cma::CMAEvolutionStrategyWrapper, name::String = "cma.png")
    plot_cma(cma)
    return pyexec(
        """
        import matplotlib
        matplotlib.use('Agg')
        from matplotlib import pyplot as plt
        plt.ioff()
        plt.savefig(name)
        plt.close()
        """, Main, (name = name,)
    )
end

# EXPORTS
export get_cma, get_cma_options
export CMAEvolutionStrategyWrapper, create_cma_es
export ask, tell
export get_popsize, is_stop, disp, log_add, results_pretty, plot_cma, plot_and_save_cma

end
