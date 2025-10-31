using MAGE_PYCMA
using Test
using PythonCall

@testset "MAGE_PYCMA.jl" begin
    include("pycma_loading.jl")
    include("api.jl")
end
