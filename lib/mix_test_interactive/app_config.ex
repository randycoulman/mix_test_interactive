defmodule MixTestInteractive.AppConfig do
  @moduledoc false

  @type key :: Application.key()
  @type value :: Application.value()

  @application :mix_test_interactive

  @spec get(key()) :: value()
  @spec get(key(), value()) :: value()
  def get(key, default \\ nil) do
    from_app_env = Application.get_env(@application, key, default)
    ProcessTree.get(key, default: from_app_env)
  end
end
