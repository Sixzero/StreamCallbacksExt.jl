using Test
using StreamCallbacks
using StreamCallbacksExt
using JSON3
include("test_utils.jl")  # Include the shared utilities

create_json_streamchunk(; json, event=nothing) = StreamChunk(
    event=event,
    data="",  # Empty string as default data
    json=JSON3.read(JSON3.write(json))
)

@testset "StreamCallbackWithHooks" begin
    # Test basic hook functionality
    events = String[]
    buf = IOBuffer()

    cb = StreamCallbackWithHooks(
        flavor = StreamCallbacks.OpenAIStream(),
        out = buf,
        content_formatter = text -> push!(events, "content: $text"),
        on_meta_usr = (tokens, cost, elapsed) -> push!(events, "usr_meta"),
        on_meta_ai = (tokens, cost, elapsed) -> push!(events, "ai_meta"),
        on_error = e -> push!(events, "error: $e"),
        on_done = () -> push!(events, "done"),
        on_start = () -> push!(events, "start")
    )

    # Test message_start
    chunk1 = create_json_streamchunk(json = Dict(:type => "message_start"), event = :message_start)
    StreamCallbacks.callback(cb, chunk1)
    @test "start" in events

    # Test content
    chunk2 = create_json_streamchunk(json = Dict(:choices => [Dict(:delta => Dict(:content => "test"))]))
    StreamCallbacks.callback(cb, chunk2)
    @test "content: test" in events

    # Test message_stop (Anthropic)
    chunk3 = create_json_streamchunk(json = Dict(:type => "message_stop"), event = :message_stop)
    StreamCallbacks.callback(cb, chunk3)
    @test "done" in events

    # Test message_end (OpenAI)
    events = String[]
    chunk4 = create_json_streamchunk(json = Dict(:type => "message_end"), event = :message_end)
    StreamCallbacks.callback(cb, chunk4)
    @test "done" in events

    # Test error handling
    events = String[]  # Reset events array
    cb = StreamCallbackWithHooks(
        flavor = StreamCallbacks.OpenAIStream(),  # Add flavor to enable content extraction
        content_formatter = _ -> error("test error"),
        on_error = e -> push!(events, "error"),
        throw_on_error = false,
        on_done = () -> push!(events, "done")
    )
    chunk = create_json_streamchunk(
        json = Dict(:choices => [Dict(:delta => Dict(:content => "test"))]),
        event = nothing
    )
    StreamCallbacks.callback(cb, chunk)
    @test "error" in events
end

@testset "Colored Message Formatting" begin
    buf = IOBuffer()
    cb = StreamCallbackWithHooks(
        out=buf,
        flavor=StreamCallbacks.OpenAIStream(),
        on_meta_usr = (tokens, cost=0.0, elapsed=nothing) ->
            "User message: [$(tokens.input) in, $(tokens.cache_read) cache read]",
        on_meta_ai = (tokens, cost=0.0, elapsed=nothing) ->
            "AI message: [$(tokens.output) out]",
        on_start = () -> "Starting..."
    )

    # Test user message formatting
    chunk1 = create_json_streamchunk(
        json = Dict(
            :type => "message_start",
            :usage => Dict(
                :prompt_tokens => 17762,
                :prompt_tokens_details => Dict(
                    :cached_tokens => 17760,
                )
            )
        ),
        event = :message_start
    )
    StreamCallbacks.callback(cb, chunk1)
    output = String(take!(buf))
    @test contains(output, "Starting...")
    @test contains(output, "User message:")
    @test contains(output, "2 in")
    @test contains(output, "17760 cache read")

    # Test AI message formatting
    chunk2 = create_json_streamchunk(
        json = Dict(:usage => Dict(:completion_tokens => 1520))
    )
    StreamCallbacks.callback(cb, chunk2)
    output = String(take!(buf))
    @test contains(output, "AI message:")
    @test contains(output, "1520 out")
end
