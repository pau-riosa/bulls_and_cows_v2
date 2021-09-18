defmodule BullsAndCowsV2Web.PageLive do
  use BullsAndCowsV2Web, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("submit", _params, socket) do
    {:noreply, push_redirect(socket, to: "/game/" <> "1")}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end
end
