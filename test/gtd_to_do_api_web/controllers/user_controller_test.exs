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

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

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

  defp create_user(_) do
    user = user_fixture()
    {:ok, user: user}
  end
end
