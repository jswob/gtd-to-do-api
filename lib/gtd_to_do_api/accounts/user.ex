defmodule GtdToDoApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :avatar_url, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many :buckets, GtdToDoApi.Containers.Bucket,
      foreign_key: :owner_id,
      on_delete: :delete_all

    has_many :collections, GtdToDoApi.Collections.Collection,
      foreign_key: :owner_id,
      on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :avatar_url])
    |> validate_required([:email])
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, Bcrypt.add_hash(password))
  end

  defp put_password_hash(changeset) do
    changeset
  end
end
