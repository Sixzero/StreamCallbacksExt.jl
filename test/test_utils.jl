using StreamCallbacks
using JSON3

"""
    create_json_streamchunk(; json, event=nothing)

Helper function to create StreamChunk objects for testing.

# Arguments
- `json`: Dictionary to be converted to JSON
- `event`: Optional event type (e.g., :message_start, :message_stop)

# Example
```julia
chunk = create_json_streamchunk(
    json = Dict(:type => "message_start"),
    event = :message_start
)
```
"""
function create_json_streamchunk(; json, event=nothing)
    StreamChunk(
        event = event,
        data = "",  # Empty string as default data
        json = JSON3.read(JSON3.write(json))
    )
end

# Export for use in tests
export create_json_streamchunk
