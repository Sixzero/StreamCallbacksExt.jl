# Manual API Tests

This directory contains tests that require API access and cost money to run. These tests are not included in the automated test suite and should be run manually when needed.

## Running the Tests

To run the API tests:

```julia
include("test/costly_tests/stop_sequence_test.jl")
```

Note: Make sure you have valid API keys set up for both OpenAI and Anthropic before running these tests.

Required environment variables:
- `OPENAI_API_KEY` for OpenAI tests
- `ANTHROPIC_API_KEY` for Anthropic tests

## Test Coverage

- OpenAI GPT-4 stop sequence functionality
- Anthropic Claude stop sequence functionality

Each test verifies that:
1. The model stops generating when it encounters the stop sequence
2. The stop sequence is properly detected and reported
3. The callback system correctly processes the stop sequence information
