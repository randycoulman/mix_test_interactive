defmodule MixTestInteractiveTest do
  use ExUnit.Case
  doctest MixTestInteractive

  test "greets the world" do
    assert MixTestInteractive.hello() == :world
  end
end
