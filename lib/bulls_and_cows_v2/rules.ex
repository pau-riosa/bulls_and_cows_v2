defmodule BullsAndCowsV2.Rules do
  @moduledoc false

  @doc """
  takes on the secret and guess number from both players
  """
  def score_guess(secret_number, guess_number) do
    case do_score_guess(secret_number, guess_number) do
      {4, _cows} = value -> {:halt, value}
      value -> {:continue, value}
    end
  end

  defp do_score_guess(secret_number, guess_number) do
    secret_number = String.codepoints(secret_number)
    guess_number = String.codepoints(guess_number)

    secret_number
    |> Enum.zip(guess_number)
    |> Enum.reduce({0, 0}, fn {s, g}, {bulls, cows} ->
      cond do
        g == s -> {bulls + 1, cows}
        g in secret_number -> {bulls, cows + 1}
        true -> {bulls, cows}
      end
    end)
  end
end
