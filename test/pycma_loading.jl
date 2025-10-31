@testset "pycma loading" begin
    cma = get_cma()
    @test cma !== nothing
    # @test hasproperty(cma, "CMAEvolutionStrategy")
end
