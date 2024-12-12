using Test
using StreamCallbacks
using StreamCallbacksExt
using JSON3

@testset "StreamCallbackChannelWrapper" begin
    errors = String[]
    output = String[]

    inner_cb = StreamCallbackWithHooks(
        flavor = StreamCallbacks.OpenAIStream(),
        out = devnull,
        on_error = e -> push!(errors, "Error: $e"),
        content_formatter = text -> begin
            # Intentionally throw error on specific content
            text == "error" && error("Test error")
            push!(output, text)
        end
    )

    cb = StreamCallbackChannelWrapper(callback=inner_cb)

    # Test normal processing
    chunk1 = StreamChunk(
        json = JSON3.read("""{"choices":[{"delta":{"content":"test"}}]}""")
    )
    StreamCallbacks.callback(cb, chunk1)

    # Test error handling
    chunk2 = StreamChunk(
        json = JSON3.read("""{"choices":[{"delta":{"content":"error"}}]}""")
    )
    StreamCallbacks.callback(cb, chunk2)

    # End processing
    chunk3 = StreamChunk(
        json = JSON3.read("""{"type":"message_end"}""")
    )
    StreamCallbacks.callback(cb, chunk3)

    # Wait for processing to complete
    sleep(0.1)

    @test length(output) > 0
    @test output[1] == "test"
    @test !isempty(errors)
    @test contains(first(errors), "Test error")
    @test !isopen(cb.channel)
end
;