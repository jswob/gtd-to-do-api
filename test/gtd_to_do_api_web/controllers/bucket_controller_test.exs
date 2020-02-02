defmodule GtdToDoApiWeb.BucketControllerTest do
  use GtdToDoApiWeb.ConnCase, async: true

  alias GtdToDoApi.Containers.Bucket

  @create_attrs %{
    color: "some color",
    title: "some title"
  }
  @update_attrs %{color: "some updated color", title: "some updated title"}
  @invalid_attrs %{color: nil, title: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "authentication" do
    test "requires user authentication on all actions",
         %{conn: conn} do
      Enum.each(
        [
          get(conn, Routes.bucket_path(conn, :index)),
          get(conn, Routes.bucket_path(conn, :show, 123)),
          put(conn, Routes.bucket_path(conn, :update, 123, %{})),
          post(conn, Routes.bucket_path(conn, :create, %{})),
          delete(conn, Routes.bucket_path(conn, :delete, 123))
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

    test "lists all buckets", %{conn: conn} do
      conn = get(conn, Routes.bucket_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create bucket" do
    setup %{conn: conn} do
      setup_test_session(conn)
    end

    test "renders bucket when data is valid", %{conn: conn} do
      conn = post(conn, Routes.bucket_path(conn, :create), bucket: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.bucket_path(conn, :show, id))

      assert %{
               "id" => id,
               "color" => "some color",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.bucket_path(conn, :create), bucket: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update bucket" do
    setup %{conn: conn} do
      create_bucket(conn)
    end

    test "renders bucket when data is valid", %{conn: conn, bucket: %Bucket{id: id} = bucket} do
      conn = put(conn, Routes.bucket_path(conn, :update, bucket), bucket: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.bucket_path(conn, :show, id))

      assert %{
               "id" => id,
               "color" => "some updated color",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, bucket: bucket} do
      conn = put(conn, Routes.bucket_path(conn, :update, bucket), bucket: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete bucket" do
    setup %{conn: conn} do
      create_bucket(conn)
    end

    test "deletes chosen bucket", %{conn: conn, bucket: bucket} do
      conn = delete(conn, Routes.bucket_path(conn, :delete, bucket))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.bucket_path(conn, :show, bucket))
      end
    end
  end

  defp create_bucket(conn) do
    {:ok, %{conn: conn}} = setup_test_session(conn)

    {:ok,
     %{
       conn: conn,
       bucket: bucket_fixture(conn.assigns.current_user),
       owner: conn.assigns.current_user
     }}
  end
end
