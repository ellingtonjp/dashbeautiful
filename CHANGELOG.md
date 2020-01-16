# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [unreleased]
### Added
- More error handling when initializing Organization/Network/Device
- Many more initialization tests
### Fixed
- ArgumentError raised when initializing network with no tags


## [0.0.1] - 2019-01-16
### Added
- API class for doing HTTP requests
- Organization, Network, Device classes
- Dashboard read access via methods like name, tags, networks, devices
- Caching by default, add a '!' to force an API request
- rspec testing for Ogranization/Network/Device classes with fixtures

### Changed
- name from meraki to dashbeautiful
- version from 0.1.0 -> 0.0.1 to account for renaming and better follow semantic versioning

[Unreleased]: https://github.com/ellingtonjp/dashbeautiful/compare/v0.0.1...HEAD
[0.0.1]: https://github.com/ellingtonjp/dashbeautiful/releases/tag/v0.0.1
