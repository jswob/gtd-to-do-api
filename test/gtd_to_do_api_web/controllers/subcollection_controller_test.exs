defmodule GtdToDoApiWeb.SubcollectionControllerTest do
  use GtdToDoApiWeb.ConnCase

  alias GtdToDoApi.Collections.Collection
  alias GtdToDoApi.Collections.Subcollection

  @create_attrs %{
    color: "some color",
    name: "some name"
  }
  @update_attrs %{
    color: "some updated color",
    name: "some updated name"
  }
  @invalid_attrs %{color: nil, name: nil, collection_id: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "authentication" do
    test "requires user authentication on all actions", %{conn: conn} do
      Enum.each(
        [
          get(conn, Routes.subcollection_path(conn, :index)),
          get(conn, Routes.subcollection_path(conn, :show, 123)),
          put(conn, Routes.subcollection_path(conn, :update, 123, %{})),
          post(conn, Routes.subcollection_path(conn, :create, %{})),
          delete(conn, Routes.subcollection_path(conn, :delete, 123))
        ],
        fn conn ->
          assert json_response(conn, 401)
          assert conn.halted
        end
      )
    end
  end

  describe "index" do
    setup %{conn: conn}, do: setup_test_session(conn)

    test "lists all subcollection", %{conn: conn} do
      conn = get(conn, Routes.subcollection_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create subcollection" do
    setup %{conn: conn} do
      setup_test_session(conn)
    end

    test "renders subcollection when data is valid", %{conn: conn} do
      owner = conn.assigns.current_user
      %Collection{id: collection_id} = collection_fixture(owner)

      attrs = Enum.into(@create_attrs, %{collection_id: collection_id})

      conn = post(conn, Routes.subcollection_path(conn, :create), subcollection: attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.subcollection_path(conn, :show, id))

      assert %{
               "id" => id,
               "color" => "some color",
               "name" => "some name",
               "collection_id" => collection_id,
               "owner_id" => owner
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.subcollection_path(conn, :create), subcollection: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update subcollection" do
    setup %{conn: conn} do
      {:ok, %{conn: conn}} = setup_test_session(conn)

      {:ok, conn: conn, subcollection: create_subcollection(conn)}
    end

    test "renders subcollection when data is valid", %{
      conn: conn,
      subcollection: %Subcollection{id: id} = subcollection
    } do
      conn =
        put(conn, Routes.subcollection_path(conn, :update, subcollection),
          subcollection: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.subcollection_path(conn, :show, id))

      assert %{
               "id" => id,
               "color" => "some updated color",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, subcollection: subcollection} do
      conn =
        put(conn, Routes.subcollection_path(conn, :update, subcollection),
          subcollection: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete subcollection" do
    setup %{conn: conn} do
      {:ok, %{conn: conn}} = setup_test_session(conn)

      {:ok, conn: conn, subcollection: create_subcollection(conn)}
    end

    test "deletes chosen subcollection", %{conn: conn, subcollection: subcollection} do
      conn = delete(conn, Routes.subcollection_path(conn, :delete, subcollection))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.subcollection_path(conn, :show, subcollection))
      end
    end
  end

  defp create_subcollection(conn) do
    owner = conn.assigns.current_user
    collection = collection_fixture(owner)
    attrs = Enum.into(@create_attrs, %{collection_id: collection.id})

    subcollection_fixture(owner, collection, attrs)
  end
end
