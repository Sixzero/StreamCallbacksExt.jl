# StreamCallbacksExt.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://SixZero.github.io/StreamCallbacksExt.jl/dev)
[![Build Status](https://github.com/SixZero/StreamCallbacksExt.jl/workflows/CI/badge.svg)](https://github.com/SixZero/StreamCallbacksExt.jl/actions)
[![Coverage](https://codecov.io/gh/SixZero/StreamCallbacksExt.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/SixZero/StreamCallbacksExt.jl)

Extension package for [StreamCallbacks.jl](https://github.com/svilupp/StreamCallbacks.jl) that adds token counting, cost calculation, and timing functionality, primarily designed to enhance streaming capabilities in [PromptingTools.jl](https://github.com/svilupp/PromptingTools.jl).

## Features

- Token counting for input, output, and cache operations
- Cost calculation for different LLM providers (OpenAI, Anthropic)
- Timing information for inference and message processing
- Customizable token and content formatters
- Support for different stream flavors (OpenAI, Anthropic)
- Customizable hooks for stream events

## Installation

```julia
using Pkg
Pkg.add("git@github.com:Sixzero/StreamCallbacksExt.jl.git")
```

## Usage with PromptingTools.jl

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

# 3. Stream with custom hooks and formatters
cb = StreamCallbackWithHooks(
    out = stdout,
    flavor = StreamCallbacks.OpenAIStream(),
    content_formatter = text -> "AI: $text",
    on_meta_usr = (tokens, cost, elapsed) -> "User tokens: $(tokens.input)",
    on_meta_ai = (tokens, cost, elapsed) -> "AI tokens: $(tokens.output)",
    on_error = e -> "Error: $e",
    on_done = () -> "Generation complete!",
    on_start = () -> "Starting..."
)
msg = aigenerate("Write a story about a space cat";
    streamcallback=cb,
    model="gpt4om",
)
```

For more detailed information and advanced usage, please see the [documentation](https://SixZero.github.io/StreamCallbacksExt.jl/dev).