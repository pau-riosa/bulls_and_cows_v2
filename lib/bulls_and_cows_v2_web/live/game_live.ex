defmodule BullsAndCowsV2Web.GameLive do
  use BullsAndCowsV2Web, :live_view
  alias BullsAndCowsV2.{Game, Player}
  alias BullsAndCowsV2.Server
  alias Phoenix.PubSub
  require Logger

  @impl true
  def mount(%{"game" => game_code, "player" => player_id}, _session, socket) do
    game_state = lookup(game_code)
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
       game: %Game{},
       secret_changeset: Player.secret_number_changeset(player),
       server_found: Server.server_found?(game_code)
     )}
  end

  def lookup(game_code) do
    [{pid, _}] = Registry.lookup(BullsAndCowsV2.GameRegistry, game_code)
    :sys.get_state(pid)
  end

  @impl true
  def handle_event(
        "validate_secret_number",
        %{"player" => player_params} = _params,
        socket
      ) do
    player = socket.assigns.player

    changeset =
      Player.secret_number_changeset(player, player_params) |> Map.put(:action, :validate)

    {:noreply, assign(socket, secret_changeset: changeset)}
  end

  @impl true
  def handle_event(
        "submit_secret_number",
        %{"player" => player_params} = _params,
        socket
      ) do
    player = socket.assigns.player
    game = socket.assigns.game

    case Player.update(player, player_params) do
      {:ok, player} ->
        updated_game = Game.update_player(game, player)
        Server.broadcast_game_state(updated_game)
        {:noreply, assign(socket, game: updated_game, player: player)}

      {:error, changeset} ->
        {:noreply, assign(socket, secret_changeset: changeset)}
    end
  end

  @impl true
  def handle_event("submit", _params, socket) do
    {:noreply, socket}
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
    case Server.get_current_game_state(game_code) do
      %Game{} = game ->
        player = Game.get_player(game, socket.assigns.player_id)
        IO.inspect(player)
        {:noreply, assign(socket, server_found: true, game: game, player: player)}

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
