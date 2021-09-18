defmodule BullsAndCowsV2.Game do
  @moduledoc false
  alias __MODULE__
  alias BullsAndCowsV2.{Player, Rules}

  defstruct code: nil,
            secret_number: nil,
            turn: nil,
            winner: nil,
            players: [],
            status: :not_started,
            over: false

  @type game_code :: String.t()
  @type t :: %Game{
          code: nil | String.t(),
          status: :not_started | :playing | :done,
          players: [Player.t()],
          turn: nil | Player.t(),
          winner: nil | Player.t(),
          over: Boolean.t(),
          secret_number: Integer.t()
        }

  def new(game_code, %Player{} = player) do
    %Game{code: game_code, players: [player]}
  end

  @doc """
  Return the player from the game state found by the ID.
  """
  @spec get_player(t(), player_id :: String.t()) :: nil | Player.t()
  def get_player(%Game{players: players} = _state, player_id) do
    Enum.find(players, &(&1.id == player_id))
  end

  # def join(%Game{players: players}) when length(players) == 2 do
  #   {:error, "No more players allowed"}
  # end

  # def join(%Game{players: players} = game) do
  #   player = next_player(players)
  #   {:ok, %{game | players: [player | players]}, player}
  # end

  # def leave(%Game{players: players} = game, player) when player in @players do
  #   {:ok, %{game | players: Enum.reject(players, fn f -> f.name == player end)}}
  # end

  # def make_guess(%Game{over: true}, _player, _guess_number), do: {:error, "Game over"}

  # def make_guess(%Game{turn: turn}, player, _guess_number) when turn !== player,
  #   do: {:error, "not your turn"}

  # def make_guess(%Game{secret_number: secret_number} = game, player, guess_number) do
  #   case Rules.score_guess(secret_number, guess_number) do
  #     {:halt, value} ->
  #       game_updated =
  #         game
  #         |> update_player_guesses(player, value)
  #         |> update_secret_number()
  #         |> update_turn(player)
  #         |> check_winner()

  #       {:halt, game_updated}

  #     {:continue, value} ->
  #       game_updated =
  #         game
  #         |> update_player_guesses(player, value)

  #       {:continue, game_updated}
  #   end
  # end

  # def update_over(game), do: %{game | over: true}
  # def update_winner(game, winner), do: %{game | winner: winner}
  # def update_turn(game, player), do: %{game | turn: opposite_player(player)}
  # def update_secret_number(game), do: %{game | secret_number: generate_secret()}

  # def update_player_guesses(game, player, value) do
  #   find_player =
  #     game.players
  #     |> Enum.find(&(&1.name == player))

  #   updated_player = %{find_player | guesses: [value | find_player.guesses]}

  #   updated_players =
  #     Enum.map(game.players, fn x ->
  #       if x.name == player, do: updated_player, else: x
  #     end)

  #   %{game | players: updated_players}
  # end

  # def opposite_player(:player_1), do: :player_2
  # def opposite_player(:player_2), do: :player_1

  # defp next_player([]), do: %Player{name: Enum.at(@players, 0)}
  # defp next_player([player]), do: %Player{name: opposite_player(player.name)}

  # defp generate_secret() do
  #   Enum.take_random(0..9, 4) |> Enum.reduce("", fn x, acc -> "#{acc}#{x}" end)
  # end

  # defp check_winner(game) do
  #   player_1 = Enum.at(game.players, 0)
  #   player_2 = Enum.at(game.players, 1)

  #   guesses_1 =
  #     if player_1.guesses |> Enum.find(fn x -> {4, 0} == x end) do
  #       player_1.guesses |> Enum.count()
  #     end

  #   guesses_2 =
  #     if player_2.guesses |> Enum.find(fn x -> {4, 0} == x end) do
  #       player_2.guesses |> Enum.count()
  #     end

  #   case {guesses_1, guesses_2} do
  #     {guesses_1, guesses_2} when not is_nil(guesses_1) and not is_nil(guesses_2) ->
  #       winner =
  #         if guesses_1 == guesses_2 do
  #           :draw
  #         else
  #           if guesses_1 > guesses_2,
  #             do: player_2.name,
  #             else: player_1.name
  #         end

  #       game |> update_winner(winner) |> update_over

  #     _ ->
  #       game
  #   end
  # end
end
