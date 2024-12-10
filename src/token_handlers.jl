"""
    handle_token_metadata(::StreamCallbacks.OpenAIStream, cb, tokens, cost, elapsed)

Handle token metadata for OpenAI streams by calling both user and AI handlers.
All metadata is sent at once, so both handlers are called sequentially.
"""
function handle_token_metadata(::StreamCallbacks.OpenAIStream, cb, tokens, cost, elapsed)
    # OpenAI sends all token info at once, so call both handlers
    msg = cb.on_meta_usr(tokens, cost, elapsed)
    !isnothing(msg) && println(cb.out, "\n"*msg)
    msg = cb.on_meta_ai(tokens, cost, elapsed)
    !isnothing(msg) && println(cb.out, msg)
end

"""
Handle token metadata for Anthropic streams by dispatching based on token type.
Dispatches to user or AI handler based on whether output tokens are present.
"""
function handle_token_metadata(::StreamCallbacks.AnthropicStream, cb, tokens, cost, elapsed)
    # For Anthropic, dispatch based on token type
    msg = if tokens.output > 0
        "\n"*cb.on_meta_ai(tokens, cost, elapsed)
    else
        cb.on_meta_usr(tokens, cost, elapsed)
    end
    !isnothing(msg) && println(cb.out, msg)
end

"""
Default token metadata handler for other stream flavors.
"""
function handle_token_metadata(::StreamCallbacks.AbstractStreamFlavor, cb, tokens, cost, elapsed)
    msg = if tokens.output > 0
        cb.on_meta_ai(tokens, cost, elapsed)
    else
        cb.on_meta_usr(tokens, cost, elapsed)
    end
    !isnothing(msg) && println(cb.out, msg)
end
