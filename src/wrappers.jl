"""
    StreamCallbackChannelWrapper(callback::StreamCallbackWithHooks; buffer_size=32)

A wrapper that processes stream chunks through a channel, providing isolated error handling
and shallow async processing. This results in cleaner stacktraces when errors occur, as the
async processing is only one level deep.

# Fields
- `callback`: The wrapped StreamCallbackWithHooks instance
- `channel`: Channel for async chunk processing
- `task`: Async task handling the processing loop

# Example
```julia
inner_cb = StreamCallbackWithHooks(on_error = e -> @warn("Error: \$e"))
cb = StreamCallbackChannelWrapper(inner_cb)

# Use with aigenerate
msg = aigenerate("Your prompt"; streamcallback=cb)
```

# Error Handling
When an error occurs in the wrapped callback, it will be caught and handled within the async task,
resulting in a much shorter stacktrace that doesn't include the full HTTP/stream processing chain.
This makes debugging easier as you only see the relevant error context.
"""
@kwdef mutable struct StreamCallbackChannelWrapper <: StreamCallbacks.AbstractStreamCallback
    callback::StreamCallbackWithHooks
    channel::Channel{Union{StreamChunk,Nothing}} = Channel{Union{StreamChunk,Nothing}}(32)
    task::Union{Task,Nothing} = nothing
end

# Property forwarding
Base.getproperty(cb::StreamCallbackChannelWrapper, name::Symbol) =
    name in (:callback, :channel, :task) ? getfield(cb, name) : getfield(cb.callback, name)
Base.setproperty!(cb::StreamCallbackChannelWrapper, name::Symbol, x) =
    name in (:callback, :channel, :task) ? setfield!(cb, name, x) : setfield!(cb.callback, name, x)

# Constructor from StreamCallbackWithHooks
StreamCallbackChannelWrapper(cb::StreamCallbackWithHooks; buffer_size::Int=32) =
    StreamCallbackChannelWrapper(callback=cb, channel=Channel{Union{StreamChunk,Nothing}}(buffer_size))

"""
    StreamCallbacks.callback(cb::StreamCallbackChannelWrapper, chunk::StreamChunk; kwargs...)

Process stream chunks through a channel-based async loop with isolated error handling.
"""
function StreamCallbacks.callback(cb::StreamCallbackChannelWrapper, chunk::StreamChunk; kwargs...)
    if isnothing(cb.task) || !isopen(cb.channel)
        cb.channel = Channel{Union{StreamChunk,Nothing}}(32)
        cb.task = @async begin
            try
                while true
                    chunk = take!(cb.channel)
                    isnothing(chunk) && break
                    StreamCallbacks.callback(cb.callback, chunk; kwargs...)
                end
            catch e
                msg = cb.callback.on_error(e)
                !isnothing(msg) && println(cb.callback.out, msg)
                cb.callback.throw_on_error && rethrow(e)
            finally
                close(cb.channel)
            end
        end
    end

    # Send chunk through channel
    put!(cb.channel, chunk)

    # Handle end conditions
    if get(chunk.json, :type, nothing) in ("message_end", "message_stop")
        put!(cb.channel, nothing)  # Signal to stop processing
    end

    nothing
end
