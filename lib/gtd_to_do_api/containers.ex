defmodule GtdToDoApi.Containers do
  @moduledoc """
  The Containers context.
  """

  import Ecto.Query, warn: false
  alias GtdToDoApi.Repo

  alias GtdToDoApi.Containers.Bucket
  alias GtdToDoApi.Accounts.User

  def list_buckets do
    Repo.all(Bucket)
  end

  def list_user_buckets(%User{id: owner_id}) do
    Repo.all(user_buckets_query(owner_id))
  end

  def get_bucket!(id), do: Repo.get!(Bucket, id)

  def get_user_bucket!(%User{id: owner_id}, id) do
    owner_id
    |> user_buckets_query()
    |> Repo.get!(id)
  end

  def create_bucket(%User{} = owner, attrs \\ %{}) do
    attrs = Map.put(attrs, "owner", owner)

    %Bucket{}
    |> Bucket.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:owner, owner)
    |> Repo.insert()
  end

  def update_bucket(%User{} = owner, %Bucket{} = bucket, attrs \\ %{}) do
    attrs = Map.put(attrs, "owner", owner)

    bucket
    |> Repo.preload([:collections])
    |> Bucket.changeset(attrs)
    |> Repo.update()
  end

  def delete_bucket(%Bucket{} = bucket) do
    Repo.delete(bucket)
  end

  def change_bucket(%Bucket{} = bucket) do
    Bucket.changeset(bucket, %{})
  end

  defp user_buckets_query(owner_id) do
    from(b in Bucket, where: b.owner_id == ^owner_id)
  end
end
