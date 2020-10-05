defmodule GtdToDoApi.Containers.Bucket do
  use Ecto.Schema
  import Ecto.Changeset

  schema "buckets" do
    field :color, :string
    field :title, :string

    belongs_to :owner, GtdToDoApi.Accounts.User
    has_many :collections, GtdToDoApi.Collections.Collection

    timestamps()
  end

  @doc false
  def changeset(bucket, attrs) do
    bucket
    |> cast(attrs, [:title, :color])
    |> validate_required([:title])
    |> validate_length(:title, min: 1, max: 35)
    |> add_collections(attrs)
  end

  def add_collections(bucket, %{"collections" => collections, "owner" => owner}) do
    collections =
      Enum.map(collections, fn collection ->
        GtdToDoApi.Collections.get_users_collection!(owner, collection["id"])
      end)

    bucket
    |> put_assoc(:collections, collections)
  end

  def add_collections(bucket, _), do: bucket
end
