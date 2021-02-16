defmodule MixTestInteractive.MessageInbox do
  @moduledoc false

  @spec flush :: :ok
  def flush do
    receive do
      _ -> flush()
    after
      0 -> :ok
    end
  end
end
