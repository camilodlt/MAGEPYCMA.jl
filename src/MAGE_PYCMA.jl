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

# EXPORTS
export get_cma
end
