defmodule GtdToDoApi.Collections.Collection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "collections" do
    field :color, :string
    field :title, :string

    belongs_to :owner, GtdToDoApi.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:title, :color])
    |> validate_required([:title, :color])
  end
end
