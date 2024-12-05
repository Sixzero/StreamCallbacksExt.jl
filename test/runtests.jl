using StreamCallbacksExt
using StreamCallbacksExt: get_cost, extract_model, extract_tokens
using StreamCallbacks
using Test
using PromptingTools

@testset "StreamCallbacksExt.jl" begin
    include("token_counts_test.jl")
    include("formatters_test.jl")
    include("extractors_test.jl")
    include("costs_test.jl")
    include("integration_test.jl")
end
