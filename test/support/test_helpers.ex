defmodule GtdToDoApi.TestHelpers do
  alias GtdToDoApi.Accounts
  alias GtdToDoApi.Collections

  alias GtdToDoApi.Accounts.User
  alias GtdToDoApi.Collections.Collection

  alias Plug.Test

  @current_user_attrs %{
    avatar_url: "some avatar_url",
    email: "some email",
    password: "some password"
  }

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@current_user_attrs)
      |> Accounts.create_user()

    user
  end

  @valid_collection_attrs %{color: "some color", name: "some name"}

  def collection_fixture(%User{} = owner, attrs \\ %{}) do
    attrs = Enum.into(attrs, @valid_collection_attrs)

    {:ok, collection} = Collections.create_collection(owner, attrs)

    collection
  end

  @valid_subcollection_attrs %{color: "some color", name: "some name"}

  def subcollection_fixture(%User{} = owner, %Collection{id: collection_id}, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{collection_id: collection_id})
      |> Enum.into(@valid_subcollection_attrs)

    {:ok, subcollection} = Collections.create_subcollection(owner, attrs)

    subcollection
  end

  def setup_test_session(conn, attrs \\ %{}) do
    owner = user_fixture(attrs)

    {:ok, %{conn: Test.init_test_session(conn, user_id: owner.id), owner: owner}}
  end
end
