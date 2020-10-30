defmodule GtdToDoApiWeb.UserControllerTest do
  use GtdToDoApiWeb.ConnCase, async: true

  alias GtdToDoApi.Accounts.User

  @create_attrs %{
    avatar_url: "some avatar_url",
    email: "some email",
    password: "some password"
  }
  @update_attrs %{
    avatar_url: "some updated avatar_url",
    email: "some updated email",
    password: "some updated password"
  }
  @invalid_attrs %{avatar_url: nil, email: nil, password: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "authentication" do
    setup %{conn: conn} do
      conn =
        conn
        |> bypass_through(GtdToDoApiWeb.Router, :api)
        |> get("/api/users/1")

      {:ok, %{conn: conn}}
    end

    test "requires user authentication on :show, :update, :delete actions and :sign_out actions",
         %{conn: conn} do
      Enum.each(
        [
          get(conn, Routes.user_path(conn, :show, 123)),
          put(conn, Routes.user_path(conn, :update, 123, %{})),
          delete(conn, Routes.user_path(conn, :delete, 123)),
          post(conn, Routes.user_path(conn, :sign_out))
        ],
        fn conn ->
          assert json_response(conn, 401)
          assert conn.halted
        end
      )
    end

    test "sign_in with correct data returns access and refresh tokens", %{conn: conn} do
      user_fixture(@create_attrs)

      conn =
        post(
          conn,
          Routes.user_path(conn, :sign_in, %{
            username: @create_attrs.email,
            password: @create_attrs.password,
            grant_type: "password"
          })
        )

      assert %{
               "access_token" => _,
               "expires_in" => _,
               "refresh_token" => _,
               "token_type" => "bearer"
             } = json_response(conn, 200)
    end

    test "sign_in with incorrect data returns error message",
         %{conn: conn} do
      conn =
        post(
          conn,
          Routes.user_path(conn, :sign_in, %{
            username: "wrong email",
            password: "wrong password",
            grant_type: "password"
          })
        )

      assert %{
               "errors" => %{
                 "detail" => "Could not find user"
               }
             } = json_response(conn, 401)
    end

    test "sign_in with refresh_token returns access and refresh_tokens", %{conn: conn} do
      user = user_fixture()
      token = token_fixture(user, token_type: "refresh")

      conn =
        post(
          conn,
          Routes.user_path(conn, :sign_in, %{
            refresh_token: token,
            grant_type: "refresh_token"
          })
        )

      assert %{
               "access_token" => _,
               "expires_in" => _,
               "refresh_token" => _,
               "token_type" => "bearer"
             } = json_response(conn, 200)
    end

    test "sign_out invalidate token", %{conn: conn} do
      {:ok, conn: conn, token: _, user: _} = setup_token_on_conn(conn)

      conn = post(conn, Routes.user_path(conn, :sign_out))

      assert %{
               "data" => %{"message" => "Signing out successfully finished!"}
             } = json_response(conn, 200)
    end
  end

  describe "show user" do
    setup %{conn: conn}, do: setup_token_on_conn(conn)

    test "shows user if exists", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))

      %{avatar_url: avatar_url, email: email, password_hash: password_hash, id: id} = user

      assert %{
               "avatar_url" => ^avatar_url,
               "email" => ^email,
               "id" => ^id,
               "password_hash" => ^password_hash
             } = json_response(conn, 200)["user"]
    end
  end

  describe "create user" do
    test "renders user and update session when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["user"]

      user = GtdToDoApi.Accounts.get_user!(id)

      assert %{
               id: ^id,
               avatar_url: "some avatar_url",
               email: "some email"
             } = user
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] == [%{"email" => "can't be blank"}]
    end
  end

  describe "update user" do
    setup %{conn: conn}, do: setup_token_on_conn(conn)

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["user"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "avatar_url" => "some updated avatar_url",
               "email" => "some updated email"
             } = json_response(conn, 200)["user"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] == %{"email" => ["can't be blank"]}
    end
  end

  describe "delete user" do
    setup %{conn: conn}, do: setup_token_on_conn(conn)

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert %{assigns: %{message: "User with this id hasn't been found"}} =
               get(conn, Routes.user_path(conn, :show, user))
    end

    test "Don't deletes user if token resource has different id", %{conn: conn, user: user} do
      sneaky_user = user_fixture(%{email: "sneaky", password: "some"})
      {:ok, conn: conn, token: _} = setup_token_on_conn(conn, sneaky_user)

      conn = delete(conn, Routes.user_path(conn, :delete, user))

      assert %{"errors" => %{"detail" => "Bad user id"}} = json_response(conn, 401)
    end
  end
end
