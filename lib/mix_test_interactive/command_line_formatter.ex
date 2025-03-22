defmodule MixTestInteractive.CommandLineFormatter do
  @moduledoc false

  @special_chars ~r/[\s&|;<>*?()\[\]{}$`'"]/
  @whitespace ~r/\s/

  def call(command, args) do
    Enum.map_join([command | args], " ", &format_argument/1)
  end

  defp format_argument(arg) do
    if arg =~ @special_chars do
      quote_argument(arg)
    else
      arg
    end
  end

  defp quote_argument(arg) do
    cond do
      # Prefer double quotes for arguments with only spaces or special characters
      String.match?(arg, @whitespace) and not String.contains?(arg, ~s(")) ->
        ~s("#{arg}")

      # Use single quotes if the argument contains double quotes but no single quotes
      String.contains?(arg, ~s(")) and not String.contains?(arg, "'") ->
        ~s('#{arg}')

      # Escape single quotes using the '"'"' trick if both quotes are present
      String.contains?(arg, "'") ->
        ~s('#{String.replace(arg, "'", "'\\''")}')

      # Default to double quotes for other special characters
      true ->
        ~s("#{arg}")
    end
  end
end
