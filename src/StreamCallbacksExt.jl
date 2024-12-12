module StreamCallbacksExt

using StreamCallbacks
using PromptingTools
const PT = PromptingTools

include("types.jl")
include("formatters.jl")
include("extractors.jl")
include("costs.jl")
include("token_handlers.jl")
include("wrappers.jl")
include("callbacks.jl")

# Update exports
export
    TokenCounts,
    RunInfo,
    StreamCallbackWithTokencounts,
    StreamCallbackWithHooks,
    StreamCallbackChannelWrapper,
    default_token_formatter,
    compact_token_formatter,
    default_content_formatter,
    extract_stop_sequence,
    extract_tokens,
    extract_model,
    get_total_elapsed,
    get_inference_elapsed
end
