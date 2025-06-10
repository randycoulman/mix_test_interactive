# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/randycoulman/mix_test_interactive/compare/v5.0.0...HEAD)

## [v5.0.0](https://github.com/randycoulman/mix_test_interactive/compare/v4.3.0...v5.0.0) - 2025-06-09

### 💥 BREAKING CHANGE 💥

- This release drops support for Elixir 1.13. We officially support the
  [same versions as Elixir itself](https://hexdocs.pm/elixir/compatibility-and-deprecations.html),
  so support for Elixir 1.13 is no longer provided. ([#137](https://github.com/randycoulman/mix_test_interactive/pull/137))

There are no actual breaking changes in the code itself, so as long as you're on
Elixir 1.14 or later, you should have no problems upgrading to this version.

### Updated

- We address new deprecations and compiler warnings in Elixir 1.19. There are no
  user-visible changes.
  ([#137](https://github.com/randycoulman/mix_test_interactive/pull/137) -
  Thanks [@frankdugan3](https://github.com/frankdugan3) for contributing to the fixes!)

- We upgrade to the newest version of `ex_docs` to get the latest improvements.
  ([#137](https://github.com/randycoulman/mix_test_interactive/pull/137))

## [v4.3.0](https://github.com/randycoulman/mix_test_interactive/compare/v4.2.0...v4.3.0) - 2025-03-21

### Added

- Add a new `verbose` configuration setting and command-line option, disabled by default. When enabled, `mix test.interactive` will print the command it is about to run just before running the tests. ([#135](https://github.com/randycoulman/mix_test_interactive/pull/135))

## [v4.2.0](https://github.com/randycoulman/mix_test_interactive/compare/v4.1.2...v4.2.0) - 2025-03-19

### Fixed

- On Unix-like system we no longer start the client application prematurely. Previously, we'd run (essentially) `mix do run -e 'Application.put_env(:elixir, :ansi_enabled, true)', test` in order to enable ANSI control codes/colors when running tests. However, `mix run` by default starts the application. Normally this would be fine, but in some cases it can cause problems. We now use `mix do eval 'Application.put_env(:elixir, :ansi_enabled, true)', test` instead, which delays starting the application until the `mix test` task runs. ([#132](https://github.com/randycoulman/mix_test_interactive/pull/132))

- Properly handle the `--no-start` option to `mix test` on Unix-like systems. Previously, we were using that option for the `mix run -e` command we were using to enable ANSI output, but not passing it through to `mix test` itself. ([#132](https://github.com/randycoulman/mix_test_interactive/pull/132))

### Added

- We make the use of ANSI control code output configurable by adding the `--(no-)ansi-enabled` command-line option and `ansi_enabled` configuration setting. Previously, we'd enable ANSI output automatically on Unix-like systems and not on Windows. This is still the default, but now Windows users can opt into ANSI output. Since Windows 10, ANSI support has been available if the [appropriate registry key is set](https://hexdocs.pm/elixir/IO.ANSI.html). Additional, users on Unix-like systems can opt out of ANSI output if desired. ([#133](https://github.com/randycoulman/mix_test_interactive/pull/133))

## [v4.1.2](https://github.com/randycoulman/mix_test_interactive/compare/v4.1.1...v4.1.2) - 2024-12-14

### Updated

- Update README with instructions for running `mix test.interactive` as an independent script that doesn't require installing as a dependency in your application. ([#127](https://github.com/randycoulman/mix_test_interactive/pull/127) - Thanks [@andyl](https://github.com/andyl)!)

- Allow process_tree versions v0.1.3 and v0.2.0 to provide more flexibility for upstream projects ([#128](https://github.com/randycoulman/mix_test_interactive/pull/128))

## [v4.1.1](https://github.com/randycoulman/mix_test_interactive/compare/v4.1.0...v4.1.1) - 2024-09-28

### Fixed

- Properly handle `mix test.interactive <files_or_patterns...>` case. The new command-line parsing added in v4.0 was not properly capturing the filenames/patterns and passing them on to `mix test`. ([#123](https://github.com/randycoulman/mix_test_interactive/pull/123) - Thanks [@jfpedroza](https://github.com/jfpedroza) for finding and reporting the bug!)

## [v4.1.0](https://github.com/randycoulman/mix_test_interactive/compare/v4.0.0...v4.1.0) - 2024-09-21

### Added

- This version adds a number of new commands for controlling additional `mix test` options interactively:

  - `d <seed>`/`d`: Set or clear the seed to use when running tests (`mix test --seed <seed>`). ([#112](https://github.com/randycoulman/mix_test_interactive/pull/112))
  - `i <tags...>`/`i`: Set or clear tags to include (`mix test --include <tag1> --include <tag2>...`). ([#113](https://github.com/randycoulman/mix_test_interactive/pull/113))
  - `o <tags...>`/`o`: Set or clear "only" tags (`mix test --only <tag1> --only <tag2>...`). ([#113](https://github.com/randycoulman/mix_test_interactive/pull/113))
  - `x <tags...>`/`x`: Set or clear tags to exclude (`mix test --exclude <tag1> --exclude <tag2>...`). ([#113](https://github.com/randycoulman/mix_test_interactive/pull/113))
  - `m <max>`/`m`: Set or clear the maximum number of failures to allow (`mix test --max-failures <max>`). ([#116](https://github.com/randycoulman/mix_test_interactive/pull/116))
  - `r <count>/`/`r`: Set or clear the maximum number of repeated runs until a test failure (`mix test --repeat-until-failure <count>`). **NOTE:** `mix test` only supports this option in v1.17.0 and later. ([#118](https://github.com/randycoulman/mix_test_interactive/pull/118))
  - `t`: Toggle test tracing on/off (`mix test --trace`). ([#117](https://github.com/randycoulman/mix_test_interactive/pull/112))

- There is now a `MixTestInteractive.TestRunner` behaviour for use in custom test runners. Up until now, custom test runners needed to implement a single `run/2` function. This release adds a behaviour that custom test runners can implement to ensure that they've correctly conformed to the interface. Custom test runners don't have to explicitly implement the behaviour, but must implicitly do so as before. ([#115](https://github.com/randycoulman/mix_test_interactive/pull/115))

## [v4.0.0](https://github.com/randycoulman/mix_test_interactive/compare/v3.2.1...v4.0.0) - 2024-09-13

### 💥 BREAKING CHANGE 💥

This version introduces the option of "config-less" operation. All configuration settings can now be supplied on the command-line instead. To avoid confusion and clashes with `mix test`'s command-line options, it is now necessary to separate `mix test.interactive`'s options from `mix test`'s options with `--` separator.

For example, to use the new `--clear` option as well as `mix test`'s `--stale` option, it is necessary to use:

```shell
mix test.interactive --clear -- --stale
```

This affects two of the command-line options that were available in previous versions:

- `mix test.interactive`'s `--no-watch` flag. Previously, you could run (for example) `mix test.interactive --no-watch --stale`. This will no longer work. You must now use `mix test.interactive --no-watch -- --stale` instead.
- `mix test`'s `--exclude` option. `mix test.interactive` now has its own `--exclude` option. Previously, you could run (for example) `mix test.interactive --exclude some_test_tag` and that argument would be forwarded on to `mix test`. Now you must use `mix test.interactive -- --exclude some_test_tag` instead.

If you don't use either of these two options, everything should work as before.

To upgrade to this version, you'll need to update any `mix` aliases or other scripts you may have defined for `mix test.interactive`. In addition, you and everyone who works in your codebase will need to update any shell aliases they have defined.

### Added

- This version introduces the option of "config-less" operation. All configuration settings can now be supplied on the command-line instead. See the [README](https://github.com/randycoulman/mix_test_interactive/blob/main/README.md) or run `mix help test.interactive` for more information. Also, see the `💥 BREAKING CHANGE 💥` section above. ([#108](https://github.com/randycoulman/mix_test_interactive/pull/108))

### Changed

- The `Running tests...` message that `mix test.interactive` displays before each test run is displayed in color. This makes it easier to find the most recent test run when scrolling back in your shell. ([#109](https://github.com/randycoulman/mix_test_interactive/pull/109))

## [v3.2.1](https://github.com/randycoulman/mix_test_interactive/compare/v3.2.0...v3.2.1) - 2024-09-07

### Fixed

- Fixed handling of custom `command`/`args` on Unix-like systems. `mix_test_interactive` was not correctly ordering the various arguments. ([#105](https://github.com/randycoulman/mix_test_interactive/pull/105) - Thanks [@callmiy](https://github.com/callmiy)!)

## [v3.2.0](https://github.com/randycoulman/mix_test_interactive/compare/v3.1.0...v3.2.0) - 2024-08-24

### Changed

- Made pattern matching more flexible. Previously, when given multiple patterns, we would not do any file filtering if any of the patterns was a `file:line`-style pattern. Instead, we'd pass all of the patterns to `mix test` literally. Now, we run normal file filtering for any non-`file:line`-style patterns and concatenate the results with any `file:line`-style patterns. ([#99](https://github.com/randycoulman/mix_test_interactive/pull/99))
- Added documentation for missing configuration options in the mix task's module documentation. ([#100](https://github.com/randycoulman/mix_test_interactive/pull/100))

## [v3.1.0](https://github.com/randycoulman/mix_test_interactive/compare/v3.0.0...v3.1.0) - 2024-08-24

### Added

- Add a new `command` configuration option that allows use of a custom command instead of `mix` for running tests. See the [README](https://github.com/randycoulman/mix_test_interactive#command-use-a-custom-command) for more details. ([#96](https://github.com/randycoulman/mix_test_interactive/pull/96))

### Changed

- Added [documentation for missing configuration options](https://github.com/randycoulman/mix_test_interactive#configuration) in the README. ([#96](https://github.com/randycoulman/mix_test_interactive/pull/96))

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

### Changed

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
