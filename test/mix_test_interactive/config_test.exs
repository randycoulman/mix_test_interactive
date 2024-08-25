defmodule MixTestInteractive.ConfigTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.Config

  describe "creation" do
    test "takes :clear? from the env" do
      Process.put(:clear, true)
      config = Config.new()
      assert config.clear?
    end

    test "takes :command as a string from the env" do
      command = "/path/to/command"

      Process.put(:command, command)
      config = Config.new()
      assert config.command == {command, []}
    end

    test "takes :command as a tuple from the env" do
      command = {"command", ["arg1", "arg2"]}

      Process.put(:command, command)
      config = Config.new()
      assert config.command == command
    end

    test "raises an error if :command is invalid" do
      Process.put(:command, ["invalid_command", "arg1", "arg2"])

      assert_raise ArgumentError, fn ->
        Config.new()
      end
    end

    test "defaults :command to `{\"mix\", []}`" do
      config = Config.new()
      assert config.command == {"mix", []}
    end

    test "takes :exclude from the env" do
      Process.put(:exclude, [~r/migration_.*/])
      config = Config.new()
      assert config.exclude == [~r/migration_.*/]
    end

    test ":exclude contains common editor temp/swap files by default" do
      config = Config.new()
      # Emacs lock symlink
      assert ~r/\.#/ in config.exclude
    end

    test "excludes default Phoenix migrations directory by default" do
      config = Config.new()
      assert ~r{priv/repo/migrations} in config.exclude
    end

    test "takes :extra_extensions from the env" do
      Process.put(:extra_extensions, [".haml"])
      config = Config.new()
      assert config.extra_extensions == [".haml"]
    end

    test "takes :show_timestamps? from the env" do
      Process.put(:timestamp, true)
      config = Config.new()
      assert config.show_timestamp?
    end

    test "takes :task from the env" do
      Process.put(:task, :env_task)
      config = Config.new()
      assert config.task == :env_task
    end

    test ~s(defaults :task to "test") do
      config = Config.new()
      assert config.task == "test"
    end
  end
end
