defmodule MixTestInteractive.ConfigTest do
  use ExUnit.Case, async: false
  use TemporaryEnv

  alias MixTestInteractive.Config

  describe "creation" do
    test "takes :clear? from the env" do
      TemporaryEnv.put :mix_test_interactive, :clear, true do
        config = Config.new()
        assert config.clear?
      end
    end

    test "takes :command as a string from the env" do
      command = "/path/to/command"

      TemporaryEnv.put :mix_test_interactive, :command, command do
        config = Config.new()
        assert config.command == {command, []}
      end
    end

    test "takes :command as a tuple from the env" do
      command = {"command", ["arg1", "arg2"]}

      TemporaryEnv.put :mix_test_interactive, :command, command do
        config = Config.new()
        assert config.command == command
      end
    end

    test "raises an error if :command is invalid" do
      TemporaryEnv.put :mix_test_interactive, :command, ["invalid_command", "arg1", "arg2"] do
        assert_raise ArgumentError, fn ->
          Config.new()
        end
      end
    end

    test "defaults :command to `{\"mix\", []}`" do
      config = Config.new()
      assert config.command == {"mix", []}
    end

    test "takes :exclude from the env" do
      TemporaryEnv.put :mix_test_interactive, :exclude, [~r/migration_.*/] do
        config = Config.new()
        assert config.exclude == [~r/migration_.*/]
      end
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
      TemporaryEnv.put :mix_test_interactive, :extra_extensions, [".haml"] do
        config = Config.new()
        assert config.extra_extensions == [".haml"]
      end
    end

    test "takes :show_timestamps? from the env" do
      TemporaryEnv.put :mix_test_interactive, :timestamp, true do
        config = Config.new()
        assert config.show_timestamp?
      end
    end

    test "takes :task from the env" do
      TemporaryEnv.put :mix_test_interactive, :task, :env_task do
        config = Config.new()
        assert config.task == :env_task
      end
    end

    test ~s(defaults :task to "test") do
      TemporaryEnv.delete :mix_test_interactive, :task do
        config = Config.new()
        assert config.task == "test"
      end
    end
  end
end
