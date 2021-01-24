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
      {:ok, args} = Config.cli_args(config)
      assert args == ["hello", "world"]
    end

    test "passes no arguments by default" do
      config = Config.new()
      {:ok, args} = Config.cli_args(config)
      assert args == []
    end

    test "initializes stale flag from arguments" do
      config = Config.new(["hello", "--stale", "world"])
      assert config.stale?
      assert config.initial_cli_args == ["hello", "world"]
    end

    test "initializes failed flag from arguments" do
      config = Config.new(["hello", "--failed", "world"])
      assert config.failed?
      assert config.initial_cli_args == ["hello", "world"]
    end
  end

  describe "filtering tests" do
    test "filters to files matching patterns" do
      all_files = ~w(file1 file2 no_match other)

      config =
        Config.new(["provided"])
        |> with_fake_file_list(all_files)
        |> Config.only_patterns(["file", "other"])

      {:ok, args} = Config.cli_args(config)
      assert args == ["provided", "file1", "file2", "other"]
    end

    test "returns error if no files match pattern" do
      config =
        Config.new()
        |> with_fake_file_list([])
        |> Config.only_patterns(["file"])

      assert {:error, :no_matching_files} = Config.cli_args(config)
    end

    test "restricts to failed tests" do
      config =
        Config.new(["provided"])
        |> Config.only_failed()

      {:ok, args} = Config.cli_args(config)
      assert args == ["provided", "--failed"]
    end

    test "restricts to stale tests" do
      config =
        Config.new(["provided"])
        |> Config.only_stale()

      {:ok, args} = Config.cli_args(config)
      assert args == ["provided", "--stale"]
    end

    test "pattern filter clears failed flag" do
      config =
        Config.new()
        |> with_fake_file_list(["file"])
        |> Config.only_failed()
        |> Config.only_patterns(["f"])

      {:ok, args} = Config.cli_args(config)
      assert args == ["file"]
    end

    test "pattern filter clears stale flag" do
      config =
        Config.new()
        |> with_fake_file_list(["file"])
        |> Config.only_stale()
        |> Config.only_patterns(["f"])

      {:ok, args} = Config.cli_args(config)
      assert args == ["file"]
    end

    test "failed flag clears pattern filters" do
      config =
        Config.new()
        |> Config.only_patterns(["file"])
        |> Config.only_failed()

      {:ok, args} = Config.cli_args(config)
      assert args == ["--failed"]
    end

    test "failed flag clears stale flag" do
      config =
        Config.new()
        |> Config.only_stale()
        |> Config.only_failed()

      {:ok, args} = Config.cli_args(config)
      assert args == ["--failed"]
    end

    test "stale flag clears pattern filters" do
      config =
        Config.new()
        |> Config.only_patterns(["file"])
        |> Config.only_stale()

      {:ok, args} = Config.cli_args(config)
      assert args == ["--stale"]
    end

    test "stale flag clears failed flag" do
      config =
        Config.new()
        |> Config.only_failed()
        |> Config.only_stale()

      {:ok, args} = Config.cli_args(config)
      assert args == ["--stale"]
    end

    test "all tests clears pattern filters" do
      config =
        Config.new()
        |> Config.only_patterns(["pattern"])
        |> Config.all_tests()

      {:ok, args} = Config.cli_args(config)
      assert args == []
    end

    test "all tests removes stale flag" do
      config =
        Config.new()
        |> Config.only_stale()
        |> Config.all_tests()

      {:ok, args} = Config.cli_args(config)
      assert args == []
    end

    test "all tests removes failed flag" do
      config =
        Config.new()
        |> Config.only_failed()
        |> Config.all_tests()

      {:ok, args} = Config.cli_args(config)
      assert args == []
    end

    defp with_fake_file_list(config, files) do
      config |> Config.list_files_with(fn -> files end)
    end
  end

  describe "summary" do
    test "ran all tests" do
      config = Config.new()

      assert Config.summary(config) == "Ran all tests"
    end

    test "ran failed tests" do
      config = Config.new() |> Config.only_failed()

      assert Config.summary(config) == "Ran only failed tests"
    end

    test "ran stale tests" do
      config = Config.new() |> Config.only_stale()

      assert Config.summary(config) == "Ran only stale tests"
    end

    test "ran specific patterns" do
      config = Config.new() |> Config.only_patterns(["p1", "p2"])

      assert Config.summary(config) == "Ran all test files matching p1, p2"
    end
  end
end
