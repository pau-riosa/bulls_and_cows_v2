defmodule BullsAndCowsV2Web.GameStarter do
  @moduledoc """
    Struct and changeset for start a game. 
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__
  alias BullsAndCowsV2.Server

  embedded_schema do
    field :name, :string
    field :game_code, :string
    field :type, Ecto.Enum, values: [:start, :join], default: :start
  end

  @type t :: %GameStarter{
          name: nil | String.t(),
          game_code: nil | String.t(),
          type: :start | :join
        }

  @doc false
  def insert_changeset(attrs) do
    %GameStarter{}
    |> cast(attrs, [:name, :game_code])
    |> validate_required([:name])
    |> validate_length(:name, max: 15)
    |> validate_length(:game_code, is: 4)
    |> uppercase_game_code()
    |> validate_game_code()
    |> compute_type()
  end

  def uppercase_game_code(changeset) do
    case get_field(changeset, :game_code) do
      nil -> changeset
      value -> put_change(changeset, :game_code, String.upcase(value))
    end
  end

  defp validate_game_code(changeset) do
    # Don't check for a running game server if there are errors on the game_code
    # field
    if changeset.errors[:game_code] do
      changeset
    else
      case get_field(changeset, :game_code) do
        nil ->
          changeset

        value ->
          if Server.server_found?(value) do
            changeset
          else
            add_error(changeset, :game_code, "not a running game.")
          end
      end
    end
  end

  def compute_type(changeset) do
    case get_field(changeset, :game_code) do
      nil ->
        put_change(changeset, :type, :start)

      _game_code ->
        put_change(changeset, :type, :join)
    end
  end

  @doc """
  Get the game code to use for starting or joining the game.
  """
  def get_game_code(%GameStarter{type: :join, game_code: code}), do: {:ok, code}

  def get_game_code(%GameStarter{type: :start}) do
    Server.generate_game_code()
  end

  @doc """
  Create the GameStart struct data from the changeset if valid.
  """
  def create(params) do
    params
    |> insert_changeset()
    |> apply_action(:insert)
  end
end
