defmodule GtdToDoApi.Collections.Collection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "collections" do
    field :color, :string
    field :has_childs, :boolean, default: false
    field :name, :string

    belongs_to :owner, GtdToDoApi.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:name, :color])
    |> validate_required([:name])
  end
end
