defmodule GtdToDoApi.Collections do
  import Ecto.Query, warn: false
  alias GtdToDoApi.Repo

  alias Ecto.Changeset
  alias GtdToDoApi.Collections.Collection
  alias GtdToDoApi.Accounts.User

  # Collection
  # //////////////////////////////////////////////////////////////

  def list_collections do
    Repo.all(Collection)
  end

  def list_users_collections(user) do
    user
    |> users_collection_query()
    |> Repo.all()
  end

  def get_collection!(id), do: Repo.get!(Collection, id)

  def get_users_collection!(user, id) do
    user
    |> users_collection_query()
    |> Repo.get(id)
  end

  def create_collection(%User{} = owner, attrs \\ %{}) do
    %Collection{}
    |> Collection.changeset(attrs)
    |> Changeset.put_assoc(:owner, owner)
    |> Repo.insert()
  end

  def update_collection(%Collection{} = collection, attrs) do
    collection
    |> Collection.changeset(attrs)
    |> Repo.update()
  end

  def delete_collection(%Collection{} = collection) do
    Repo.delete(collection)
  end

  def change_collection(%Collection{} = collection) do
    Collection.changeset(collection, %{})
  end

  defp users_collection_query(%User{id: owner_id}) do
    from(c in Collection, where: c.owner_id == ^owner_id)
  end

  # subcollection
  # //////////////////////////////////////////////////////////////

  alias GtdToDoApi.Collections.Subcollection

  def list_subcollection do
    Repo.all(Subcollection)
  end

  def get_subcollection!(id), do: Repo.get!(Subcollection, id)

  def update_subcollection(%Subcollection{} = subcollection, attrs) do
    subcollection
    |> Subcollection.changeset(attrs)
    |> Repo.update()
  end

  def delete_subcollection(%Subcollection{} = subcollection) do
    Repo.delete(subcollection)
  end

  def change_subcollection(%Subcollection{} = subcollection) do
    Subcollection.changeset(subcollection, %{})
  end

  def list_subcollections_from_collection(collection) do
    Repo.all(list_subcollections_query(collection))
  end

  def get_collection_subcollection(collection, subcollection_id) do
    Repo.get!(list_subcollections_query(collection), subcollection_id)
  end

  def create_subcollection(%User{id: owner_id}, collection_id, attrs) do
    %Subcollection{owner_id: owner_id, collection_id: collection_id}
    |> Subcollection.changeset(attrs)
    |> Repo.insert()
  end

  defp list_subcollections_query(%Collection{} = collection) do
    from(s in Ecto.assoc(collection, :subcollections))
  end
end
