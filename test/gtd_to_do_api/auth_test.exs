defmodule GtdToDoApi.AuthTest do
  use GtdToDoApiWeb.ConnCase, async: true

  alias GtdToDoApi.Auth
  alias GtdToDoApi.Accounts.User
  alias GtdToDoApi.Guardian

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(GtdToDoApiWeb.Router, :api)
      |> get("/api/users/1")

    {:ok, %{conn: conn}}
  end

  test "when session is empty halt connection", %{conn: conn} do
    conn = Auth.ensure_authenticated(conn, [])

    assert conn.halted
  end

  test "when :current_user is set make a connection", %{conn: conn} do
    user = user_fixture()

    conn =
      conn
      |> assign(:current_user, user)
      |> Auth.ensure_authenticated([])

    refute conn.halted
  end

  test "call with session, set :current_user", %{conn: conn} do
    %User{id: id} = user_fixture()

    conn =
      conn
      |> put_session(:user_id, id)
      |> Auth.call(Auth.init([]))

    assert %User{id: ^id} = conn.assigns[:current_user]
  end

  test "call with empty session, set :current_user to nil", %{conn: conn} do
    conn = Auth.call(conn, Auth.init([]))

    assert conn.assigns[:current_user] == nil
  end

  test "authenticate_user/2 returns {:ok, user} if email and password are ok" do
    user_password = "some password"
    %User{id: id, email: email} = user_fixture(%{password: user_password})

    id = to_string(id)

    assert {:ok, token, refresh_token, expiration} = Auth.authenticate_user(email, user_password)
    assert {:ok, %{"sub" => ^id}} = Guardian.decode_and_verify(token, %{})

    assert {:ok, %{"sub" => ^id}} =
             Guardian.decode_and_verify(refresh_token, %{"typ" => "refresh"})
  end

  test "authenticate_user/2 returns {:error, message} if email or password are wrong" do
    assert {:error, "Could not find user"} = Auth.authenticate_user("wrong email", "wrong pass")
  end
end
