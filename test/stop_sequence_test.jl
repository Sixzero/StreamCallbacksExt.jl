@testset "Stop Sequence handling" begin
    # Test OpenAI stop sequence with delta.stop_sequence
    chunk1 = create_json_streamchunk(json = Dict(
        :choices => [Dict(
            :delta => Dict(:stop_sequence => "STOP")
        )]
    ))
    @test extract_stop_sequence(StreamCallbacks.OpenAIStream(), chunk1) == "STOP"

    # Test OpenAI stop sequence with finish_reason
    chunk2 = create_json_streamchunk(json = Dict(
        :choices => [Dict(
            :delta => Dict(),
            :finish_reason => "stop"
        )]
    ))
    @test extract_stop_sequence(StreamCallbacks.OpenAIStream(), chunk2) == "stop"

    # Test Anthropic stop sequence
    chunk3 = create_json_streamchunk(json = Dict(
        :stop_sequence => "END"
    ))
    @test extract_stop_sequence(StreamCallbacks.AnthropicStream(), chunk3) == "END"

    # Test storage in RunInfo
    info = RunInfo()
    @test isnothing(info.stop_sequence)
    info.stop_sequence = "TEST"
    @test info.stop_sequence == "TEST"
end
```
