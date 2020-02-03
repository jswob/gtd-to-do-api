defmodule GtdToDoApi.Collections.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :color, :string
    field :title, :string

    belongs_to :owner, GtdToDoApi.Accounts.User
    belongs_to :collection, GtdToDoApi.Collections.Collection

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title, :color, :collection_id])
    |> validate_required([:title, :color, :collection_id])
    |> check_if_collection_has_proper_owner()
  end

  defp check_if_collection_has_proper_owner(
         %Ecto.Changeset{
           valid?: true,
           changes: %{collection_id: collection_id},
           data: %{owner_id: owner_id}
         } = changeset
       ) do
    collection_owner = GtdToDoApi.Collections.get_collection!(collection_id).owner_id

    if collection_owner == owner_id do
      changeset
    else
      Ecto.Changeset.add_error(
        changeset,
        :collection_id,
        "The owner of the collection is not you"
      )
    end
  end

  defp check_if_collection_has_proper_owner(changeset), do: changeset
end
