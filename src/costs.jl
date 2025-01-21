using PromptingTools

"""
    calculate_cost(cost_of_token_prompt::Real, cost_of_token_generation::Real,
                  tokens::TokenCounts, cache_write_multiplier::Real, cache_read_multiplier::Real)

Calculate the total cost for token usage based on the provided rates and multipliers.
"""
function calculate_cost(cost_of_token_prompt::Real, cost_of_token_generation::Real, tokens::TokenCounts, cache_write_multiplier::Real, cache_read_multiplier::Real)
    tokens.input * cost_of_token_prompt +
    tokens.cache_write * (cost_of_token_prompt * cache_write_multiplier) +
    tokens.cache_read * (cost_of_token_prompt * cache_read_multiplier) +
    tokens.output * cost_of_token_generation
end

"""
    get_cost(::StreamCallbacks.AnthropicStream, model::String, tokens::TokenCounts)

Calculate costs for Anthropic models with their specific cache multipliers.
"""
function get_cost(::StreamCallbacks.AnthropicStream, model::String, tokens::TokenCounts)
    (; cost_of_token_prompt, cost_of_token_generation) = PromptingTools.get(PromptingTools.MODEL_REGISTRY, model, (; cost_of_token_prompt=0.0, cost_of_token_generation=0.0))
    calculate_cost(cost_of_token_prompt, cost_of_token_generation, tokens, 1.25, 0.1)
end

"""
    get_cost(::StreamCallbacks.OpenAIStream, model::String, tokens::TokenCounts)

Calculate costs for OpenAI models with their specific cache multipliers.
"""
function get_cost(::StreamCallbacks.OpenAIStream, model::String, tokens::TokenCounts)
    (; cost_of_token_prompt, cost_of_token_generation) = PromptingTools.get(PromptingTools.MODEL_REGISTRY, model, (; cost_of_token_prompt=0.0, cost_of_token_generation=0.0))
    cache_read_multiplier= 0.5
    if model == "deepseek-chat"
        cache_read_multiplier = 0.1
    end
    if model == "deepseek-reasoner"
        cache_read_multiplier = 0.14/0.55
    end
    calculate_cost(cost_of_token_prompt, cost_of_token_generation, tokens, 1.0, cache_read_multiplier)
end
