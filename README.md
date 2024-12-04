# StreamCallbacksExt.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://SixZero.github.io/StreamCallbacksExt.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://SixZero.github.io/StreamCallbacksExt.jl/dev)
[![Build Status](https://github.com/SixZero/StreamCallbacksExt.jl/workflows/CI/badge.svg)](https://github.com/SixZero/StreamCallbacksExt.jl/actions)
[![Coverage](https://codecov.io/gh/SixZero/StreamCallbacksExt.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/SixZero/StreamCallbacksExt.jl)

Extension package for [StreamCallbacks.jl](https://github.com/svilup/StreamCallbacks.jl) that adds token counting, cost calculation, and timing functionality, primarily designed to enhance streaming capabilities in [PromptingTools.jl](https://github.com/svilup/PromptingTools.jl).

## Features

- Token counting for input, output, and cache operations
- Cost calculation for different LLM providers (OpenAI, Anthropic)
- Timing information for inference and message processing
- Customizable token and content formatters
- Support for different stream flavors (OpenAI, Anthropic)

## Installation

```julia
using Pkg
Pkg.add("git@github.com:Sixzero/StreamCallbacksExt.jl.git")
```

## Usage with PromptingTools.jl

The main use case is to enable streaming responses with token counting and timing when using PromptingTools.jl's `aigenerate`:
```julia
using PromptingTools
using StreamCallbacks
using StreamCallbacksExt
const PT = PromptingTools

# 1. Basic streaming to stdout
msg = aigenerate("Write a story about a space cat"; 
    streamcallback=stdout,  # Simplest way to stream to terminal
    model="gpt4om",
    api_kwargs=(stream=true,)  # Enable streaming mode!
)

# 2. Stream with token counting and timing
cb = StreamCallbackWithTokencounts(
    out = stdout,  # or any IO
    flavor = StreamCallbacks.OpenAIStream(),
)
msg = aigenerate("Write a story about a space cat";
    streamcallback=cb,
    model="gpt4om",
    api_kwargs=(stream=true,)  # Must enable streaming!
)
# 2. B Stream with token counting and timing for Anthropic models
cb = StreamCallbackWithTokencounts(
    out = stdout,  # or any IO
    flavor = StreamCallbacks.AnthropicStream(),
)
msg = aigenerate("Write a story about a space cat";
    streamcallback=cb,
    model="claudeh",
    api_kwargs=(stream=true,)  # Must enable streaming!
)
# [in=25, out=0, cache_in=0, cache_read=0, $0.0, 0.554s]
# Whiskers, a brave tabby, sailed past Mars in his silver rocket, chasing cosmic mice and dreaming of tuna asteroids.
# [in=0, out=33, cache_in=0, cache_read=0, $0.0002, 1.345s]

# ^ Shows both the story and output token stats.

# 3. Custom formatting of token information
my_formatter(tokens, cost, elapsed) = "Words: $(tokens.output/1.3) Cost: \$$(round(cost; digits=4))"
cb = StreamCallbackWithTokencounts(
    flavor = StreamCallbacks.OpenAIStream(),
    token_formatter = my_formatter
)
msg = aigenerate("Write a story about a space cat"; 
    streamcallback=cb,
    model="gpt4om",
    api_kwargs=(stream=true,)  # Don't forget streaming!
)
```

## Token Formatters

Two built-in formatters are provided:

- `default_token_formatter`: Simple text format
  ```
  [in=10, out=20, cache_in=2, cache_read=5, $0.0015, 1.234s]
  ```

- `compact_token_formatter`: Colorful emoji format
  ```
  [🔤 in:10 out:20 cache:(w:2,r:5) 💰$0.0015 ⚡️1.234s]
  ```

## Dependencies

- StreamCallbacks.jl
- PromptingTools.jl