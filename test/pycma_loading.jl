@testset "pycma loading" begin
    # Attempt to import pycma using PythonCall's pyimport
    cma = get_cma()
    @test cma !== nothing
    @test hasproperty(cma, "CMAEvolutionStrategy")
end
