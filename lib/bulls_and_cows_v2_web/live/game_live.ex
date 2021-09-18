defmodule BullsAndCowsV2Web.GameLive do
  use BullsAndCowsV2Web, :live_view
  alias BullsAndCowsV2.Game
  alias BullsAndCowsV2.Server
  alias Phoenix.PubSub
  require Logger
  @impl true
  def mount(%{"game" => game_code, "player" => player_id}, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(BullsAndCowsV2.PubSub, "game:#{game_code}")

      send(self(), :load_game_state)
    end

    {:ok,
     assign(socket,
       game_code: game_code,
       player_id: player_id,
       player: nil,
       game: %Game{},
       server_found: Server.server_found?(game_code)
     )}
  end

  @impl true
  def handle_event("submit", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_info(
        :load_game_state,
        %{assigns: %{server_found: true, game_code: game_code}} = socket
      ) do
    case Server.get_current_game_state(game_code) do
      %Game{} = game ->
        player = Game.get_player(game, socket.assigns.player_id)
        {:noreply, assign(socket, server_found: true, game: game, player: player)}

      error ->
        Logger.error("Failed to load game server state. #{inspect(error)}")
        {:noreply, assign(socket, :server_found, false)}
    end
  end

  def handle_info(:load_game_state, socket) do
    Logger.debug("Game server #{inspect(socket.assigns.game_code)} not found")
    # Schedule to check again
    Process.send_after(self(), :load_game_state, 500)
    {:noreply, assign(socket, :server_found, GameServer.server_found?(socket.assigns.game_code))}
  end
end
