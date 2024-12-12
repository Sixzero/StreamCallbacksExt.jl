# StreamCallbacksExt.jl

Documentation for [StreamCallbacksExt.jl](https://github.com/SixZero/StreamCallbacksExt.jl).

Extension package for [StreamCallbacks.jl](https://github.com/svilupp/StreamCallbacks.jl) with 3 things in mind:
- Instant feedback as soon as usage package comes in.
- Cached token informations
- Cached token costs
also adding timing for prompt processing time and inference time.
Primarily designed to extend streaming capabilities in [PromptingTools.jl](https://github.com/svilupp/PromptingTools.jl).

For detailed API documentation, see the [API Reference](api.md).

## Features

- Token counting for input, output, and cache operations
- Cost calculation for different LLM providers (OpenAI, Anthropic)
- Timing information for inference and message processing
- Customizable token and content formatters
- Support for different stream flavors (OpenAI, Anthropic)
- Flexible hook system for customizing callback behavior
- Channel-based async processing for cleaner stacktraces

## Installation

```julia
using Pkg
Pkg.add("git@github.com:Sixzero/StreamCallbacksExt.jl.git")
```

## Basic Usage

```julia
using PromptingTools, StreamCallbacks, StreamCallbacksExt
const PT = PromptingTools

# Basic streaming with token counting
cb = StreamCallbackWithTokencounts(
    out = stdout,  # or any IO
    flavor = StreamCallbacks.OpenAIStream(),
)
msg = aigenerate("Write a story about a space cat";
    streamcallback=cb,
    model="gpt4om",
    api_kwargs=(stream=true,)
)

# Using hooks for custom behavior
cb = StreamCallbackWithHooks(
    content_formatter = text -> "AI: $text",
    on_meta_usr = (tokens, cost, elapsed) -> "User tokens: $(tokens.input)",
    on_meta_ai = (tokens, cost, elapsed) -> "AI tokens: $(tokens.output)",
    on_error = e -> "Error: $e",
    on_done = () -> "Generation complete!"
)

# Using channel wrapper for cleaner stacktraces
cb = StreamCallbackChannelWrapper(
    callback = StreamCallbackWithHooks(
        on_error = e -> @warn("Error: $e")
    )
)
```

## Token Formatters

Two built-in formatters are provided:

### Default Text Format

```julia
cb = StreamCallbackWithTokencounts(
    flavor = StreamCallbacks.OpenAIStream(),
    token_formatter = default_token_formatter
)
# [in=10, out=20, cache_in=2, cache_read=5, $0.0015, 1.234s]
```

### Compact Emoji Format

```julia
cb = StreamCallbackWithTokencounts(
    flavor = StreamCallbacks.OpenAIStream(),
    token_formatter = compact_token_formatter
)
# [🔤 in:10 out:20 cache:(w:2,r:5) 💰$0.0015 ⚡️1.234s]
```

### Custom Formatter
```julia
# Create your own formatter
my_formatter(tokens, cost, elapsed) = "Words: \$(tokens.output/1.3) Cost: \\\$\$(round(cost; digits=4))"
cb = StreamCallbackWithTokencounts(
    flavor = StreamCallbacks.OpenAIStream(),
    token_formatter = my_formatter
)
```

## Dependencies

- [StreamCallbacks.jl](https://github.com/svilupp/StreamCallbacks.jl)
- [PromptingTools.jl](https://github.com/svilupp/PromptingTools.jl)
