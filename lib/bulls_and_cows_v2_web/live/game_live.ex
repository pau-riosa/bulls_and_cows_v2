defmodule BullsAndCowsV2Web.GameLive do
  use BullsAndCowsV2Web, :live_view

  @impl true
  def mount(%{"id" => game_id}, _session, socket) do
    {:ok, assign(socket, game_id: game_id)}
  end

  @impl true
  def handle_event("submit", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end
end
