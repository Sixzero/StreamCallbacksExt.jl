# StreamCallbacksExt.jl

Documentation for [StreamCallbacksExt.jl](https://github.com/SixZero/StreamCallbacksExt.jl).

Extension package for [StreamCallbacks.jl](https://github.com/svilupp/StreamCallbacks.jl) with 3 things in mind:
- Instant feedback as soon as usage package comes in.
- Cached token informations
- Cached token costs
also adding timing for prompt processing time and inference time.
Primarily designed to extend streaming capabilities in [PromptingTools.jl](https://github.com/svilupp/PromptingTools.jl).

## Features

- Token counting for input, output, and cache operations
- Cost calculation for different LLM providers (OpenAI, Anthropic)
- Timing information for inference and message processing
- Customizable token and content formatters
- Support for different stream flavors (OpenAI, Anthropic)

## Installation

using Pkg
Pkg.add("git@github.com:Sixzero/StreamCallbacksExt.jl.git")

## Basic Usage

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

## Token Formatters

Two built-in formatters are provided:

### Default Text Format

cb = StreamCallbackWithTokencounts(
    flavor = StreamCallbacks.OpenAIStream(),
    token_formatter = default_token_formatter
)
[in=10, out=20, cache_in=2, cache_read=5, \$0.0015, 1.234s]

### Compact Emoji Format

cb = StreamCallbackWithTokencounts(
    flavor = StreamCallbacks.OpenAIStream(),
    token_formatter = compact_token_formatter
)
[🔤 in:10 out:20 cache:(w:2,r:5) 💰\$0.0015 ⚡️1.234s]

### Custom Formatter
# Create your own formatter
my_formatter(tokens, cost, elapsed) = "Words: \$(tokens.output/1.3) Cost: \\\$\$(round(cost; digits=4))"
cb = StreamCallbackWithTokencounts(
    flavor = StreamCallbacks.OpenAIStream(),
    token_formatter = my_formatter
)

## Types

### TokenCounts
Tracks token usage across different categories:
- `input`: Number of new tokens in the prompt (excluding cached tokens)
- `output`: Number of generated tokens in the response
- `cache_write`: Number of tokens written to cache
- `cache_read`: Number of tokens read from cache

Note: Total input tokens = input + cache_write + cache_read

### TimingInfo
Tracks timing-related information during the streaming process:
- `creation_time`: When the callback was created
- `inference_start`: When the model started processing
- `last_message_time`: Timestamp of the last received message

### StreamCallbackWithTokencounts
Main callback type that implements token counting, cost tracking, and timing:
StreamCallbackWithTokencounts(;
    out = stdout,              # Output IO stream
    flavor = nothing,          # Stream format handler (OpenAI/Anthropic)
    total_tokens = TokenCounts(), # Accumulated token counts
    model = nothing,           # Model identifier
    token_formatter = default_token_formatter,
    content_formatter = default_content_formatter,
    timing = TimingInfo()
)

## Cost Calculation

The package automatically calculates costs based on the model and provider:

# OpenAI models
cb = StreamCallbackWithTokencounts(
    flavor = StreamCallbacks.OpenAIStream()
)

# Anthropic models
cb = StreamCallbackWithTokencounts(
    flavor = StreamCallbacks.AnthropicStream()
)

Each provider has specific cache multipliers for cost calculation:
- OpenAI: cache_write: 1.0x, cache_read: 0.5x
- Anthropic: cache_write: 1.25x, cache_read: 0.1x

## Dependencies

- [StreamCallbacks.jl](https://github.com/svilupp/StreamCallbacks.jl)
- [PromptingTools.jl](https://github.com/svilupp/PromptingTools.jl)

## API Reference

```@docs
TokenCounts
StreamCallbacksExt.extract_model(::StreamCallbacks.AnthropicStream, ::StreamCallbacks.AbstractStreamChunk)
StreamCallbacksExt.extract_model(::StreamCallbacks.OpenAIStream, ::StreamCallbacks.AbstractStreamChunk)
StreamCallbacksExt.extract_model(::StreamCallbacks.AbstractStreamFlavor, ::StreamCallbacks.AbstractStreamChunk)
StreamCallbacksExt.get_cost(::StreamCallbacks.OpenAIStream, ::String, ::Any)
StreamCallbacksExt.get_cost(::StreamCallbacks.AnthropicStream, ::String, ::Any)
StreamCallbacksExt.TimingInfo
StreamCallbacksExt.default_content_formatter
StreamCallbacksExt.extract_tokens(::StreamCallbacks.AnthropicStream, ::StreamCallbacks.AbstractStreamChunk)
StreamCallbacksExt.extract_tokens(::StreamCallbacks.OpenAIStream, ::StreamCallbacks.AbstractStreamChunk)
StreamCallbacksExt.extract_tokens(::StreamCallbacks.AbstractStreamFlavor, ::StreamCallbacks.AbstractStreamChunk)
StreamCallbacksExt.compact_token_formatter
StreamCallbacksExt.calculate_cost
StreamCallbacks.callback(::StreamCallbackWithTokencounts, ::StreamCallbacks.StreamChunk)
StreamCallbacksExt.default_token_formatter
StreamCallbacksExt.StreamCallbackWithTokencounts
```


