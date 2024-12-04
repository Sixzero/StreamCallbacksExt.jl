
@testset "Callback Integration" begin
    # Test full callback functionality with a mock stream
    buf = IOBuffer()
    cb = StreamCallbackWithTokencounts(
        out=buf,
        flavor=StreamCallbacks.OpenAIStream()
    )
    
    # Simulate a stream of chunks
    chunks = [
        StreamChunk(  # Start message
            json = JSON3.read(JSON3.write(Dict(
                :type => "message_start",
                :model => "gpt-4"
            )))
        ),
        StreamChunk(  # Content in OpenAI format
            json = JSON3.read(JSON3.write(Dict(
                :choices => [
                    Dict(:delta => Dict(:content => "Hello"))
                ]
            )))
        ),
        StreamChunk(  # Usage info
            json = JSON3.read(JSON3.write(Dict(
                :usage => Dict(
                    :prompt_tokens => 10,
                    :completion_tokens => 5
                )
            )))
        )
    ]

    for chunk in chunks
        StreamCallbacks.callback(cb, chunk)
    end

    output = String(take!(buf))
    @test !isempty(output)
    @test contains(output, "Hello")
    @test cb.model == "gpt-4"
    @test cb.total_tokens.input + cb.total_tokens.output > 0
end
