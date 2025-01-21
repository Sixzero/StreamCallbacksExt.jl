# Callback implementations for different stream callback types

"""
    callback(cb::StreamCallbackWithTokencounts, chunk::StreamChunk; kwargs...)

Process a stream chunk through the token-counting callback. This implementation:
- Tracks timing information for inference
- Extracts and accumulates token counts
- Calculates costs based on model and token usage
- Formats and prints token statistics and content

Returns a Dict with token counts if token information is available in the chunk.
"""
function StreamCallbacks.callback(cb::StreamCallbackWithTokencounts, chunk::StreamChunk; kwargs...)
    if !isnothing(chunk.json) && get(chunk.json, :type, nothing) == "message_start"
        cb.run_info.inference_start = time()
    end

    if isnothing(cb.model) && !isnothing(cb.flavor)
        cb.model = extract_model(cb.flavor, chunk)
    end

    # Handle token stats
    if (tokens = extract_tokens(cb.flavor, chunk)) !== nothing
        cb.total_tokens = cb.total_tokens + tokens

        cost = if !isnothing(cb.flavor)
            model = !isnothing(cb.model) ? cb.model : get(kwargs, :model, "")
            get_cost(cb.flavor, model, cb.total_tokens)
        else
            0.0
        end

        cb.run_info.last_message_time = time()
        elapsed = time() - cb.run_info.creation_time

        println(cb.out, cb.token_formatter(tokens, cost, elapsed))
    end

    # Handle content
    if !isnothing(cb.flavor)
        if (text = StreamCallbacks.extract_content(cb.flavor, chunk; kwargs...)) !== nothing
            print(cb.out, cb.content_formatter(text))
        end
        if (reasoning = extract_reasoning(cb.flavor, chunk)) !== nothing
            print(cb.out, "$(REASONING_COLOR)$reasoning$(Crayon(reset=true))")
        end
    end
end

function StreamCallbacks.callback(cb::StreamCallbackWithHooks, chunk::StreamChunk; kwargs...)
    # Early return if no json
    isnothing(chunk.json) && return nothing

    # Handle message start
    if get(chunk.json, :type, nothing) == "message_start"
        cb.run_info.inference_start = time()
        msg = cb.on_start()
        !isnothing(msg) && println(cb.out, msg)
    end

    # Extract model info if needed
    if isnothing(cb.model) && !isnothing(cb.flavor)
        cb.model = extract_model(cb.flavor, chunk)
    end

    # Handle content
    try
        if !isnothing(cb.flavor)
            if (reasoning = extract_reasoning(cb.flavor, chunk)) !== nothing
                !cb.in_reasoning_mode && print(cb.out, "$(REASONING_COLOR)")
                cb.in_reasoning_mode = true
                print(cb.out, reasoning)
            elseif (text = StreamCallbacks.extract_content(cb.flavor, chunk; kwargs...)) !== nothing
                if cb.in_reasoning_mode
                    print(cb.out, "$(Crayon(reset=true))\n\n")
                    cb.in_reasoning_mode = false
                end
                formatted = cb.content_formatter(text)
                !isnothing(formatted) && print(cb.out, formatted)
            end
        end
    catch e
        msg = cb.on_error(e)
        !isnothing(msg) && println(stderr, msg)
        cb.throw_on_error && rethrow(e)
    end

    # Store stop sequence if present
    if !isnothing(cb.flavor) && (stop_seq = extract_stop_sequence(cb.flavor, chunk)) !== nothing
        cb.run_info.stop_sequence = stop_seq
        cb.on_stop_sequence(stop_seq)
    end

    # Handle token metadata with flavor-specific dispatch
    if !isnothing(cb.flavor) && (tokens = extract_tokens(cb.flavor, chunk)) !== nothing
        cb.total_tokens = cb.total_tokens + tokens
        cost = get_cost(cb.flavor, !isnothing(cb.model) ? cb.model : get(kwargs, :model, ""), cb.total_tokens)
        cb.run_info.last_message_time = time()
        elapsed = cb.run_info.last_message_time - cb.run_info.creation_time

        handle_token_metadata(cb.flavor, cb, tokens, cost, elapsed)
    end

    # Handle completion
    if get(chunk.json, :type, nothing) in ("message_end", "message_stop")
        msg = cb.on_done()
        !isnothing(msg) && println(cb.out, msg)
    end
end
