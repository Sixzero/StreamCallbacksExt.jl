var documenterSearchIndex = {"docs":
[{"location":"api/#API-Reference","page":"API Reference","title":"API Reference","text":"","category":"section"},{"location":"api/","page":"API Reference","title":"API Reference","text":"using StreamCallbacksExt","category":"page"},{"location":"api/#Timing-Utilities","page":"API Reference","title":"Timing Utilities","text":"","category":"section"},{"location":"api/","page":"API Reference","title":"API Reference","text":"StreamCallbacksExt.get_total_elapsed\nStreamCallbacksExt.get_inference_elapsed","category":"page"},{"location":"api/#StreamCallbacksExt.get_total_elapsed","page":"API Reference","title":"StreamCallbacksExt.get_total_elapsed","text":"get_total_elapsed(info::RunInfo)\n\nGet total elapsed time since callback creation. Returns time in seconds or nothing if no messages received.\n\n\n\n\n\n","category":"function"},{"location":"api/#StreamCallbacksExt.get_inference_elapsed","page":"API Reference","title":"StreamCallbacksExt.get_inference_elapsed","text":"get_inference_elapsed(info::RunInfo)\n\nGet elapsed time for inference (time between first inference and last message). Returns time in seconds or nothing if inference hasn't started.\n\n\n\n\n\n","category":"function"},{"location":"api/#Types","page":"API Reference","title":"Types","text":"","category":"section"},{"location":"api/","page":"API Reference","title":"API Reference","text":"StreamCallbacksExt.TokenCounts\nStreamCallbacksExt.RunInfo\nStreamCallbacksExt.StreamCallbackWithTokencounts\nStreamCallbacksExt.StreamCallbackWithHooks\nStreamCallbacksExt.StreamCallbackChannelWrapper","category":"page"},{"location":"api/#StreamCallbacksExt.TokenCounts","page":"API Reference","title":"StreamCallbacksExt.TokenCounts","text":"TokenCounts(; input=0, output=0, cache_write=0, cache_read=0)\n\nTracks token usage across different categories:\n\ninput: Number of new tokens in prompt (excluding cached tokens)\noutput: Number of generated tokens in response\ncache_write: Number of tokens written to cache\ncache_read: Number of tokens read from cache\n\nNote: Total input tokens = input + cachewrite + cacheread\n\n\n\n\n\n","category":"type"},{"location":"api/#StreamCallbacksExt.RunInfo","page":"API Reference","title":"StreamCallbacksExt.RunInfo","text":"RunInfo(; creation_time=time(), inference_start=nothing, last_message_time=nothing, stop_sequence=nothing)\n\nTracks run statistics and metadata during the streaming process.\n\nFields\n\ncreation_time: When the callback was created\ninference_start: When the model started processing\nlast_message_time: Timestamp of the last received message\nstop_sequence: The sequence that caused the generation to stop (if any). For OpenAI this can be:\nA specific stop sequence provided in the chunk's delta.stop_sequence\n\"stop\" if finish_reason is \"stop\"\nFor Anthropic this is the stop_sequence provided in the chunk.\n\nTiming Methods\n\nget_total_elapsed(info): Get total elapsed time since callback creation\nget_inference_elapsed(info): Get elapsed time for inference phase only\n\n\n\n\n\n","category":"type"},{"location":"api/#StreamCallbacksExt.StreamCallbackWithTokencounts","page":"API Reference","title":"StreamCallbacksExt.StreamCallbackWithTokencounts","text":"StreamCallbackWithTokencounts(; \n    out=stdout, \n    flavor=nothing, \n    chunks=StreamChunk[], \n    verbose=false,\n    throw_on_error=false,\n    kwargs=NamedTuple(),\n    total_tokens=TokenCounts(),\n    model=nothing,\n    token_formatter=default_token_formatter,\n    content_formatter=default_content_formatter,\n    timing=RunInfo()\n)\n\nA stream callback that tracks token usage, costs, and timing information.\n\nArguments\n\nout: Output IO stream (default: stdout)\nflavor: Stream format handler (OpenAI/Anthropic)\nchunks: Vector to store stream chunks\nverbose: Enable verbose logging\nthrow_on_error: Whether to throw errors\nkwargs: Additional keyword arguments\ntotal_tokens: Accumulated token counts\nmodel: Model identifier\ntoken_formatter: Function to format token statistics\ncontent_formatter: Function to format streamed content\ntiming: Timing information\n\nExample\n\ncb = StreamCallbackWithTokencounts(     out = stdout,     flavor = StreamCallbacks.OpenAIStream() )\n\n\n\n\n\n","category":"type"},{"location":"api/#StreamCallbacksExt.StreamCallbackWithHooks","page":"API Reference","title":"StreamCallbacksExt.StreamCallbackWithHooks","text":"StreamCallbackWithHooks(; kwargs...)\n\nA stream callback that combines token counting with customizable hooks for various events.\n\nFields\n\nout: Output IO stream (default: stdout)\nflavor: Stream format handler (OpenAI/Anthropic)\nchunks: Vector to store stream chunks\nverbose: Enable verbose logging\nthrow_on_error: Whether to throw errors\nkwargs: Additional keyword arguments\ntotal_tokens: Accumulated token counts\nmodel: Model identifier\ntoken_formatter: Function to format token statistics\ntiming: Timing information\n\nHooks\n\ncontent_formatter: Function to process and format content text\non_meta_usr: Handler for user token counts/metadata\non_meta_ai: Handler for AI token counts/metadata\non_error: Error handler\non_done: Completion handler\non_start: Start handler\n\nExample\n\ncb = StreamCallbackWithHooks(\n    on_meta_ai = (tokens, cost, elapsed) -> println(\"AI: $(tokens.output) tokens\")\n)\n\n\n\n\n\n","category":"type"},{"location":"api/#StreamCallbacksExt.StreamCallbackChannelWrapper","page":"API Reference","title":"StreamCallbacksExt.StreamCallbackChannelWrapper","text":"StreamCallbackChannelWrapper(callback::StreamCallbackWithHooks; buffer_size=32)\n\nA wrapper that processes stream chunks through a channel, providing isolated error handling and shallow async processing. This results in cleaner stacktraces when errors occur, as the async processing is only one level deep.\n\nFields\n\ncallback: The wrapped StreamCallbackWithHooks instance\nchannel: Channel for async chunk processing\ntask: Async task handling the processing loop\n\nExample\n\ninner_cb = StreamCallbackWithHooks(on_error = e -> @warn(\"Error: $e\"))\ncb = StreamCallbackChannelWrapper(inner_cb)\n\n# Use with aigenerate\nmsg = aigenerate(\"Your prompt\"; streamcallback=cb)\n\nError Handling\n\nWhen an error occurs in the wrapped callback, it will be caught and handled within the async task, resulting in a much shorter stacktrace that doesn't include the full HTTP/stream processing chain. This makes debugging easier as you only see the relevant error context.\n\n\n\n\n\n","category":"type"},{"location":"api/#Formatters","page":"API Reference","title":"Formatters","text":"","category":"section"},{"location":"api/","page":"API Reference","title":"API Reference","text":"StreamCallbacksExt.default_token_formatter\nStreamCallbacksExt.compact_token_formatter\nStreamCallbacksExt.default_content_formatter\nStreamCallbacksExt.format_user_message\nStreamCallbacksExt.format_error_message\nStreamCallbacksExt.format_info_message\nStreamCallbacksExt.format_ai_message","category":"page"},{"location":"api/#StreamCallbacksExt.default_token_formatter","page":"API Reference","title":"StreamCallbacksExt.default_token_formatter","text":"default_token_formatter(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing)\n\nFormat token statistics in a default text format: [in=X, out=Y, cache_in=Z, cache_read=W, $C, Ts]\n\n\n\n\n\n","category":"function"},{"location":"api/#StreamCallbacksExt.compact_token_formatter","page":"API Reference","title":"StreamCallbacksExt.compact_token_formatter","text":"compact_token_formatter(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing)\n\nFormat token statistics in a compact, emoji-decorated format: [🔤 in:X out:Y cache:(w:Z,r:W) 💰$C ⚡️Ts]\n\n\n\n\n\n","category":"function"},{"location":"api/#StreamCallbacksExt.default_content_formatter","page":"API Reference","title":"StreamCallbacksExt.default_content_formatter","text":"default_content_formatter(text::AbstractString)\n\nDefault content formatter that returns the text unchanged.\n\n\n\n\n\n","category":"function"},{"location":"api/#StreamCallbacksExt.format_user_message","page":"API Reference","title":"StreamCallbacksExt.format_user_message","text":"format_user_message(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing) -> String\n\nFormat user message with token counts in green color, including token statistics and optional timing.\n\n\n\n\n\n","category":"function"},{"location":"api/#StreamCallbacksExt.format_error_message","page":"API Reference","title":"StreamCallbacksExt.format_error_message","text":"format_error_message(e) -> String\n\nFormat error message in red color.\n\n\n\n\n\n","category":"function"},{"location":"api/#StreamCallbacksExt.format_info_message","page":"API Reference","title":"StreamCallbacksExt.format_info_message","text":"format_info_message(msg) -> String\n\nFormat info messages in blue color.\n\n\n\n\n\n","category":"function"},{"location":"api/#StreamCallbacksExt.format_ai_message","page":"API Reference","title":"StreamCallbacksExt.format_ai_message","text":"format_ai_message(tokens::TokenCounts, cost::Float64, elapsed::Union{Float64,Nothing}=nothing) -> String\n\nFormat AI message with token counts in green color, including output tokens, cost and optional timing.\n\n\n\n\n\n","category":"function"},{"location":"api/#Extractors","page":"API Reference","title":"Extractors","text":"","category":"section"},{"location":"api/","page":"API Reference","title":"API Reference","text":"StreamCallbacksExt.extract_stop_sequence\nStreamCallbacksExt.extract_tokens\nStreamCallbacksExt.extract_model","category":"page"},{"location":"api/#StreamCallbacksExt.extract_stop_sequence","page":"API Reference","title":"StreamCallbacksExt.extract_stop_sequence","text":"extract_stop_sequence(::StreamCallbacks.AbstractStreamFlavor, chunk::StreamCallbacks.AbstractStreamChunk)\n\nDefault stop sequence extractor that returns nothing.\n\n\n\n\n\nextract_stop_sequence(::StreamCallbacks.OpenAIStream, chunk::StreamCallbacks.AbstractStreamChunk)\n\nExtract stop sequence from OpenAI stream chunks. Handles both delta.stopsequence and finishreason=\"stop\".\n\n\n\n\n\nextract_stop_sequence(::StreamCallbacks.AnthropicStream, chunk::StreamCallbacks.AbstractStreamChunk)\n\nExtract stop sequence from Anthropic stream chunks.\n\n\n\n\n\n","category":"function"},{"location":"api/#StreamCallbacksExt.extract_tokens","page":"API Reference","title":"StreamCallbacksExt.extract_tokens","text":"extract_tokens(::StreamCallbacks.AbstractStreamFlavor, chunk::StreamCallbacks.AbstractStreamChunk)\n\nDefault token extractor that warns about unimplemented flavors.\n\n\n\n\n\nextract_tokens(::StreamCallbacks.AnthropicStream, chunk::StreamCallbacks.AbstractStreamChunk)\n\nExtract token counts from Anthropic stream chunks. Handles both message_start events with usage information and completion events with output tokens.\n\n\n\n\n\nextract_tokens(::StreamCallbacks.OpenAIStream, chunk::StreamCallbacks.AbstractStreamChunk)\n\nExtract token counts from OpenAI stream chunks. Handles:\n\nLegacy format with prompttokens and completiontokens\nCache hit/miss statistics\nDetailed token breakdowns (cachedtokens, audiotokens)\nEnd-of-stream combined usage statistics\n\n\n\n\n\n","category":"function"},{"location":"api/#StreamCallbacksExt.extract_model","page":"API Reference","title":"StreamCallbacksExt.extract_model","text":"extract_model(::StreamCallbacks.OpenAIStream, chunk::StreamCallbacks.AbstractStreamChunk)\n\nExtract model identifier from OpenAI stream chunks.\n\n\n\n\n\nextract_model(::StreamCallbacks.AnthropicStream, chunk::StreamCallbacks.AbstractStreamChunk)\n\nExtract model identifier from Anthropic stream chunks, specifically from message_start events.\n\n\n\n\n\nextract_model(::StreamCallbacks.AbstractStreamFlavor, chunk::StreamCallbacks.AbstractStreamChunk)\n\nDefault model extractor that warns about unimplemented flavors.\n\n\n\n\n\n","category":"function"},{"location":"api/#Token-Handlers","page":"API Reference","title":"Token Handlers","text":"","category":"section"},{"location":"api/","page":"API Reference","title":"API Reference","text":"StreamCallbacksExt.handle_token_metadata(::StreamCallbacks.OpenAIStream, ::Any, ::Any, ::Any, ::Any)\nStreamCallbacksExt.handle_token_metadata(::StreamCallbacks.AnthropicStream, ::Any, ::Any, ::Any, ::Any)\nStreamCallbacksExt.handle_token_metadata(::StreamCallbacks.AbstractStreamFlavor, ::Any, ::Any, ::Any, ::Any)","category":"page"},{"location":"api/#StreamCallbacksExt.handle_token_metadata-Tuple{OpenAIStream, Vararg{Any, 4}}","page":"API Reference","title":"StreamCallbacksExt.handle_token_metadata","text":"handle_token_metadata(::StreamCallbacks.OpenAIStream, cb, tokens, cost, elapsed)\n\nHandle token metadata for OpenAI streams by calling both user and AI handlers. All metadata is sent at once, so both handlers are called sequentially.\n\n\n\n\n\n","category":"method"},{"location":"api/#StreamCallbacksExt.handle_token_metadata-Tuple{AnthropicStream, Vararg{Any, 4}}","page":"API Reference","title":"StreamCallbacksExt.handle_token_metadata","text":"Handle token metadata for Anthropic streams by dispatching based on token type. Dispatches to user or AI handler based on whether output tokens are present.\n\n\n\n\n\n","category":"method"},{"location":"api/#StreamCallbacksExt.handle_token_metadata-Tuple{StreamCallbacks.AbstractStreamFlavor, Vararg{Any, 4}}","page":"API Reference","title":"StreamCallbacksExt.handle_token_metadata","text":"Default token metadata handler for other stream flavors.\n\n\n\n\n\n","category":"method"},{"location":"api/#Cost-Calculations","page":"API Reference","title":"Cost Calculations","text":"","category":"section"},{"location":"api/","page":"API Reference","title":"API Reference","text":"StreamCallbacksExt.get_cost(::StreamCallbacks.AnthropicStream, ::String, ::TokenCounts)\nStreamCallbacksExt.get_cost(::StreamCallbacks.OpenAIStream, ::String, ::TokenCounts)\nStreamCallbacksExt.calculate_cost","category":"page"},{"location":"api/#StreamCallbacksExt.get_cost-Tuple{AnthropicStream, String, TokenCounts}","page":"API Reference","title":"StreamCallbacksExt.get_cost","text":"get_cost(::StreamCallbacks.AnthropicStream, model::String, tokens::TokenCounts)\n\nCalculate costs for Anthropic models with their specific cache multipliers.\n\n\n\n\n\n","category":"method"},{"location":"api/#StreamCallbacksExt.get_cost-Tuple{OpenAIStream, String, TokenCounts}","page":"API Reference","title":"StreamCallbacksExt.get_cost","text":"get_cost(::StreamCallbacks.OpenAIStream, model::String, tokens::TokenCounts)\n\nCalculate costs for OpenAI models with their specific cache multipliers.\n\n\n\n\n\n","category":"method"},{"location":"api/#StreamCallbacksExt.calculate_cost","page":"API Reference","title":"StreamCallbacksExt.calculate_cost","text":"calculate_cost(cost_of_token_prompt::Real, cost_of_token_generation::Real,\n              tokens::TokenCounts, cache_write_multiplier::Real, cache_read_multiplier::Real)\n\nCalculate the total cost for token usage based on the provided rates and multipliers.\n\n\n\n\n\n","category":"function"},{"location":"api/#Callbacks","page":"API Reference","title":"Callbacks","text":"","category":"section"},{"location":"api/","page":"API Reference","title":"API Reference","text":"StreamCallbacks.callback(::StreamCallbackWithTokencounts, ::StreamCallbacks.StreamChunk)\nStreamCallbacks.callback(::StreamCallbackChannelWrapper, ::StreamCallbacks.StreamChunk)","category":"page"},{"location":"api/#StreamCallbacks.callback-Tuple{StreamCallbackWithTokencounts, StreamChunk}","page":"API Reference","title":"StreamCallbacks.callback","text":"callback(cb::StreamCallbackWithTokencounts, chunk::StreamChunk; kwargs...)\n\nProcess a stream chunk through the token-counting callback. This implementation:\n\nTracks timing information for inference\nExtracts and accumulates token counts\nCalculates costs based on model and token usage\nFormats and prints token statistics and content\n\nReturns a Dict with token counts if token information is available in the chunk.\n\n\n\n\n\n","category":"method"},{"location":"api/#StreamCallbacks.callback-Tuple{StreamCallbackChannelWrapper, StreamChunk}","page":"API Reference","title":"StreamCallbacks.callback","text":"StreamCallbacks.callback(cb::StreamCallbackChannelWrapper, chunk::StreamChunk; kwargs...)\n\nProcess stream chunks through a channel-based async loop with isolated error handling.\n\n\n\n\n\n","category":"method"},{"location":"#StreamCallbacksExt.jl","page":"Home","title":"StreamCallbacksExt.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for StreamCallbacksExt.jl.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Extension package for StreamCallbacks.jl with 3 things in mind:","category":"page"},{"location":"","page":"Home","title":"Home","text":"Instant feedback as soon as usage package comes in.\nCached token informations\nCached token costs","category":"page"},{"location":"","page":"Home","title":"Home","text":"also adding timing for prompt processing time and inference time. Primarily designed to extend streaming capabilities in PromptingTools.jl.","category":"page"},{"location":"","page":"Home","title":"Home","text":"For detailed API documentation, see the API Reference.","category":"page"},{"location":"#Features","page":"Home","title":"Features","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Token counting for input, output, and cache operations\nCost calculation for different LLM providers (OpenAI, Anthropic)\nTiming information for inference and message processing\nCustomizable token and content formatters\nSupport for different stream flavors (OpenAI, Anthropic)\nFlexible hook system for customizing callback behavior\nChannel-based async processing for cleaner stacktraces","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"using Pkg\nPkg.add(\"git@github.com:Sixzero/StreamCallbacksExt.jl.git\")","category":"page"},{"location":"#Basic-Usage","page":"Home","title":"Basic Usage","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"using PromptingTools, StreamCallbacks, StreamCallbacksExt\nconst PT = PromptingTools\n\n# Basic streaming with token counting\ncb = StreamCallbackWithTokencounts(\n    out = stdout,  # or any IO\n    flavor = StreamCallbacks.OpenAIStream(),\n)\nmsg = aigenerate(\"Write a story about a space cat\";\n    streamcallback=cb,\n    model=\"gpt4om\",\n    api_kwargs=(stream=true,)\n)\n\n# Using hooks for custom behavior\ncb = StreamCallbackWithHooks(\n    content_formatter = text -> \"AI: $text\",\n    on_meta_usr = (tokens, cost, elapsed) -> \"User tokens: $(tokens.input)\",\n    on_meta_ai = (tokens, cost, elapsed) -> \"AI tokens: $(tokens.output)\",\n    on_error = e -> \"Error: $e\",\n    on_done = () -> \"Generation complete!\"\n)\n\n# Using channel wrapper for cleaner stacktraces\ncb = StreamCallbackChannelWrapper(\n    callback = StreamCallbackWithHooks(\n        on_error = e -> @warn(\"Error: $e\")\n    )\n)","category":"page"},{"location":"#Token-Formatters","page":"Home","title":"Token Formatters","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Two built-in formatters are provided:","category":"page"},{"location":"#Default-Text-Format","page":"Home","title":"Default Text Format","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"cb = StreamCallbackWithTokencounts(\n    flavor = StreamCallbacks.OpenAIStream(),\n    token_formatter = default_token_formatter\n)\n# [in=10, out=20, cache_in=2, cache_read=5, $0.0015, 1.234s]","category":"page"},{"location":"#Compact-Emoji-Format","page":"Home","title":"Compact Emoji Format","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"cb = StreamCallbackWithTokencounts(\n    flavor = StreamCallbacks.OpenAIStream(),\n    token_formatter = compact_token_formatter\n)\n# [🔤 in:10 out:20 cache:(w:2,r:5) 💰$0.0015 ⚡️1.234s]","category":"page"},{"location":"#Custom-Formatter","page":"Home","title":"Custom Formatter","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"# Create your own formatter\nmy_formatter(tokens, cost, elapsed) = \"Words: \\$(tokens.output/1.3) Cost: \\\\\\$\\$(round(cost; digits=4))\"\ncb = StreamCallbackWithTokencounts(\n    flavor = StreamCallbacks.OpenAIStream(),\n    token_formatter = my_formatter\n)","category":"page"},{"location":"#Dependencies","page":"Home","title":"Dependencies","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"StreamCallbacks.jl\nPromptingTools.jl","category":"page"}]
}
