defmodule GtdToDoApiWeb.ListControllerTest do
  use GtdToDoApiWeb.ConnCase

  alias GtdToDoApi.Collections
  alias GtdToDoApi.Collections.List

  @create_attrs %{
    color: "some color",
    title: "some title"
  }
  @update_attrs %{
    color: "some updated color",
    title: "some updated title"
  }
  @invalid_attrs %{color: nil, title: nil, collection_id: 123}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "authentication" do
    test "requires user authentication on all actions", %{conn: conn} do
      Enum.each(
        [
          get(conn, Routes.list_path(conn, :index)),
          get(conn, Routes.list_path(conn, :show, 123)),
          put(conn, Routes.list_path(conn, :update, 123, %{})),
          post(conn, Routes.list_path(conn, :create, %{})),
          delete(conn, Routes.list_path(conn, :delete, 123))
        ],
        fn conn ->
          assert json_response(conn, 401)
          assert conn.halted
        end
      )
    end
  end

  describe "index" do
    setup %{conn: conn} do
      {:ok, %{conn: conn}} = setup_test_session(conn)
      {:ok, list: list, collection: collection} = create_list(conn)
      {:ok, conn: conn, list: list, collection: collection}
    end

    test "lists all lists", %{conn: conn, list: %List{id: list_id}, collection: collection} do
      conn = get(conn, Routes.list_path(conn, :index), collection: collection)
      assert [%{"id" => ^list_id}] = json_response(conn, 200)["data"]
    end
  end

  describe "create list" do
    setup %{conn: conn} do
      setup_test_session(conn)
    end

    test "renders list when data is valid", %{conn: conn} do
      owner = conn.assigns.current_user
      collection = collection_fixture(owner)

      attrs = Enum.into(%{collection_id: collection.id}, @create_attrs)

      conn = post(conn, Routes.list_path(conn, :create), list: attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.list_path(conn, :show, id))

      assert %{
               "id" => id,
               "color" => "some color",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      owner = conn.assigns.current_user
      collection = collection_fixture(owner)

      attrs = Enum.into(%{collection_id: collection.id}, @invalid_attrs)

      conn = post(conn, Routes.list_path(conn, :create), list: attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update list" do
    setup %{conn: conn} do
      {:ok, %{conn: conn}} = setup_test_session(conn)
      {:ok, list: list, collection: collection} = create_list(conn)
      {:ok, conn: conn, list: list, collection: collection}
    end

    test "renders list when data is valid", %{conn: conn, list: %List{id: id} = list} do
      conn = put(conn, Routes.list_path(conn, :update, list), list: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.list_path(conn, :show, id))

      assert %{
               "id" => id,
               "color" => "some updated color",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, list: list} do
      conn = put(conn, Routes.list_path(conn, :update, list), list: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete list" do
    setup %{conn: conn} do
      {:ok, %{conn: conn}} = setup_test_session(conn)
      {:ok, list: list, collection: collection} = create_list(conn)
      {:ok, conn: conn, list: list, collection: collection}
    end

    test "deletes chosen list", %{conn: conn, list: list} do
      conn = delete(conn, Routes.list_path(conn, :delete, list))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.list_path(conn, :show, list))
      end
    end
  end

  defp create_list(conn) do
    owner = conn.assigns.current_user
    collection = collection_fixture(owner)
    attrs = Enum.into(@create_attrs, %{collection_id: collection.id})

    list = list_fixture(owner, collection, attrs)

    {:ok, list: list, collection: collection}
  end
end
