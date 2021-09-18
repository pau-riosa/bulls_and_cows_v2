defmodule BullsAndCowsV2.Player do
  @moduledoc "Player struct"

  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  embedded_schema do
    field :secret_number, :string
    field :name, :string
    field :guesses, {:array, :map}
  end

  @type t :: %Player{
          secret_number: nil | String.t(),
          name: nil | String.t(),
          guesses: nil | List.t()
        }

  @doc false
  def insert_changeset(attrs) do
    changeset(%Player{}, attrs)
  end

  def update_changeset(player, attrs) do
    secret_number_changeset(player, attrs)
  end

  def secret_number_changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:secret_number])
    |> validate_required(:secret_number)
    |> validate_length(:secret_number, is: 4)
  end

  @doc false
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:name, :guesses, :secret_number])
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

  @doc """
  update a player struct instance from the attributes
  """
  def update(player, params) do
    player
    |> update_changeset(params)
    |> apply_action(:update)
  end
end
