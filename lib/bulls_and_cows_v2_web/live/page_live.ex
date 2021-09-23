defmodule BullsAndCowsV2Web.PageLive do
  use BullsAndCowsV2Web, :live_view
  alias BullsAndCowsV2Web.GameStarter
  alias BullsAndCowsV2.{Player, Server}
  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :changeset, GameStarter.insert_changeset(%{}))}
  end

  @impl true
  def handle_event("submit", %{"game_starter" => params}, socket) do
    with {:ok, starter} <- GameStarter.create(params),
         {:ok, game_code} <- GameStarter.get_game_code(starter),
         {:ok, player} <- Player.create(%{name: starter.name, guesses: []}),
         {:ok, _} <- Server.start_or_join(game_code, player) do
      {:noreply,
       push_redirect(socket,
         to: Routes.game_path(socket, :index, game_code, game: game_code, player: player.id)
       )}
    else
      {:error, reason} when is_binary(reason) ->
        {:noreply, put_flash(socket, :error, reason)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def handle_event("validate", %{"game_starter" => params}, socket) do
    changeset =
      params
      |> GameStarter.insert_changeset()
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  defp new_game?(changeset) do
    Ecto.Changeset.get_field(changeset, :type) == :start
  end
end
