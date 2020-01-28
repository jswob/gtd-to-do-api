defmodule GtdToDoApi.Collections.Subcollection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subcollection" do
    field :color, :string
    field :name, :string

    belongs_to :owner, GtdToDoApi.Accounts.User
    belongs_to :collection, GtdToDoApi.Collections.Collection

    timestamps()
  end

  @doc false
  def changeset(subcollection, attrs) do
    subcollection
    |> cast(attrs, [:name, :color, :collection_id])
    |> validate_required([:name, :color, :collection_id])
  end
end
