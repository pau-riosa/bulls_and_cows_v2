defmodule BullsAndCowsV2Web.GameLive do
  use BullsAndCowsV2Web, :live_view
  alias BullsAndCowsV2.{Game, Player}
  alias BullsAndCowsV2.Server
  alias Phoenix.PubSub
  require Logger

  @impl true
  def mount(%{"game" => game_code, "player" => player_id}, _session, socket) do
    game_state = Server.get_current_game_state(game_code)
    player = Enum.find(game_state.players, fn f -> f.id == player_id end)

    if connected?(socket) do
      PubSub.subscribe(BullsAndCowsV2.PubSub, "game:#{game_code}")
      send(self(), :load_game_state)
    end

    {:ok,
     assign(socket,
       game_code: game_code,
       player_id: player_id,
       player: nil,
       reason: nil,
       game: %Game{},
       server_found: Server.server_found?(game_code)
     )}
  end

  @impl true
  def handle_event("submit", %{"guess" => guess_params} = _params, socket) do
    game_code = socket.assigns.game.code
    player_id = socket.assigns.player.id

    guess_number =
      Map.values(guess_params)
      |> Enum.join()

    with %Game{} = game <- Server.get_current_game_state(game_code),
         player <- Game.get_player(game, player_id),
         {:ok, game_state} <- Server.make_guess(game_code, player, guess_number) do
      send(self(), :load_game_state)
      {:noreply, assign(socket, game: game_state)}
    else
      {:error, reason} ->
        {:noreply, assign(socket, reason: reason)}
    end
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(
        :load_game_state,
        %{assigns: %{server_found: true, game_code: game_code}} = socket
      ) do
    with %Game{} = game <- Server.get_current_game_state(game_code),
         %Player{} = player <- Game.get_player(game, socket.assigns.player_id) do
      {:noreply, assign(socket, server_found: true, game: game, player: player)}
    else
      error ->
        Logger.error("Failed to load game server state. #{inspect(error)}")
        {:noreply, assign(socket, :server_found, false)}
    end
  end

  @impl true
  def handle_info(:load_game_state, socket) do
    Logger.debug("Game server #{inspect(socket.assigns.game_code)} not found")
    # Schedule to check again
    Process.send_after(self(), :load_game_state, 500)
    {:noreply, assign(socket, :server_found, Server.server_found?(socket.assigns.game_code))}
  end

  @impl true
  def handle_info({:game_state, %Game{} = state} = _event, socket) do
    updated_socket =
      socket
      |> clear_flash()
      |> assign(:game, state)

    {:noreply, updated_socket}
  end
end
