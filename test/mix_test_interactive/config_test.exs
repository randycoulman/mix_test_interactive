defmodule MixTestInteractive.ConfigTest do
  use ExUnit.Case, async: true

  import ConfigHelpers

  alias MixTestInteractive.Config

  describe "loading from the environment" do
    test "takes :ansi_enabled? from the env" do
      Process.put(:os_type, {:unix, :darwin})
      Process.put(:ansi_enabled, false)
      config = Config.load_from_environment()
      refute config.ansi_enabled?
    end

    test "defaults :ansi_enabled? to false on Windows" do
      Process.put(:os_type, {:win32, :nt})
      config = Config.load_from_environment()
      refute config.ansi_enabled?
    end

    test "defaults :ansi_enabled? to true on other platforms" do
      Process.put(:os_type, {:unix, :darwin})
      config = Config.load_from_environment()
      assert config.ansi_enabled?
    end

    test "takes :clear? from the env" do
      Process.put(:clear, true)
      config = Config.load_from_environment()
      assert config.clear?
    end

    test "takes :command as a string from the env" do
      command = "/path/to/command"

      Process.put(:command, command)
      config = Config.load_from_environment()
      assert config.command == {command, []}
    end

    test "takes :command as a tuple from the env" do
      command = {"command", ["arg1", "arg2"]}

      Process.put(:command, command)
      config = Config.load_from_environment()
      assert config.command == command
    end

    test "raises an error if :command is invalid" do
      Process.put(:command, ["invalid_command", "arg1", "arg2"])

      assert_raise ArgumentError, fn ->
        Config.load_from_environment()
      end
    end

    test "defaults :command to `{\"mix\", []}`" do
      config = Config.load_from_environment()
      assert config.command == {"mix", []}
    end

    test "takes :exclude from the env" do
      Process.put(:exclude, [~r/migration_.*/])
      config = Config.load_from_environment()
      assert compare_regexes?(config.exclude, [~r/migration_.*/])
    end

    test ":exclude contains common editor temp/swap files by default" do
      config = Config.load_from_environment()
      # Emacs lock symlink
      assert regex_in?(~r/\.#/, config.exclude)
    end

    test "excludes default Phoenix migrations directory by default" do
      config = Config.load_from_environment()
      assert regex_in?(~r{priv/repo/migrations}, config.exclude)
    end

    test "takes :extra_extensions from the env" do
      Process.put(:extra_extensions, [".haml"])
      config = Config.load_from_environment()
      assert config.extra_extensions == [".haml"]
    end

    test "takes :show_timestamps? from the env" do
      Process.put(:timestamp, true)
      config = Config.load_from_environment()
      assert config.show_timestamp?
    end

    test "takes :task from the env" do
      Process.put(:task, :env_task)
      config = Config.load_from_environment()
      assert config.task == :env_task
    end

    test ~s(defaults :task to "test") do
      config = Config.load_from_environment()
      assert config.task == "test"
    end

    test "takes :verbose from the env" do
      Process.put(:verbose, true)
      config = Config.load_from_environment()
      assert config.verbose?
    end

    test "defaults verbose to false" do
      config = Config.load_from_environment()
      refute config.verbose?
    end
  end
end
