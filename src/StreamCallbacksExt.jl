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
        return Dict(:prompt_tokens => tokens.input, :completion_tokens => tokens.output)
    end
    
    processed_text = StreamCallbacks.extract_content(cb.flavor, chunk; kwargs...)
    isnothing(processed_text) && return "HEY"
    
    print(cb.out, cb.content_formatter(processed_text))
end

# Export all public types and functions
export 
    # Types
    TokenCounts,
    TimingInfo,
    StreamCallbackWithTokencounts,
    
    # Formatters
    default_token_formatter,
    compact_token_formatter,
    default_content_formatter

end
