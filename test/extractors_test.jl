
using JSON3
using StreamCallbacksExt: extract_tokens, extract_model

@testset "Token Extractors" begin
    @testset "OpenAI" begin
        # Test standard OpenAI format
        chunk = StreamChunk(
            json = JSON3.read(JSON3.write(Dict(
                :usage => Dict(
                    :prompt_tokens => 100,
                    :completion_tokens => 50,
                    :prompt_tokens_details => Dict(:cached_tokens => 20)
                )
            )))
        )
        tokens = extract_tokens(StreamCallbacks.OpenAIStream(), chunk)
        @test tokens.input == 80  # 100 - 20 cached
        @test tokens.output == 50
        @test tokens.cache_read == 20
        @test tokens.cache_write == 0

        # Test DeepSeek format
        chunk = StreamChunk(
            json = JSON3.read(JSON3.write(Dict(
                :usage => Dict(
                    :prompt_cache_hit_tokens => 30,
                    :prompt_cache_miss_tokens => 70,
                    :completion_tokens => 40
                )
            )))
        )
        tokens = extract_tokens(StreamCallbacks.OpenAIStream(), chunk)
        @test tokens.input == 70
        @test tokens.output == 40
        @test tokens.cache_read == 30
        @test tokens.cache_write == 0
    end

    @testset "Anthropic" begin
        # Test message_start
        chunk = StreamChunk(
            event = :message_start,
            data = "",
            json = JSON3.read(JSON3.write(Dict(
                :message => Dict(
                    :usage => Dict(
                        :input_tokens => 100,
                        :cache_creation_input_tokens => 10,
                        :cache_read_input_tokens => 20
                    )
                )
            )))
        )
        tokens = extract_tokens(StreamCallbacks.AnthropicStream(), chunk)
        @test tokens.input == 100
        @test tokens.output == 0
        @test tokens.cache_write == 10
        @test tokens.cache_read == 20

        # Test completion
        chunk = StreamChunk(
            event = nothing,
            data = "",
            json = JSON3.read(JSON3.write(Dict(
                :usage => Dict(
                    :output_tokens => 50
                )
            )))
        )
        tokens = extract_tokens(StreamCallbacks.AnthropicStream(), chunk)
        @test tokens.input == 0
        @test tokens.output == 50
        @test tokens.cache_write == 0
        @test tokens.cache_read == 0
    end
end

@testset "Model Extractors" begin
    @testset "OpenAI Model" begin
        chunk = StreamChunk(
            event = nothing,
            data = "",
            json = JSON3.read(JSON3.write(Dict(:model => "gpt-4")))
        )
        model = extract_model(StreamCallbacks.OpenAIStream(), chunk)
        @test model == "gpt-4"
    end

    @testset "Anthropic Model" begin
        chunk = StreamChunk(
            event = :message_start,
            data = "",
            json = JSON3.read(JSON3.write(Dict(
                :message => Dict(:model => "claude-3")
            )))
        )
        model = extract_model(StreamCallbacks.AnthropicStream(), chunk)
        @test model == "claude-3"
    end
end
