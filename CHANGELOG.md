# Changelog

All notable changes to this project will be documented in this file.

## [0.3.1] - 2024-12-13

### Added
- Added timeout handling for channel callback tests
- Added costly tests directory with README and manual API tests
- Added StreamCallbackChannelWrapper to API documentation

### Changed
- Reordered OpenAI stop sequence extraction to prioritize finish_reason over delta.stop_sequence
- Improved test organization with separate stop sequence tests
- Added failfast option to test suite

## [0.3.0] - 2024-12-13

### Changed
- Reordered callback processing in `StreamCallbackWithHooks` to handle content before token metadata
- Fixed Anthropic stop sequence extraction to properly handle delta structure

## [0.2.0] - 2024-12-12

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

## [0.1.0] - 2024-12-09

### Added
- Initial release
- Basic token counting functionality
- Support for OpenAI and Anthropic stream formats
- Token cost calculation
- Basic timing utilities
