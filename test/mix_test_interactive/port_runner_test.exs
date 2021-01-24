defmodule MixTestInteractive.PortRunnerTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.{Config, PortRunner}

  describe "build_task_command/1" do
    test "appends commandline arguments from passed config" do
      config = Config.new(["--exclude", "integration"])

      expected =
        "MIX_ENV=test mix do run -e " <>
          "'Application.put_env(:elixir, :ansi_enabled, true);', " <> "test --exclude integration"

      assert {:ok, ^expected} = PortRunner.build_task_command(config)
    end

    test "takes custom task from passed config" do
      config = %Config{task: "custom_task"}

      expected =
        "MIX_ENV=test mix do run -e " <>
          "'Application.put_env(:elixir, :ansi_enabled, true);', " <> "custom_task"

      assert {:ok, ^expected} = PortRunner.build_task_command(config)
    end

    test "respect no-start commandline argument from passed config" do
      config = Config.new(["--exclude", "integration", "--no-start"])

      expected =
        "MIX_ENV=test mix do run --no-start -e " <>
          "'Application.put_env(:elixir, :ansi_enabled, true);', " <>
          "test --exclude integration --no-start"

      assert {:ok, ^expected} = PortRunner.build_task_command(config)
    end
  end
end
