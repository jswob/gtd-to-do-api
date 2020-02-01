defmodule GtdToDoApi.Containers.Bucket do
  use Ecto.Schema
  import Ecto.Changeset

  schema "buckets" do
    field :color, :string
    field :title, :string

    belongs_to :owner, GtdToDoApi.Accounts.User
    has_many :collections, GtdToDoApi.Multimedia.Collections

    timestamps()
  end

  @doc false
  def changeset(bucket, attrs) do
    bucket
    |> cast(attrs, [:title, :color])
    |> validate_required([:title, :color])
  end
end
