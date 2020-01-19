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

    test "sign_in with correct data returns user and update session with user id", %{conn: conn} do
      %User{id: id} = user_fixture(@create_attrs)

      conn =
        post(
          conn,
          Routes.user_path(conn, :sign_in, %{
            email: @create_attrs.email,
            password: @create_attrs.password
          })
        )

      assert conn.assigns.user.id == id

      assert %{"data" => %{"email" => email, "id" => id}} = json_response(conn, 200)
    end

    test "sign_in with incorrect data delete user id from session and return 401 error message",
         %{conn: conn} do
      id = 123
      put_session(conn, :user_id, id)

      conn =
        post(
          conn,
          Routes.user_path(conn, :sign_in, %{email: "wrong email", password: "wrong password"})
        )

      assert get_session(conn, :user_id) == nil
      assert json_response(conn, 401)
    end

    test "sign_out drop session", %{conn: conn} do
      user = user_fixture(@create_attrs)

      conn =
        post(
          conn,
          Routes.user_path(conn, :sign_in, %{
            email: @create_attrs.email,
            password: @create_attrs.password
          })
        )

      assert conn.cookies != %{}

      conn = post(conn, Routes.user_path(conn, :sign_out))

      assert conn.cookies == %{}
    end
  end

  describe "create user" do
    test "renders user and update session when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      assert get_session(conn, :user_id) == id

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "avatar_url" => "some avatar_url",
               "email" => "some email"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup %{conn: conn} do
      user = user_fixture()
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    end

    @tag timeout: :infinity
    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "avatar_url" => "some updated avatar_url",
               "email" => "some updated email"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup %{conn: conn} do
      user = user_fixture()
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    end

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert %{assigns: %{message: "Unauthenticated user"}} =
               get(conn, Routes.user_path(conn, :show, user))
    end
  end
end
