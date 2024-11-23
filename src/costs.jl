function calculate_cost(cost_of_token_prompt, cost_of_token_generation, tokens::TokenCounts, cache_write_multiplier, cache_read_multiplier)
    tokens.input * cost_of_token_prompt +
    tokens.cache_write * (cost_of_token_prompt * cache_write_multiplier) +
    tokens.cache_read * (cost_of_token_prompt * cache_read_multiplier) +
    tokens.output * cost_of_token_generation
end

function get_cost(::StreamCallbacks.AnthropicStream, model::String, tokens)
    (; cost_of_token_prompt, cost_of_token_generation) = PT.get(PT.MODEL_REGISTRY, model, (; cost_of_token_prompt=0.0, cost_of_token_generation=0.0))
    calculate_cost(cost_of_token_prompt, cost_of_token_generation, tokens, 1.25, 0.1)
end

function get_cost(::StreamCallbacks.OpenAIStream, model::String, tokens)
    (; cost_of_token_prompt, cost_of_token_generation) = PT.get(PT.MODEL_REGISTRY, model, (; cost_of_token_prompt=0.0, cost_of_token_generation=0.0))
    calculate_cost(cost_of_token_prompt, cost_of_token_generation, tokens, 1.0, 0.5)
end
