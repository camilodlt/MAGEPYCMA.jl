# Utils
@testset "CMA Options" begin
    @test begin
        options = get_cma_options()
        options isa Vector{String}
    end
end

# Create ES
@testset "CMA ES" begin
    @test begin
        es = create_cma_es([0.1, 0.1]; popsize = 100)
        es isa CMAEvolutionStrategyWrapper && es.wrapped isa Py &&
            get_popsize(es) == 100
    end

    @test begin
        es = create_cma_es([0.1, 0.1], 0.1; popsize = 20) # with step size
        es isa CMAEvolutionStrategyWrapper &&
            pyconvert(Float64, es.wrapped.sigma) == 0.1 &&
            get_popsize(es) == 20
    end

    @test begin
        es = create_cma_es([0.1, 0.1], 0.1, Dict("seed" => 1); popsize = 10) # with step size
        es isa CMAEvolutionStrategyWrapper &&
            pyconvert(Float64, es.wrapped.sigma) == 0.1 &&
            pyconvert(Int, es.wrapped.opts.get("seed")) == 1 &&
            get_popsize(es) == 10
    end
end

# ASK
@testset "Ask" begin
    @test begin
        es = create_cma_es([0.1, 0.1, 0.0]; popsize = 10)
        next_one = ask(es)
        length(next_one) == 10
    end
    @test begin
        es = create_cma_es([0.0]; popsize = 2)
        next_one = ask(es)
        length(next_one) == 2 && length(next_one[1]) == 1
    end
end

# TELL
@testset "Ask" begin
    @test begin
        es = create_cma_es([0.1, 0.1, 0.0]; popsize = 3)
        next_one = ask(es)
        tell(es, next_one, [1.0, 0.5, 0.0])
        pyconvert(Int, es.wrapped.countiter) == 1
    end
    @test begin
        es = create_cma_es([0.1, 0.0]; popsize = 3)
        next_one = ask(es)
        tell(es, [[0.0, 0.0], [1.0, 1.0], [1.0, 1.0]], [1.0, 0.5, 0.0])
        pyconvert(Int, es.wrapped.countiter) == 1
    end
    @test_throws AssertionError begin
        es = create_cma_es([0.1, 0.1, 0.0]; popsize = 3)
        next_one = ask(es)
        tell(es, next_one, [1.0, 0.5])
        pyconvert(Int, es.wrapped.countiter) == 1
    end
    @test_throws AssertionError begin
        es = create_cma_es([0.1, 0.0]; popsize = 3)
        next_one = ask(es)
        tell(es, [[0.0, 0.0]], [1.0, 0.5, 0.0])
        pyconvert(Int, es.wrapped.countiter) == 1
    end
end

# Integration Test
@testset "intergration" begin
    obj(x) = sum(x .^ 2)
    x0 = [1.0, -1.0, 1.0 - 1.0]
    @test begin
        es = create_cma_es(x0; popsize = 10)
        for i in 1:2000
            is_stop(es) ? break : nothing
            sampled = ask(es)
            f = obj.(sampled)
            tell(es, sampled, f)
            log_add(es)
            disp(es)
        end
        iths_cond = pyconvert(Int, es.wrapped.countiter) < 2000 # stoped before 2000
        results_pretty(es)
        plot_and_save_cma(es)
        iths_cond
    end
end
