defmodule GtdToDoApi.Collections.Collection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "collections" do
    field :color, :string
    field :title, :string

    belongs_to :owner, GtdToDoApi.Accounts.User
    belongs_to :bucket, GtdToDoApi.Containers.Bucket
    has_many :lists, GtdToDoApi.Collections.List

    timestamps()
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:title, :color])
    |> validate_required([:title])
    |> validate_length(:title, min: 1, max: 35)
  end
end
