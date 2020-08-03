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

  def list_non_bucket_collections(user) do
    user
    |> non_bucket_collections_query()
    |> Repo.all()
  end

  def list_bucket_collections(bucket) do
    bucket
    |> bucket_collections_query()
    |> Repo.all()
  end

  def get_collection!(id), do: Repo.get!(Collection, id)

  def get_users_collection!(user, id) do
    user
    |> users_collection_query()
    |> Repo.get(id)
  end

  def create_collection(%User{} = owner, attrs \\ %{}) do
    attrs = Map.put(attrs, "owner", owner)

    %Collection{}
    |> Collection.changeset(attrs)
    |> Changeset.put_assoc(:owner, owner)
    |> Repo.insert()
  end

  def update_collection(%Collection{} = collection, attrs) do
    owner = GtdToDoApi.Accounts.get_user!(collection.owner_id)
    attrs = Map.put(attrs, "owner", owner)

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
    from(c in Collection,
      where: c.owner_id == ^owner_id,
      preload: [bucket: c]
    )
  end

  defp non_bucket_collections_query(%User{id: owner_id}) do
    from(c in Collection,
      where: c.owner_id == ^owner_id and is_nil(c.bucket_id),
      preload: [bucket: c]
    )
  end

  defp bucket_collections_query(%GtdToDoApi.Containers.Bucket{id: bucket_id}) do
    from(c in Collection, where: c.bucket_id == ^bucket_id)
  end

  # list
  # /////////////////////////////////////////////////////////////

  alias GtdToDoApi.Collections.List

  @doc """
  Returns the list of lists.

  ## Examples

      iex> list_lists()
      [%List{}, ...]

  """
  def list_lists do
    Repo.all(List)
  end

  @doc """
  Returns the list of lists for given collection.

  ## Examples

      iex> list_collection_lists(collection)
      [%List{collection_id: ^collection.id}, ...]

  """
  def list_collection_lists(%Collection{} = collection) do
    Repo.all(list_lists_query(collection))
  end

  @doc """
  Gets a single list.

  Raises `Ecto.NoResultsError` if the List does not exist.

  ## Examples

      iex> get_list!(123)
      %List{}

      iex> get_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_list!(id), do: Repo.get!(List, id)

  @doc """
  Gets a single list for given user.

  ## Examples

      iex> get_user_list!(owner, 123)
      %List{}

      iex> get_user_list!(owner, 456)
      ** (Ecto.NoResultsError)

  """
  def get_user_list!(%User{id: user_id}, id),
    do: Repo.get!(from(l in List, where: l.owner_id == ^user_id), id)

  @doc """
  Creates a list.

  ## Examples

      iex> create_list(user, collection, %{field: value})
      {:ok, %List{}}

      iex> create_list(user, collection, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_list(%User{} = owner, %Collection{} = collection, attrs \\ %{}) do
    %List{collection_id: collection.id}
    |> List.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:owner, owner)
    |> Ecto.Changeset.put_assoc(:collection, collection)
    |> Repo.insert()
  end

  @doc """
  Updates a list.

  ## Examples

      iex> update_list(list, %{field: new_value})
      {:ok, %List{}}

      iex> update_list(list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_list(%List{} = list, attrs) do
    list
    |> List.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a List.

  ## Examples

      iex> delete_list(list)
      {:ok, %List{}}

      iex> delete_list(list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_list(%List{} = list) do
    Repo.delete(list)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking list changes.

  ## Examples

      iex> change_list(list)
      %Ecto.Changeset{source: %List{}}

  """
  def change_list(%List{} = list) do
    List.changeset(list, %{})
  end

  @doc """
  Returns query that selects all lists for given collection.

  ## Examples

      iex> list_lists_query(collection)
      #Ecto.Query<from l0 in GtdToDoApi.Collections.List,
                    where: l0.collection_id == ^collection.id>

  """
  def list_lists_query(collection) do
    from(l in Ecto.assoc(collection, :lists))
  end
end
