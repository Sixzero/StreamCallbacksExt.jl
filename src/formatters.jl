"""
    default_token_formatter(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing)

Format token statistics in a default text format: `[in=X, out=Y, cache_in=Z, cache_read=W, \$C, Ts]`
"""
function default_token_formatter(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing)
    base = "in=$(tokens.input), out=$(tokens.output), cache_in=$(tokens.cache_write), cache_read=$(tokens.cache_read), \$$(round(cost, digits=4))"
    elapsed_str = isnothing(elapsed) ? "" : ", $(round(elapsed; digits=3))s"
    "[$base$elapsed_str]"
end

"""
    compact_token_formatter(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing)

Format token statistics in a compact, emoji-decorated format: `[🔤 in:X out:Y cache:(w:Z,r:W) 💰\$C ⚡️Ts]`
"""
function compact_token_formatter(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing)
    base = "🔤 in:$(tokens.input) out:$(tokens.output) cache:(w:$(tokens.cache_write),r:$(tokens.cache_read)) 💰\$$(round(cost, digits=4))"
    elapsed_str = isnothing(elapsed) ? "" : " ⚡️$(round(elapsed; digits=3))s"
    "\e[36m[$base$elapsed_str]\e[0m"
end

"""
    default_content_formatter(text::AbstractString)

Default content formatter that returns the text unchanged.
"""
default_content_formatter(text::AbstractString) = text
