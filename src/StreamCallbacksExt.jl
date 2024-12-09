module StreamCallbacksExt

using StreamCallbacks
using PromptingTools
const PT = PromptingTools

include("types.jl")
include("formatters.jl")
include("extractors.jl")
include("costs.jl")

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
        cb.timing.inference_start = time()
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

        cb.timing.last_message_time = time()
        elapsed = time() - cb.timing.creation_time

        println(cb.out, cb.token_formatter(tokens, cost, elapsed))
        # return Dict(:prompt_tokens => tokens.input, :completion_tokens => tokens.output)
    end

    # Handle content
    if !isnothing(cb.flavor) && (text = StreamCallbacks.extract_content(cb.flavor, chunk; kwargs...)) !== nothing
        print(cb.out, cb.content_formatter(text))
    end
end

function StreamCallbacks.callback(cb::StreamCallbackWithHooks, chunk::StreamChunk; kwargs...)
    # Early return if no json
    isnothing(chunk.json) && return nothing

    # Store stop sequence if present
    if !isnothing(cb.flavor) && (stop_seq = extract_stop_sequence(cb.flavor, chunk)) !== nothing
        cb.timing.stop_sequence = stop_seq
    end

    # Handle message start
    if get(chunk.json, :type, nothing) == "message_start"
        cb.timing.inference_start = time()
        println(cb.out, cb.on_start())
    end

    # Extract model info if needed
    if isnothing(cb.model) && !isnothing(cb.flavor)
        cb.model = extract_model(cb.flavor, chunk)
    end

    # Handle token metadata
    if !isnothing(cb.flavor) && (tokens = extract_tokens(cb.flavor, chunk)) !== nothing
        cb.total_tokens = cb.total_tokens + tokens
        cost = get_cost(cb.flavor, !isnothing(cb.model) ? cb.model : get(kwargs, :model, ""), cb.total_tokens)
        cb.timing.last_message_time = time()
        elapsed = time() - cb.timing.creation_time

        # Dispatch metadata hooks based on token type
        msg = if tokens.output > 0
            cb.on_meta_ai(tokens, cost, elapsed)
        else
            cb.on_meta_usr(tokens, cost, elapsed)
        end
        !isnothing(msg) && println(cb.out, msg)

        # return Dict(:prompt_tokens => tokens.input, :completion_tokens => tokens.output)
    end

    # Handle content
    try
        if !isnothing(cb.flavor) && (text = StreamCallbacks.extract_content(cb.flavor, chunk; kwargs...)) !== nothing
            formatted = cb.content_formatter(text)
            !isnothing(formatted) && print(cb.out, formatted)
        end
    catch e
        msg = cb.on_error(e)
        !isnothing(msg) && println(stderr, msg)
        cb.throw_on_error && rethrow(e)
    end

    # Handle completion
    if get(chunk.json, :type, nothing) in ("message_end", "message_stop")
        msg = cb.on_done()
        !isnothing(msg) && println(cb.out, msg)
    end
end

# Update exports
export
    TokenCounts,
    RunInfo,  # Changed from TimingInfo
    StreamCallbackWithTokencounts,
    StreamCallbackWithHooks,
    default_token_formatter,
    compact_token_formatter,
    default_content_formatter,
    extract_stop_sequence,  # Add this export
    extract_tokens,         # Add this export
    extract_model          # Add this export
end
