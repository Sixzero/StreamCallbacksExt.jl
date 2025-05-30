import Base: +

"""
    TokenCounts(; input=0, output=0, cache_write=0, cache_read=0)

Tracks token usage across different categories:
- `input`: Number of new tokens in prompt (excluding cached tokens)
- `output`: Number of generated tokens in response
- `cache_write`: Number of tokens written to cache
- `cache_read`: Number of tokens read from cache

Note: Total input tokens = input + cache_write + cache_read
"""
@kwdef struct TokenCounts
    input::Int = 0
    output::Int = 0
    cache_write::Int = 0
    cache_read::Int = 0
end

+(a::TokenCounts, b::TokenCounts) = TokenCounts(
    input = a.input + b.input,
    output = a.output + b.output,
    cache_write = a.cache_write + b.cache_write,
    cache_read = a.cache_read + b.cache_read
)

"""
    RunInfo(; creation_time=time(), inference_start=nothing, last_message_time=nothing, stop_sequence=nothing)

Tracks run statistics and metadata during the streaming process.

# Fields
- `creation_time`: When the callback was created
- `inference_start`: When the model started processing
- `last_message_time`: Timestamp of the last received message
- `stop_sequence`: The sequence that caused the generation to stop (if any). For OpenAI this can be:
  - A specific stop sequence provided in the chunk's delta.stop_sequence
  - "stop" if finish_reason is "stop"
  For Anthropic this is the stop_sequence provided in the chunk.

# Timing Methods
- `get_total_elapsed(info)`: Get total elapsed time since callback creation
- `get_inference_elapsed(info)`: Get elapsed time for inference phase only
"""
@kwdef mutable struct RunInfo
    creation_time::Float64 = time()
    inference_start::Union{Float64,Nothing} = nothing
    last_message_time::Union{Float64,Nothing} = nothing
    stop_sequence::Union{String,Nothing} = nothing
end

# Add utility functions for RunInfo
"""
    get_total_elapsed(info::RunInfo)

Get total elapsed time since callback creation.
Returns time in seconds or nothing if no messages received.
"""
get_total_elapsed(info::RunInfo) = !isnothing(info.last_message_time) ? info.last_message_time - info.creation_time : nothing

"""
    get_inference_elapsed(info::RunInfo)

Get elapsed time for inference (time between first inference and last message).
Returns time in seconds or nothing if inference hasn't started.
"""
get_inference_elapsed(info::RunInfo) = !isnothing(info.inference_start) && !isnothing(info.last_message_time) ?
    info.last_message_time - info.inference_start : nothing

"""
    needs_tool_execution(info::RunInfo)

Check if the run was terminated because the model is requested tool execution (with stop_sequence).
"""
function needs_tool_execution(info::RunInfo)
    return !isnothing(info.stop_sequence)
end

"""
    StreamCallbackWithTokencounts(; 
        out=stdout, 
        flavor=nothing, 
        chunks=StreamChunk[], 
        verbose=false,
        throw_on_error=false,
        kwargs=NamedTuple(),
        total_tokens=TokenCounts(),
        model=nothing,
        token_formatter=default_token_formatter,
        content_formatter=default_content_formatter,
        timing=RunInfo()
    )

A stream callback that tracks token usage, costs, and timing information.

# Arguments
- `out`: Output IO stream (default: stdout)
- `flavor`: Stream format handler (OpenAI/Anthropic)
- `chunks`: Vector to store stream chunks
- `verbose`: Enable verbose logging
- `throw_on_error`: Whether to throw errors
- `kwargs`: Additional keyword arguments
- `total_tokens`: Accumulated token counts
- `model`: Model identifier
- `token_formatter`: Function to format token statistics
- `content_formatter`: Function to format streamed content
- `timing`: Timing information

# Example
cb = StreamCallbackWithTokencounts(
    out = stdout,
    flavor = StreamCallbacks.OpenAIStream()
)
"""
@kwdef mutable struct StreamCallbackWithTokencounts <: StreamCallbacks.AbstractStreamCallback
    out::IO = stdout
    flavor::Union{StreamCallbacks.AbstractStreamFlavor,Nothing} = nothing
    chunks::Vector{StreamChunk} = StreamChunk[]
    verbose::Bool = false
    throw_on_error::Bool = false
    kwargs::NamedTuple = NamedTuple()
    total_tokens::TokenCounts = TokenCounts()
    model::Union{String,Nothing} = nothing
    token_formatter::Function = default_token_formatter
    content_formatter::Function = default_content_formatter
    run_info::RunInfo = RunInfo()  # Renamed from timing to run_info
end

"""
    StreamCallbackWithHooks(; kwargs...)

A stream callback that combines token counting with customizable hooks for various events.

# Fields
- `out`: Output IO stream (default: stdout)
- `flavor`: Stream format handler (OpenAI/Anthropic)
- `chunks`: Vector to store stream chunks
- `verbose`: Enable verbose logging
- `throw_on_error`: Whether to throw errors
- `kwargs`: Additional keyword arguments
- `total_tokens`: Accumulated token counts
- `model`: Model identifier
- `token_formatter`: Function to format token statistics
- `timing`: Timing information

# Hooks
- `content_formatter`: Function to process and format content text
- `on_meta_usr`: Handler for user token counts/metadata
- `on_meta_ai`: Handler for AI token counts/metadata
- `on_error`: Error handler
- `on_done`: Completion handler
- `on_start`: Start handler

# Example
```julia
cb = StreamCallbackWithHooks(
    on_meta_ai = (tokens, cost, elapsed) -> println("AI: \$(tokens.output) tokens")
)
```
"""
@kwdef mutable struct StreamCallbackWithHooks <: StreamCallbacks.AbstractStreamCallback
    out::IO = stdout
    flavor::Union{StreamCallbacks.AbstractStreamFlavor,Nothing} = nothing
    chunks::Vector{StreamChunk} = StreamChunk[]
    verbose::Bool = false
    throw_on_error::Bool = false
    kwargs::NamedTuple = NamedTuple()
    run_info::RunInfo = RunInfo()
    total_tokens::TokenCounts = TokenCounts()
    model::Union{String,Nothing} = nothing
    token_formatter::Function = default_token_formatter

    # some inner workings...
    in_reasoning_mode::Bool = false

    # Hooks with colored formatters
    content_formatter::Function = identity
    on_meta_usr::Function = (tokens, cost=0.0, elapsed=nothing) -> format_user_meta(tokens, cost, elapsed)
    on_meta_ai::Function = (tokens, cost=0.0, elapsed=nothing) -> format_ai_meta(tokens, cost, elapsed)
    on_error::Function = e -> format_error_message(e)
    on_done::Function = () -> nothing
    on_start::Function = () -> nothing
    on_stop_sequence::Function = identity
end

