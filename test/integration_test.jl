@testset "Stop Sequences" begin
    # Test OpenAI stop sequences
    buf = IOBuffer()
    cb = StreamCallbackWithTokencounts(
        out=buf,
        flavor=StreamCallbacks.OpenAIStream()
    )

    # Test chunk with stop sequence
    chunk = StreamChunk(
        json = JSON3.read(JSON3.write(Dict(
            :choices => [Dict(
                :delta => Dict(
                    :content => "Hello",
                    :finish_reason => "stop"
                )
            )],
            :usage => Dict(
                :prompt_tokens => 10,
                :completion_tokens => 5
            )
        )))
    )

    StreamCallbacks.callback(cb, chunk)
    output = String(take!(buf))
    @test !isempty(output)
    @test contains(output, "Hello")
    @test cb.total_tokens.input + cb.total_tokens.output > 0
end
