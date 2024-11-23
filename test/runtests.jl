using StreamCallbacksExt
using StreamCallbacks
using Test
using PromptingTools

@testset "StreamCallbacksExt.jl" begin
    # Include all test files
    include("token_counts_test.jl")
    include("formatters_test.jl")
    include("extractors_test.jl")
    include("costs_test.jl")
    include("integration_test.jl")
end
