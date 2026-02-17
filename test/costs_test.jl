@testset "Cost Calculation" begin
    tokens = TokenCounts(input=100, output=50, cache_write=20, cache_read=30)
    
    @testset "OpenAI Costs" begin
        cost = get_cost(StreamCallbacks.OpenAIStream(), "gpt-4", tokens)
        # Note: actual cost values depend on PromptingTools.MODEL_REGISTRY
        @test cost isa Float64
        @test cost >= 0.0
    end

    @testset "Anthropic Costs" begin
        cost = get_cost(StreamCallbacks.AnthropicStream(), "claude-3", tokens)
        @test cost isa Float64
        @test cost >= 0.0
    end

    @testset "Warn on unknown model" begin
        @test_logs (:warn, r"No cost information found .* unknown-model") begin
            cost = get_cost(StreamCallbacks.OpenAIStream(), "unknown-model", tokens)
            @test cost == 0.0
        end
    end
end
