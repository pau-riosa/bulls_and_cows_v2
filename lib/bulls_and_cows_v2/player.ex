defmodule BullsAndCowsV2.Player do
  @moduledoc "Player struct"

  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  embedded_schema do
    field :name, :string
    field :guesses, {:array, :map}
  end

  @type t :: %Player{
          name: nil | String.t(),
          guesses: nil | List.t()
        }

  @doc false
  def insert_changeset(attrs) do
    changeset(%Player{}, attrs)
  end

  @doc false
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:name, :guesses])
    |> validate_required([:name])
    |> generate_id()
  end

  defp generate_id(changeset) do
    case get_field(changeset, :id) do
      nil ->
        put_change(changeset, :id, Ecto.UUID.generate())

      _value ->
        changeset
    end
  end

  @doc """
  create a player struct instance from the attributes
  """
  def create(params) do
    params
    |> insert_changeset
    |> apply_action(:insert)
  end
end
