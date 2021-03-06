defmodule GtdToDoApi.TestHelpers do
  import Plug.Conn

  alias GtdToDoApi.Accounts
  alias GtdToDoApi.Collections
  alias GtdToDoApi.Tasks

  alias GtdToDoApi.Accounts.User
  alias GtdToDoApi.Collections.Collection

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

  @valid_bucket_attrs %{"color" => "some color", "title" => "some title"}

  def bucket_fixture(%User{} = owner, attrs \\ %{}) do
    attrs = Enum.into(attrs, @valid_bucket_attrs)

    {:ok, bucket} = GtdToDoApi.Containers.create_bucket(owner, attrs)

    bucket
  end

  @valid_collection_attrs %{"color" => "some color", "title" => "some title"}

  def collection_fixture(%User{} = owner, attrs \\ %{}) do
    attrs = Enum.into(attrs, @valid_collection_attrs)

    {:ok, collection} = Collections.create_collection(owner, attrs)

    collection
  end

  def collection_params_fixture(%User{} = owner, attrs \\ %{}) do
    attrs = Enum.into(attrs, @valid_collection_attrs)

    collection = collection_fixture(owner, attrs)

    %{
      "id" => collection.id,
      "title" => collection.title,
      "color" => collection.color
    }
  end

  @valid_list_attrs %{color: "some color", title: "some title"}

  def list_fixture(%User{} = user, %Collection{} = collection, attrs \\ %{}) do
    attrs = Enum.into(attrs, @valid_list_attrs)

    {:ok, list} = Collections.create_list(user, collection, attrs)

    list
  end

  @valid_task_attrs %{"content" => "some content", "is_done" => false}

  def task_fixture(attrs \\ %{}) do
    owner = user_fixture()
    collection = collection_fixture(owner)
    list = list_fixture(owner, collection)

    attrs = Enum.into(attrs, @valid_task_attrs)

    {:ok, task} = Tasks.create_task(owner, list, attrs)

    %{task: task, owner: owner, list: list}
  end

  def token_fixture(%User{} = user, params \\ []) do
    {:ok, token, _} = GtdToDoApi.Auth.Guardian.encode_and_sign(user, %{}, params)
    token
  end

  def setup_token_on_conn(conn) do
    user = user_fixture()
    token = token_fixture(user)

    conn = put_req_header(conn, "authorization", "Bearer #{token}")

    {:ok, conn: conn, token: token, user: user}
  end

  def setup_token_on_conn(conn, %User{} = user) do
    token = token_fixture(user)

    conn = put_req_header(conn, "authorization", "Bearer #{token}")

    {:ok, conn: conn, token: token}
  end

  def setup_token_on_conn(conn, token) do
    conn = put_req_header(conn, "authorization", "Bearer #{token}")

    {:ok, conn: conn}
  end
end
