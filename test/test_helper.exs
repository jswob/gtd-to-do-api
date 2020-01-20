ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(GtdToDoApi.Repo, :manual)

defmodule GtdToDoApi.TestHelpers do
  alias GtdToDoApi.Accounts
  alias GtdToDoApi.Collections

  @current_user_attrs %{
    avatar_url: "some avatar_url",
    email: "some email",
    password: "some password"
  }

  @valid_collection_attrs %{color: "some color", name: "some name"}

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@current_user_attrs)
      |> Accounts.create_user()

    user
  end

  def collection_fixture(%Accounts.User{} = owner, attrs \\ %{}) do
    attrs = Enum.into(attrs, @valid_collection_attrs)

    {:ok, collection} = Collections.create_collection(owner, attrs)

    collection
  end
end
