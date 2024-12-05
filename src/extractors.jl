"""
    extract_tokens(::StreamCallbacks.AbstractStreamFlavor, chunk::StreamCallbacks.AbstractStreamChunk)

Default token extractor that warns about unimplemented flavors.
"""
function extract_tokens(::StreamCallbacks.AbstractStreamFlavor, chunk::StreamCallbacks.AbstractStreamChunk)
    @warn "Unimplemented token extractor for flavor: $(typeof(flavor))"
    nothing
end

"""
    extract_tokens(::StreamCallbacks.AnthropicStream, chunk::StreamCallbacks.AbstractStreamChunk)

Extract token counts from Anthropic stream chunks. Handles both message_start events with usage information
and completion events with output tokens.
"""
function extract_tokens(::StreamCallbacks.AnthropicStream, chunk::StreamCallbacks.AbstractStreamChunk)
    !isnothing(chunk.json) || return nothing
    
    usage = if chunk.event == :message_start && haskey(chunk.json, :message)
        get(chunk.json[:message], :usage, nothing)
    else
        get(chunk.json, :usage, nothing)
    end
    isnothing(usage) && return nothing

    if chunk.event == :message_start
        TokenCounts(
            input=get(usage, :input_tokens, 0),
            output=0,
            cache_write=get(usage, :cache_creation_input_tokens, 0),
            cache_read=get(usage, :cache_read_input_tokens, 0)
        )
    else
        TokenCounts(output=get(usage, :output_tokens, 0))
    end
end

"""
    extract_tokens(::StreamCallbacks.OpenAIStream, chunk::StreamCallbacks.AbstractStreamChunk)

Extract token counts from OpenAI stream chunks. Handles both legacy and new token counting formats,
including cache hit/miss statistics.
"""
function extract_tokens(::StreamCallbacks.OpenAIStream, chunk::StreamCallbacks.AbstractStreamChunk)
    !isnothing(chunk.json) || return nothing
    usage = get(chunk.json, :usage, nothing)
    isnothing(usage) && return nothing
    
    prompt_details = get(usage, :prompt_tokens_details, nothing)

    if haskey(usage, :prompt_cache_hit_tokens)
        TokenCounts(
            input = get(usage, :prompt_cache_miss_tokens, 0),
            output = get(usage, :completion_tokens, 0),
            cache_write = 0,
            cache_read = get(usage, :prompt_cache_hit_tokens, 0)
        )
    else
        cache_read = isnothing(prompt_details) ? 0 : get(prompt_details, :cached_tokens, 0)
        TokenCounts(
            input = get(usage, :prompt_tokens, 0) - cache_read,
            output = get(usage, :completion_tokens, 0),
            cache_write = 0,
            cache_read = cache_read
        )
    end
end

"""
    extract_model(::StreamCallbacks.OpenAIStream, chunk::StreamCallbacks.AbstractStreamChunk)

Extract model identifier from OpenAI stream chunks.
"""
function extract_model(::StreamCallbacks.OpenAIStream, chunk::StreamCallbacks.AbstractStreamChunk)
    !isnothing(chunk.json) || return nothing
    get(chunk.json, :model, nothing)
end

"""
    extract_model(::StreamCallbacks.AnthropicStream, chunk::StreamCallbacks.AbstractStreamChunk)

Extract model identifier from Anthropic stream chunks, specifically from message_start events.
"""
function extract_model(::StreamCallbacks.AnthropicStream, chunk::StreamCallbacks.AbstractStreamChunk)
    !isnothing(chunk.json) || return nothing
    chunk.event == :message_start || return nothing
    get(chunk.json[:message], :model, nothing)
end

"""
    extract_model(::StreamCallbacks.AbstractStreamFlavor, chunk::StreamCallbacks.AbstractStreamChunk)

Default model extractor that warns about unimplemented flavors.
"""
function extract_model(::StreamCallbacks.AbstractStreamFlavor, chunk::StreamCallbacks.AbstractStreamChunk)
    @warn "Unimplemented model extractor for flavor: $(typeof(flavor))"
    nothing
end
