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
    TimingInfo(; creation_time=time(), inference_start=nothing, last_message_time=nothing)

Tracks timing information during the streaming process:
- `creation_time`: When the callback was created
- `inference_start`: When the model started processing
- `last_message_time`: Timestamp of the last received message
"""
@kwdef mutable struct TimingInfo
    creation_time::Float64 = time()
    inference_start::Union{Float64,Nothing} = nothing
    last_message_time::Union{Float64,Nothing} = nothing
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
        timing=TimingInfo()
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
    timing::TimingInfo = TimingInfo()
end
