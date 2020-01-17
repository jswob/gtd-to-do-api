defmodule GtdToDoApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :avatar_url, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :avatar_url])
    |> put_password_hash()
    |> validate_required([:email, :password])
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, %{password: Bcrypt.add_hash(password)})
  end

  defp put_password_hash(changeset) do
    changeset
  end
end
