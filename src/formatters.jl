using Crayons

# Color constants using Crayons
const USER_COLOR = Crayon(foreground=:green, bold=true)
const AI_COLOR = Crayon(foreground=:green)
const ERROR_COLOR = Crayon(foreground=:red)
const INFO_COLOR = Crayon(foreground=:blue)
const TOKEN_COLOR = Crayon(foreground=:cyan)
const REASONING_COLOR = Crayon(foreground=:dark_gray, italics=true)

"""
    default_token_formatter(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing)

Format token statistics in a default text format: `[in=X, out=Y, cache_in=Z, cache_read=W, \$C, Ts]`
"""
function default_token_formatter(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing)
    is_end = tokens.input == 0
    new_line = is_end ? "\n" : ""
    base = "in=$(tokens.input), out=$(tokens.output), cache_in=$(tokens.cache_write), cache_read=$(tokens.cache_read), \$$(round(cost, digits=4))"
    elapsed_str = isnothing(elapsed) ? "" : ", $(round(elapsed; digits=3))s"
    "$new_line[$base$elapsed_str]"
end

"""
    compact_token_formatter(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing)

Format token statistics in a compact, emoji-decorated format: `[🔤 in:X out:Y cache:(w:Z,r:W) 💰\$C ⚡️Ts]`
"""
function compact_token_formatter(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing)
    base = "🔤 in:$(tokens.input) out:$(tokens.output) cache:(w:$(tokens.cache_write),r:$(tokens.cache_read)) 💰\$$(round(cost, digits=4))"
    elapsed_str = isnothing(elapsed) ? "" : " ⚡️$(round(elapsed; digits=3))s"
    "$(TOKEN_COLOR)[$base$elapsed_str]$(Crayon(reset=true))"
end

"""
    default_content_formatter(text::AbstractString)

Default content formatter that returns the text unchanged.
"""
default_content_formatter(text::AbstractString) = text

"""
    format_user_meta(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing) -> String

Format user message with token counts in green color, including token statistics and optional timing.
"""
function format_user_meta(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing)
    elapsed_str = isnothing(elapsed) ? "" : ", $(round(elapsed; digits=2))s"
    "$(USER_COLOR)User message: [$(tokens.input) in, $(tokens.cache_write) cache creation, $(tokens.cache_read) cache read, \$$(round(cost; digits=3))$elapsed_str]$(Crayon(reset=true))"
end

function dict_user_meta(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing)
    elapsed_str = isnothing(elapsed) ? nothing : round(elapsed; digits=2)
    Dict(
        "input" => tokens.input,
        "cache_write" => tokens.cache_write,
        "cache_read" => tokens.cache_read,
        "cost" => round(cost; digits=3),
        "elapsed" => elapsed_str
    )
end

"""
    format_ai_meta(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing) -> String

Format AI message with token counts in green color, including output tokens, cost and optional timing.
"""
function format_ai_meta(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing)
    elapsed_str = isnothing(elapsed) ? "" : ", $(round(elapsed; digits=2))s"
    "$(AI_COLOR)AI message: [$(tokens.output) out, \$$(round(cost; digits=3))$elapsed_str]$(Crayon(reset=true))"
end

function dict_ai_meta(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing)
    elapsed_str = isnothing(elapsed) ? nothing : round(elapsed; digits=2)
    Dict(
        "output" => tokens.output,
        "cost" => round(cost; digits=3),
        "elapsed" => elapsed_str
    )
end

"""
    format_error_message(e) -> String

Format error message in red color.
"""
function format_error_message(e)
    "$(ERROR_COLOR)Error: $e$(Crayon(reset=true))"
end

"""
    format_info_message(msg) -> String

Format info messages in blue color.
"""
function format_info_message(msg)
    "$(INFO_COLOR)$msg$(Crayon(reset=true))"
end
