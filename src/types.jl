import Base: +

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

@kwdef mutable struct TimingInfo
    creation_time::Float64 = time()
    inference_start::Union{Float64,Nothing} = nothing
    last_message_time::Union{Float64,Nothing} = nothing
end

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
