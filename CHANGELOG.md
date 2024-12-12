# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0] - 2024-03-14

### Added
- New `StreamCallbackWithHooks` struct for flexible callback customization with hooks
- New `StreamCallbackChannelWrapper` for handling async processing with cleaner error handling
- Support for stop sequence detection and handling
- Improved token metadata handling with flavor-specific dispatching

### Changed
- Moved callback implementations to separate `callbacks.jl` file for better code organization
- Renamed `timing` field to `run_info` in callback structs for clarity
- Enhanced error handling and metadata processing in stream callbacks

### Fixed
- Better handling of stream chunk processing errors
- Improved token counting accuracy with cache handling

## [0.1.0] - 2024-03-01

### Added
- Initial release
- Basic token counting functionality
- Support for OpenAI and Anthropic stream formats
- Token cost calculation
- Basic timing utilities
