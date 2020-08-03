defmodule GtdToDoApiWeb.CollectionControllerTest do
  use GtdToDoApiWeb.ConnCase, async: true

  alias GtdToDoApi.Collections.Collection
  alias GtdToDoApi.Containers.Bucket

  @create_attrs %{
    "color" => "some color",
    "title" => "some title"
  }
  @update_attrs %{
    "color" => "some updated color",
    "title" => "some updated title"
  }

  @invalid_attrs %{"color" => nil, "title" => nil}

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
    setup %{conn: conn}, do: setup_token_on_conn(conn)

    test "lists all collections", %{conn: conn} do
      conn = get(conn, Routes.collection_path(conn, :index))
      assert json_response(conn, 200)["collections"] == []
    end
  end

  describe "index bucket collections" do
    setup %{conn: conn} do
      {:ok, conn: conn, token: _, user: owner} = setup_token_on_conn(conn)

      bucket = bucket_fixture(owner)

      collection_attrs = Map.put(@create_attrs, "bucket", bucket.id)

      {:ok,
       conn: conn,
       bucket: bucket,
       collection_1: collection_fixture(owner, collection_attrs),
       collection_2: collection_fixture(owner, collection_attrs)}
    end

    test "lists all collections for given bucket_id", %{
      conn: conn,
      bucket: %Bucket{id: bucket_id},
      collection_1: %Collection{id: collection_1_id},
      collection_2: %Collection{id: collection_2_id}
    } do
      conn = get(conn, Routes.collection_path(conn, :index_bucket_collections, bucket_id))

      assert [%{"id" => ^collection_1_id}, %{"id" => ^collection_2_id}] =
               json_response(conn, 200)["collections"]
    end
  end

  describe "index non bucket collections" do
    setup %{conn: conn}, do: setup_token_on_conn(conn)

    test "lists all collections for given user id without bucket", %{conn: conn, user: owner} do
      # Create collection for different user
      sneaky_user = user_fixture(%{email: "sneaky email"})
      collection_fixture(sneaky_user)

      # Create collection with bucket
      bucket = bucket_fixture(owner)
      collection_fixture(owner, Map.put(@create_attrs, "bucket", bucket.id))

      # Create two collections without buckets and with correct user
      %Collection{id: collection_1_id} = collection_fixture(owner)
      %Collection{id: collection_2_id} = collection_fixture(owner)

      conn = get(conn, Routes.collection_path(conn, :index_non_bucket_collections, owner.id))

      assert [%{"id" => ^collection_1_id}, %{"id" => ^collection_2_id}] =
               json_response(conn, 200)["collections"]

      assert 2 = Enum.count(json_response(conn, 200)["collections"])
    end

    test "if user_id and real user id are different return 401 error", %{conn: conn} do
      # Create bad user
      sneaky_user = user_fixture(%{email: "sneaky email"})

      conn =
        get(conn, Routes.collection_path(conn, :index_non_bucket_collections, sneaky_user.id))

      assert %{
               "errors" => %{
                 "detail" => "Unathoraized to access that resource"
               }
             } = json_response(conn, 401)
    end
  end

  describe "create collection" do
    setup %{conn: conn}, do: setup_token_on_conn(conn)

    test "renders collection when data is valid", %{conn: conn, user: user} do
      create_attrs = setup_bucket_on_attrs(user, @create_attrs)

      conn = post(conn, Routes.collection_path(conn, :create), collection: create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["collection"]

      conn = get(conn, Routes.collection_path(conn, :show, id))

      links = "/collections/#{id}/lists"
      %{"color" => color, "title" => title, "bucket" => bucket_id} = create_attrs

      assert %{
               "id" => ^id,
               "color" => ^color,
               "title" => ^title,
               "bucket" => ^bucket_id,
               "links" => %{
                 "lists" => ^links
               }
             } = json_response(conn, 200)["collection"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.collection_path(conn, :create), collection: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update collection" do
    setup %{conn: conn}, do: create_collection(conn)

    test "renders collection when data is valid", %{
      conn: conn,
      collection: %Collection{id: id} = collection,
      owner: owner
    } do
      %GtdToDoApi.Containers.Bucket{id: bucket_id} = bucket_fixture(owner)

      update_attrs = Map.put(@update_attrs, "bucket", bucket_id)

      conn =
        put(conn, Routes.collection_path(conn, :update, collection), collection: update_attrs)

      links = "/collections/#{id}/lists"
      %{"color" => color, "title" => title} = update_attrs

      assert %{"id" => ^id} = json_response(conn, 200)["collection"]

      conn = get(conn, Routes.collection_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "color" => ^color,
               "title" => ^title,
               "bucket" => ^bucket_id,
               "links" => %{
                 "lists" => ^links
               }
             } = json_response(conn, 200)["collection"]
    end

    test "renders errors when data is invalid", %{conn: conn, collection: collection} do
      conn =
        put(conn, Routes.collection_path(conn, :update, collection), collection: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete collection" do
    setup %{conn: conn}, do: create_collection(conn)

    test "deletes chosen collection", %{
      conn: conn,
      collection: collection
    } do
      conn = delete(conn, Routes.collection_path(conn, :delete, collection))
      assert response(conn, 204)
    end
  end

  defp create_collection(conn) do
    {:ok, conn: conn, token: _, user: owner} = setup_token_on_conn(conn)

    {:ok, conn: conn, collection: collection_fixture(owner), owner: owner}
  end

  defp setup_bucket_on_attrs(user, attrs) do
    bucket = bucket_fixture(user)
    attrs = Map.put(attrs, "bucket", bucket.id)

    attrs
  end
end
