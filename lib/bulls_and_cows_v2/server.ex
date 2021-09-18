defmodule BullsAndCowsV2.Server do
  use GenServer
  alias BullsAndCowsV2.{Player, Game}
  alias __MODULE__
  require Logger

  @impl true
  def init(%{player: player, code: code}) do
    # Create the new game state with the creating player assigned
    {:ok, Game.new(code, player)}
  end

  def child_spec(opts) do
    name = Keyword.get(opts, :name, Server)
    player = Keyword.fetch!(opts, :player)

    %{
      id: "#{Server}_#{name}",
      start: {Server, :start_link, [name, player]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def start_link(game_code, %Player{} = player) do
    case GenServer.start_link(Server, %{player: player, code: game_code},
           name: via_tuple(game_code)
         ) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.info(
          "Already started Server #{inspect(game_code)} at #{inspect(pid)}, returning :ignore"
        )

        :ignore
    end
  end

  def via_tuple(game_code), do: {:via, Horde.Registry, {BullsAndCowsV2.GameRegistry, game_code}}

  def start_or_join(game_code, %Player{} = player) do
    case Horde.DynamicSupervisor.start_child(
           BullsAndCowsV2.DistributedSupervisor,
           {Server, [name: game_code, player: player]}
         ) do
      {:ok, _pid} ->
        Logger.info("Started game server #{inspect(game_code)}")
        {:ok, :started}

      :ignore ->
        Logger.info("Game Server #{inspect(game_code)} already running. Joining")

        {:ok, :joined}
        # case join_game(game_code, player) do
        #   :ok -> {:ok, :joined}
        #   {:error, _reason} = error -> error
        # end
    end
  end

  @doc """
  Lookup the GameServer and report if it is found. Returns a boolean.
  """
  @spec server_found?(Game.game_code()) :: boolean()
  def server_found?(game_code) do
    # Look up the game in the registry. Return if a match is found.
    case Horde.Registry.lookup(BullsAndCowsV2.GameRegistry, game_code) do
      [] -> false
      [{pid, _} | _] when is_pid(pid) -> true
    end
  end

  @doc """
  Generate a unique game code for starting a new game server.
  """
  @spec generate_game_code() :: {:ok, Game.game_code()} | {:error, String.t()}
  def generate_game_code() do
    # Generate 3 server codes to try. Take the first that is unused.
    # If no unused ones found, add an error
    codes = Enum.map(1..3, fn _ -> do_generate_code() end)

    case Enum.find(codes, &(!Server.server_found?(&1))) do
      nil ->
        # no unused game code found. Report server busy, try again later.
        {:error, "Didn't find unused code, try again later"}

      code ->
        {:ok, code}
    end
  end

  defp do_generate_code() do
    # Generate a single 4 character random code
    range = ?A..?Z

    1..4
    |> Enum.map(fn _ -> [Enum.random(range)] |> List.to_string() end)
    |> Enum.join("")
  end

  # def join(id) do
  #   GenServer.call(via_tuple(id), :join)
  # end

  # def leave(id, player) do
  #   GenServer.call(via_tuple(id), {:leave, player})
  # end

  # def stop(id) do
  #   GenServer.stop(via_tuple(id), :shutdown)
  # end

  # def make_guess(id, player, guess_number) do
  #   GenServer.call(via_tuple(id), {:make_guess, player, guess_number})
  # end

  # def get_state(id) do
  #   GenServer.call(via_tuple(id), :get_state)
  # end

  # defp via_tuple(game_id) do
  #   {:via, Registry, {Registry.ViaGame, game_id}}
  # end

  # @impl true
  # def init(_args) do
  #   {:ok, Game.new()}
  # end

  # @impl true
  # def handle_call(:get_state, _form, state) do
  #   {:reply, state, state}
  # end

  # @impl true
  # def handle_call({:make_guess, player, guess_number}, _from, state) do
  #   case Game.make_guess(state, player, guess_number) do
  #     {:halt, new_state} -> {:reply, {:ok, new_state}, new_state}
  #     {:continue, new_state} -> {:reply, {:ok, new_state}, new_state}
  #     {:error, reason} -> {:reply, {:error, reason}, state}
  #   end
  # end

  # @impl true
  # def handle_call(:join, _from, state) do
  #   case Game.join(state) do
  #     {:ok, new_state, player} -> {:reply, {:ok, new_state, player}, new_state}
  #     {:error, reason} -> {:reply, {:error, reason}, state}
  #   end
  # end

  # @impl true
  # def handle_call({:leave, player}, _from, state) do
  #   case Game.leave(state, player) do
  #     {:ok, new_state} -> {:reply, {:ok, new_state}, new_state}
  #   end
  # end

  # @impl true
  # def terminate(_reason, _status) do
  #   :ok
  # end
end
