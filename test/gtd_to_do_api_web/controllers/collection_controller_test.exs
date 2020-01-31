defmodule GtdToDoApiWeb.CollectionControllerTest do
  use GtdToDoApiWeb.ConnCase, async: true

  alias GtdToDoApi.Collections.Collection

  @create_attrs %{
    color: "some color",
    title: "some title"
  }
  @update_attrs %{
    color: "some updated color",
    title: "some updated title"
  }
  @invalid_attrs %{color: nil, title: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "authentication" do
    test "requires user authentication on all actions",
         %{conn: conn} do
      Enum.each(
        [
          get(conn, Routes.collection_path(conn, :index)),
          get(conn, Routes.collection_path(conn, :show, 123)),
          put(conn, Routes.collection_path(conn, :update, 123, %{})),
          post(conn, Routes.collection_path(conn, :create, %{})),
          delete(conn, Routes.collection_path(conn, :delete, 123))
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
      setup_test_session(conn)
    end

    test "lists all collections", %{conn: conn} do
      conn = get(conn, Routes.collection_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create collection" do
    setup %{conn: conn} do
      setup_test_session(conn)
    end

    test "renders collection when data is valid", %{conn: conn} do
      conn = post(conn, Routes.collection_path(conn, :create), collection: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.collection_path(conn, :show, id))

      assert %{
               "id" => id,
               "color" => "some color",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.collection_path(conn, :create), collection: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update collection" do
    setup %{conn: conn} do
      create_collection(conn)
    end

    test "renders collection when data is valid", %{
      conn: conn,
      collection: %Collection{id: id} = collection
    } do
      conn =
        put(conn, Routes.collection_path(conn, :update, collection), collection: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.collection_path(conn, :show, id))

      assert %{
               "id" => id,
               "color" => "some updated color",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, collection: collection} do
      conn =
        put(conn, Routes.collection_path(conn, :update, collection), collection: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete collection" do
    setup %{conn: conn} do
      create_collection(conn)
    end

    test "deletes chosen collection", %{
      conn: conn,
      collection: collection
    } do
      conn = delete(conn, Routes.collection_path(conn, :delete, collection))
      assert response(conn, 204)
    end
  end

  defp create_collection(conn) do
    {:ok, %{conn: conn}} = setup_test_session(conn)

    {:ok,
     %{
       conn: conn,
       collection: collection_fixture(conn.assigns.current_user),
       owner: conn.assigns.current_user
     }}
  end
end
