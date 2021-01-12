defmodule MixTestInteractive.ConfigTest do
  use ExUnit.Case, async: false
  use TemporaryEnv

  alias MixTestInteractive.Config

  describe "creation" do
    test "takes :tasks from the env" do
      TemporaryEnv.put :mix_test_interactive, :tasks, :env_tasks do
        config = Config.new()
        assert config.tasks == :env_tasks
      end
    end

    test ~s(defaults :tasks to ["test"]) do
      TemporaryEnv.delete :mix_test_interactive, :tasks do
        config = Config.new()
        assert config.tasks == ["test"]
      end
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

    test "passes cli_args" do
      config = Config.new(["hello", "world"])
      assert Config.cli_args(config) == ["hello", "world"]
    end

    test "default cli_args to empty list" do
      config = Config.new()
      assert Config.cli_args(config) == []
    end

    test "takes :clear from the env" do
      TemporaryEnv.put :mix_test_interactive, :clear, true do
        config = Config.new()
        assert config.clear
      end
    end

    test "takes :timestamp from the env" do
      TemporaryEnv.put :mix_test_interactive, :timestamp, true do
        config = Config.new()
        assert config.timestamp
      end
    end

    test "takes :shell_prefix from the env" do
      TemporaryEnv.put :mix_test_interactive, :cli_executable, "iex -S" do
        config = Config.new()
        assert config.cli_executable == "iex -S"
      end
    end
  end

  describe "command line arguments" do
    test "passes on provided arguments" do
      config = Config.new(["hello", "world"])
      assert Config.cli_args(config) == ["hello", "world"]
    end

    test "passes no arguments by default" do
      config = Config.new()
      assert Config.cli_args(config) == []
    end

    test "restricts to provided files" do
      config =
        Config.new(["provided"])
        |> Config.only_files(["file1", "file2:42"])

      assert Config.cli_args(config) == ["provided", "file1", "file2:42"]
    end

    test "clears restricted files" do
      config =
        Config.new()
        |> Config.only_files(["restricted"])
        |> Config.all_files()

      assert Config.cli_args(config) == []
    end
  end
end
