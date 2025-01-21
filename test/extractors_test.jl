using Test
using StreamCallbacks
using StreamCallbacksExt
using StreamCallbacksExt: extract_reasoning
using JSON3
include("test_utils.jl")

@testset "OpenAI End-of-Stream Token Stats" begin
    # Test GPT-4o end-of-stream format
    chunk = create_json_streamchunk(json = Dict(
        :usage => Dict(
            :prompt_tokens => 34,
            :completion_tokens => 20,
            :total_tokens => 54,
            :prompt_tokens_details => Dict(
                :cached_tokens => 5,
                :audio_tokens => 2
            ),
            :completion_tokens_details => Dict(
                :reasoning_tokens => 0,
                :audio_tokens => 0,
                :accepted_prediction_tokens => 0,
                :rejected_prediction_tokens => 0
            )
        )
    ))
    tokens = extract_tokens(StreamCallbacks.OpenAIStream(), chunk)
    @test tokens.input == 27  # 34 - 5 - 2 (total - cached - audio)
    @test tokens.output == 20
    @test tokens.cache_read == 5
    @test tokens.cache_write == 0
end

@testset "OpenAI Reasoning Content" begin
    chunk = create_json_streamchunk(json = Dict(
        :choices => [
            Dict(
                :delta => Dict(
                    :content => nothing,
                    :reasoning_content => " to"
                )
            )
        ]
    ))
    reasoning = extract_reasoning(StreamCallbacks.OpenAIStream(), chunk)
    @test reasoning == " to"
end
