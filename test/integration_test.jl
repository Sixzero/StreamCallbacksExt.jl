@testset "Callback Integration" begin
    # Test full callback functionality with a mock stream
    buf = IOBuffer()
    cb = TokenStreamCallback(
        out=buf,
        flavor=StreamCallbacks.OpenAIStream()
    )
    
    # Simulate a stream of chunks
    chunks = [
        StreamChunk(  # Start message
            json = Dict(
                :type => "message_start",
                :model => "gpt-4"
            )
        ),
        StreamChunk(  # Content
            json = Dict(:content => "Hello")
        ),
        StreamChunk(  # Usage info
            json = Dict(
                :usage => Dict(
                    :prompt_tokens => 10,
                    :completion_tokens => 5
                )
            )
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
