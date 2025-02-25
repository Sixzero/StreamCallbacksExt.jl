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

Extract token counts from OpenAI stream chunks. Handles:
- Legacy format with prompt_tokens and completion_tokens
- Cache hit/miss statistics
- Detailed token breakdowns (cached_tokens, audio_tokens)
- End-of-stream combined usage statistics
"""
function extract_tokens(::StreamCallbacks.OpenAIStream, chunk::StreamCallbacks.AbstractStreamChunk)
    !isnothing(chunk.json) || return nothing
    usage = get(chunk.json, :usage, nothing)
    isnothing(usage) && return nothing

    # Handle end-of-stream combined stats
    if haskey(usage, :prompt_tokens) && haskey(usage, :completion_tokens) &&
       haskey(usage, :prompt_tokens_details)
        prompt_details = usage.prompt_tokens_details
        cache_read = get(prompt_details, :cached_tokens, 0)
        audio_tokens = get(prompt_details, :audio_tokens, 0)

        return TokenCounts(
            input = usage.prompt_tokens - cache_read - audio_tokens,
            output = usage.completion_tokens,
            cache_write = 0,
            cache_read = cache_read
        )
    end

    # Handle streaming format with cache stats
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

"""
    extract_stop_sequence(::StreamCallbacks.AbstractStreamFlavor, chunk::StreamCallbacks.AbstractStreamChunk)

Default stop sequence extractor that returns nothing.
"""
function extract_stop_sequence(::StreamCallbacks.AbstractStreamFlavor, chunk::StreamCallbacks.AbstractStreamChunk)
    nothing
end

"""
    extract_stop_sequence(::StreamCallbacks.OpenAIStream, chunk::StreamCallbacks.AbstractStreamChunk)

Extract stop sequence from OpenAI stream chunks. Handles both delta.stop_sequence and finish_reason="stop".
"""
function extract_stop_sequence(::StreamCallbacks.OpenAIStream, chunk::StreamCallbacks.AbstractStreamChunk)
    !isnothing(chunk.json) || return nothing

    # Handle finish_reason="stop" format
    if haskey(chunk.json, :choices) && !isempty(chunk.json.choices) &&
       haskey(chunk.json.choices[1], :finish_reason) && chunk.json.choices[1].finish_reason == "stop"
        return "stop"
    end

    # Handle delta.stop_sequence format, although openai probably not using this...
    if haskey(chunk.json, :choices) && !isempty(chunk.json.choices) &&
       haskey(chunk.json.choices[1], :delta) && haskey(chunk.json.choices[1].delta, :stop_sequence)
        return chunk.json.choices[1].delta.stop_sequence
    end
    
    nothing
end

"""
    extract_stop_sequence(::StreamCallbacks.AnthropicStream, chunk::StreamCallbacks.AbstractStreamChunk)

Extract stop sequence from Anthropic stream chunks.
"""
function extract_stop_sequence(::StreamCallbacks.AnthropicStream, chunk::StreamCallbacks.AbstractStreamChunk)
    !isnothing(chunk.json) || return nothing
    delta = get(chunk.json, :delta, nothing)
    isnothing(delta) && return nothing
    get(delta, :stop_sequence, nothing)
end

"""
    extract_reasoning(::StreamCallbacks.AbstractStreamFlavor, chunk::StreamCallbacks.AbstractStreamChunk)

Default reasoning content extractor that warns if unhandled reasoning content is detected.
"""
function extract_reasoning(::StreamCallbacks.AbstractStreamFlavor, chunk::StreamCallbacks.AbstractStreamChunk)
    if !isnothing(chunk.json) && haskey(chunk.json, :choices) && !isempty(chunk.json.choices) &&
       haskey(chunk.json.choices[1], :delta) && haskey(chunk.json.choices[1].delta, :reasoning_content)
        @warn "Unhandled reasoning content for flavor: $(typeof(flavor))"
    end
    nothing
end

"""
    extract_reasoning(::StreamCallbacks.OpenAIStream, chunk::StreamCallbacks.AbstractStreamChunk)

Extract reasoning content from OpenAI stream chunks.
"""
function extract_reasoning(::StreamCallbacks.OpenAIStream, chunk::StreamCallbacks.AbstractStreamChunk)
    isnothing(chunk.json) && return nothing
    haskey(chunk.json, :choices) || return nothing
    isempty(chunk.json.choices) && return nothing
    
    delta = chunk.json.choices[1].delta
    get(delta, :reasoning_content, nothing)
end

"""
    extract_reasoning(::StreamCallbacks.AnthropicStream, chunk::StreamCallbacks.AbstractStreamChunk)

Extract reasoning/thinking content from Anthropic stream chunks.
"""
function extract_reasoning(::StreamCallbacks.AnthropicStream, chunk::StreamCallbacks.AbstractStreamChunk)
    isnothing(chunk.json) && return nothing
    
    # Handle content_block_delta with thinking_delta
    if get(chunk.json, :type, nothing) == "content_block_delta" && 
       haskey(chunk.json, :delta) && 
       get(chunk.json[:delta], :type, nothing) == "thinking_delta"
        return get(chunk.json[:delta], :thinking, nothing)
    end
    
    nothing
end
