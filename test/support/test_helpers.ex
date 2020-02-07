defmodule GtdToDoApi.TestHelpers do
  use Phoenix.ConnTest
  @endpoint GtdToDoApiWeb.Endpoint

  alias GtdToDoApi.Accounts
  alias GtdToDoApi.Collections
  alias GtdToDoApi.Tasks

  alias GtdToDoApi.Accounts.User
  alias GtdToDoApi.Collections.Collection
  alias GtdToDoApi.Collections.List
  alias GtdToDoApiWeb.Router.Helpers, as: Routes

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

  @valid_bucket_attrs %{color: "some color", title: "some title"}

  def bucket_fixture(%User{} = owner, attrs \\ %{}) do
    attrs = Enum.into(attrs, @valid_bucket_attrs)

    {:ok, bucket} = GtdToDoApi.Containers.create_bucket(owner, attrs)

    bucket
  end

  @valid_collection_attrs %{color: "some color", title: "some title"}

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

  @valid_list_attrs %{color: "some color", title: "some title"}

  def list_fixture(%User{} = user, %Collection{} = collection, attrs \\ %{}) do
    attrs = Enum.into(attrs, @valid_list_attrs)

    {:ok, list} = Collections.create_list(user, collection, attrs)

    list
  end

  @valid_task_attrs %{content: "some content", is_done: false}

  def task_fixture(attrs \\ %{}) do
    owner = user_fixture()
    collection = collection_fixture(owner)
    list = list_fixture(owner, collection)

    attrs = Enum.into(attrs, @valid_task_attrs)

    {:ok, task} = Tasks.create_task(owner, list, attrs)

    %{task: task, owner: owner, list: list}
  end

  def setup_test_session(conn, attrs \\ %{}) do
    owner = user_fixture(attrs)

    conn =
      conn
      |> Test.init_test_session(user_id: owner.id)
      |> get(Routes.user_path(conn, :show, owner.id))

    {:ok, %{conn: conn}}
  end
end
