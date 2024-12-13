using StreamCallbacksExt
using StreamCallbacksExt: get_cost, extract_model, extract_tokens, get_total_elapsed, get_inference_elapsed
using StreamCallbacks
using Test
using PromptingTools

@testset "StreamCallbacksExt.jl" failfast=true begin
    include("token_counts_test.jl")
    include("formatters_test.jl")
    include("extractors_test.jl")
    include("costs_test.jl")
    include("integration_test.jl")
    include("hooks_test.jl")
    include("extractors_test.jl")
    include("run_info_test.jl")
    include("stop_sequence_test.jl")
    include("channel_callback_test.jl")
end;