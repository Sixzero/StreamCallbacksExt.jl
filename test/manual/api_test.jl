using Test
using StreamCallbacks
using StreamCallbacksExt
using PromptingTools
const PT = PromptingTools

"""
Manual tests for API functionality. These tests cost money and should be run manually.
To run: include("test/manual/api_test.jl")
"""

@testset "Manual API Tests" begin
    @testset "OpenAI GPT-4 Stop Sequence" begin
        buf = IOBuffer()
        cb = StreamCallbackWithHooks(
            out = buf,
            flavor = StreamCallbacks.OpenAIStream(),
            on_stop_sequence = seq -> println(buf, "\nStop sequence detected: ", seq)
        )

        msg = aigenerate("Count from 1 to 10";
            model="gpt4om",
            streamcallback=cb,
            api_kwargs=(stream=true, stop=["5"],)
        )
        output = String(take!(buf))
        @test occursin("Stop sequence detected: stop", output)
        @test !occursin("6", output)
    end

    @testset "Anthropic Claude Stop Sequence" begin
        buf = IOBuffer()
        cb = StreamCallbackWithHooks(
            out = buf,
            flavor = StreamCallbacks.AnthropicStream(),
            on_stop_sequence = seq -> println(buf, "\nStop sequence detected: ", seq)
        )

        msg = aigenerate("Count from 1 to 10";
            model="claudeh",
            streamcallback=cb,
            api_kwargs=(stream=true, stop_sequences=["5"])
        )
        output = String(take!(buf))
        @test occursin("Stop sequence detected: 5", output)
        @test !occursin("6", output)
    end
end
