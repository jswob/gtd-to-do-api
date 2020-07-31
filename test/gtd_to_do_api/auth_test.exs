defmodule GtdToDoApi.AuthTest do
  use GtdToDoApiWeb.ConnCase, async: true

  alias GtdToDoApi.Auth
  alias GtdToDoApi.Accounts.User
  alias GtdToDoApi.Auth.Guardian

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(GtdToDoApiWeb.Router, :api)
      |> get("/api/users/1")

    {:ok, %{conn: conn}}
  end

  test "authenticate_user/2 returns {:ok, token, refresh_token, expiration} if email and password are ok" do
    user_password = "some password"
    %User{id: id, email: email} = user_fixture(%{password: user_password})

    assert {:ok, token, refresh_token, expiration, ^id} =
             Auth.authenticate_user(email, user_password)

    id = to_string(id)

    assert {:ok, %{"sub" => ^id}} = Guardian.decode_and_verify(token, %{})

    assert {:ok, %{"sub" => ^id}} =
             Guardian.decode_and_verify(refresh_token, %{"typ" => "refresh"})
  end

  test "authenticate_user/2 returns {:error, message} if email or password are wrong" do
    assert {:error, "Could not find user"} = Auth.authenticate_user("wrong email", "wrong pass")
  end

  test "authenticate_user/1 returns {:ok, token, refresh_token, expiration} if token is correct" do
    user = user_fixture()

    {:ok, refresh_token, %{"sub" => id}} =
      Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {1, :minute})

    assert {:ok, token, refresh_token, expiration, user_id} =
             Auth.authenticate_user(refresh_token)

    assert {:ok, %{"sub" => ^id}} = Guardian.decode_and_verify(token, %{})

    assert {:ok, %{"sub" => ^id}} =
             Guardian.decode_and_verify(refresh_token, %{"typ" => "refresh"})
  end

  test "authenticate_user/1 returns {:error, message} if token is bad" do
    assert {:error, "Bad token"} = Auth.authenticate_user("bad_token")
  end
end
