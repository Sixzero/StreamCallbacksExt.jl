# API Reference

```@setup
using StreamCallbacksExt
```

## Timing Utilities

```@docs
StreamCallbacksExt.get_total_elapsed
StreamCallbacksExt.get_inference_elapsed
```

## Types

```@docs
StreamCallbacksExt.TokenCounts
StreamCallbacksExt.RunInfo
StreamCallbacksExt.StreamCallbackWithTokencounts
StreamCallbacksExt.StreamCallbackWithHooks
StreamCallbacksExt.StreamCallbackChannelWrapper
```

## Formatters

```@docs
StreamCallbacksExt.default_token_formatter
StreamCallbacksExt.compact_token_formatter
StreamCallbacksExt.default_content_formatter
StreamCallbacksExt.format_user_meta
StreamCallbacksExt.format_error_message
StreamCallbacksExt.format_info_message
StreamCallbacksExt.format_ai_meta
```

## Extractors

```@docs
StreamCallbacksExt.extract_stop_sequence
StreamCallbacksExt.extract_tokens
StreamCallbacksExt.extract_model
```

## Token Handlers

```@docs
StreamCallbacksExt.handle_token_metadata(::StreamCallbacks.OpenAIStream, ::Any, ::Any, ::Any, ::Any)
StreamCallbacksExt.handle_token_metadata(::StreamCallbacks.AnthropicStream, ::Any, ::Any, ::Any, ::Any)
StreamCallbacksExt.handle_token_metadata(::StreamCallbacks.AbstractStreamFlavor, ::Any, ::Any, ::Any, ::Any)
```

## Cost Calculations

```@docs
StreamCallbacksExt.get_cost(::StreamCallbacks.AnthropicStream, ::String, ::TokenCounts)
StreamCallbacksExt.get_cost(::StreamCallbacks.OpenAIStream, ::String, ::TokenCounts)
StreamCallbacksExt.calculate_cost
```

## Callbacks

```@docs
StreamCallbacks.callback(::StreamCallbackWithTokencounts, ::StreamCallbacks.StreamChunk)
StreamCallbacks.callback(::StreamCallbackChannelWrapper, ::StreamCallbacks.StreamChunk)
```

