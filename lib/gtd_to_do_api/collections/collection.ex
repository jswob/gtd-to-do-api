defmodule GtdToDoApi.Collections.Collection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "collections" do
    field :color, :string
    field :title, :string

    belongs_to :owner, GtdToDoApi.Accounts.User
    belongs_to :bucket, GtdToDoApi.Containers.Bucket, on_replace: :nilify
    has_many :lists, GtdToDoApi.Collections.List

    timestamps()
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:title, :color])
    |> validate_required([:title])
    |> add_bucket(attrs)
    |> validate_length(:title, min: 1, max: 35)
  end

  def add_bucket(collection, %{"bucket" => bucket_id, "owner" => owner}) do
    case bucket_id do
      nil ->
        put_assoc(collection, :bucket, nil)

      id ->
        put_assoc(collection, :bucket, GtdToDoApi.Containers.get_user_bucket!(owner, id))
    end
  end

  def add_bucket(collection, _), do: collection
end
