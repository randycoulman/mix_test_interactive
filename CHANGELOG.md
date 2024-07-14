# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/randycoulman/mix_test_interactive/compare/v3.0.0...HEAD)

## [v3.0.0](https://github.com/randycoulman/mix_test_interactive/compare/v2.1.0...v3.0.0) - 2024-07-13

### 💥 BREAKING CHANGE 💥

- This release drops support for Elixir 1.12. We officially support the
  [same versions as Elixir
  itself](https://hexdocs.pm/elixir/1.17.2/compatibility-and-deprecations.html),
  so support for Elixir 1.12.
  ([#94](https://github.com/randycoulman/mix_test_interactive/pull/94))

There are no actual breaking changes in the code itself, so as long as you're on
Elixir 1.13 or later, you should have no problems upgrading to this version.

### Changed

- Update to the latest version of [ex_doc](https://hexdocs.pm/ex_doc/readme.html). The [documentation](https://hexdocs.pm/mix_test_interactive/readme.html) reflects these changes. ([#93](https://github.com/randycoulman/mix_test_interactive/pull/93))

## [v2.1.0](https://github.com/randycoulman/mix_test_interactive/compare/v2.0.4...v2.1.0) - 2024-07-13

### Fixed

- Fix compiler warnings on Elixir 1.17. ([#89](https://github.com/randycoulman/mix_test_interactive/pull/89) - Thanks [@jfpedroza](https://github.com/jfpedroza)!)

## [v2.0.4](https://github.com/randycoulman/mix_test_interactive/compare/v2.0.3...v2.0.4) - 2024-03-04

### Fixed

- Ignore some filesystem events emitted by inotify. Some events are triggered later than others and end up causing the tests to run twice for a single file change. ([#86](https://github.com/randycoulman/mix_test_interactive/pull/86) - Thanks
  [@jwilger](https://github.com/jwilger)!)

## [v2.0.3](https://github.com/randycoulman/mix_test_interactive/compare/v2.0.2...v2.0.3) - 2024-01-27

### Changed

- Update `file_system` dependency to allow versions 0.2 and 1.0 to avoid dependency conflicts with popular libraries like `phoenix_live_reload`. Previously, we'd specified v0.3, but there is no such version of `file_system`. ([#83](https://github.com/randycoulman/mix_test_interactive/pull/83))

## [v2.0.2](https://github.com/randycoulman/mix_test_interactive/compare/v2.0.1...v2.0.2) - 2024-01-25

### Changed

- Allow `file_system` versions 0.3 and 1.0 to avoid dependency conflicts with popular libraries like `phoenix_live_reload`. ([#81](https://github.com/randycoulman/mix_test_interactive/pull/81))

## [v2.0.1](https://github.com/randycoulman/mix_test_interactive/compare/v2.0.0...v2.0.1) - 2024-01-25

### Fixed

- Make the `styler` dependency a dev-only dependency to avoid pulling it into client projects with a potential version conflict. ([#79](https://github.com/randycoulman/mix_test_interactive/pull/79))

## [v2.0.0](https://github.com/randycoulman/mix_test_interactive/compare/v1.2.1...v2.0.0) - 2024-01-22

### 💥 BREAKING CHANGES 💥

- This release drops support for older Elixir versions. We officially support the
  [same versions as Elixir
  itself](https://hexdocs.pm/elixir/1.16.0/compatibility-and-deprecations.html),
  so support for Elixir 1.11 and prior has been dropped.
  ([#67](https://github.com/randycoulman/mix_test_interactive/pull/67),
  [#75](https://github.com/randycoulman/mix_test_interactive/pull/75))
- Upgrade [file_system](https://hex.pm/packages/file_system) dependency to
  version 1.0. This appears to be a simple bump to 1.0 with no breaking changes,
  so should be safe to upgrade to. It might break dependency resolution
  if you're locked to a pre-1.0 version, so it's noted here.
  ([#72](https://github.com/randycoulman/mix_test_interactive/pull/72) - Thanks
  [@andyl](https://github.com/andyl)!)

There are no actual breaking changes, so as long as you're on Elixir 1.12 or
later and aren't depending on a pre-1.0 version of `file_system`, you should
have no problems upgrading to this version.

### Added

- Add full task documentation. `mix help test.interactive` will now show a
  summary of usage and configuration information ([#70](https://github.com/randycoulman/mix_test_interactive/pull/70))

- Add support for newer `mix test` options ([#71](https://github.com/randycoulman/mix_test_interactive/pull/71))

## [v1.2.2](https://github.com/randycoulman/mix_test_interactive/compare/v1.2.1...v1.2.2) - 2022-11-15

No functional changes; purely administrative.

## Changed

- Migrated repository ownership from @influxdata to @randycoulman ([#60](https://github.com/randycoulman/mix_test_interactive/pull/60))

## [v1.2.1](https://github.com/randycoulman/mix_test_interactive/compare/v1.2.0...v1.2.1) - 2022-06-01

### Fixed

- Include .heex in list of watched file extensions
  ([#57](https://github.com/randycoulman/mix_test_interactive/pull/57) - Thanks @juddey!)

## [v1.2.0](https://github.com/randycoulman/mix_test_interactive/compare/v1.1.0...v1.2.0) - 2022-04-07

### Changed

- Now tested against Elixir 1.12 and 1.13. ([#55](https://github.com/randycoulman/mix_test_interactive/pull/55))
- Misc. dependency upgrades. ([#55](https://github.com/randycoulman/mix_test_interactive/pull/55))

### Documentation

- Include proper source ref in the generated documentation so that it now points at the correct version of the source code. ([#51](https://github.com/randycoulman/mix_test_interactive/pull/51) - Thanks @kianmeng!)

- Include license and changelog in generated documentation. ([#51](https://github.com/randycoulman/mix_test_interactive/pull/51) - Thanks @kianmeng!)

## [v1.1.0](https://github.com/randycoulman/mix_test_interactive/compare/v1.0.1...v1.1.0) - 2021-10-08

### Fixed

- The `p` (pattern) command now works properly in umbrella projects. Previously, it was unable to find any test files in order to filter the pattern and would therefore not run any tests. Now, in an umbrella project, `mix test.interactive` looks for test files in `apps/*/test` by default, but still respects the `:test_paths` config option used by `mix test`. ([#48](https://github.com/randycoulman/mix_test_interactive/pull/48))

### Documentation

- Fixed the spelling of Louis Pilfold's name in the README. Sorry, Louis! 🤦‍♂️ ([#49](https://github.com/randycoulman/mix_test_interactive/pull/49))

## [v1.0.1](https://github.com/randycoulman/mix_test_interactive/compare/v1.0.0...v1.0.1) - 2021-03-09

### Fixed

- Eliminates a GenServer call timeout that can occur if a command is typed while a long-running test run is in progress. ([#44](https://github.com/randycoulman/mix_test_interactive/pull/44)).

## [v1.0.0](https://github.com/randycoulman/mix_test_interactive/compare/14eb50c742a042de7bfc37c41b8af68d839eb443...v1.0.0) - 2021-02-18

🎉 Happy Birthday!

The following sections describe changes from [mix-test.watch](https://github.com/lpil/mix-test.watch), which served as the basis of this project.

### Added

- Interactive mode allows dynamically filtering test files based on a substring pattern or switching to run only failed or stale tests without having to restart.

- File-watching mode can be turned on and off, either by passing `--no-watch` on the command line, or by using the `w` command to dynamically toggle watch mode on and off. When file-watching mode is on, tests will be run in response to file changes as with `mix-test.watch`. When off, tests must be run explicitly using the `Enter` key or by using another command that changes the set of tests to be run.

### Removed

- It is no longer possible to customize the CLI executable. We always use `mix`. Previously, this allowed the use of `iex -S mix` instead, but that doesn't work well with interactive mode.

- It is no longer possible to specify multiple tasks to run on file changes. This ability added complexity and the feature didn't work very well because it assumed that all tasks would take the exact same set of command-line arguments. It is still possible to specify a different task name than `test`, but `mix test.interactive` assumes that the custom task accepts the same command-line arguments as `mix test`.

### Fixed

- On Windows, `mix test.interactive` runs the correct `mix` task, including a custom task provided in the configuration, rather than always running `mix test`. It also passes along other provided command-line arguments as well as those injected by `mix test.interactive`.
