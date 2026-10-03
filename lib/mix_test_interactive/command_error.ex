defmodule MixTestInteractive.CommandError do
  @moduledoc false
  defexception [:message]

  @type t :: %__MODULE__{
          message: String.t()
        }

  def exception(other) when is_exception(other) do
    exception(Exception.message(other))
  end

  def exception(opts), do: super(opts)
end
