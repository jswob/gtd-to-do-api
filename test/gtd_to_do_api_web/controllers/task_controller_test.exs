defmodule GtdToDoApiWeb.TaskControllerTest do
  use GtdToDoApiWeb.ConnCase

  alias GtdToDoApi.Tasks
  alias GtdToDoApi.Tasks.Task

  @create_attrs %{
    content: "some content",
    is_done: true
  }
  @update_attrs %{
    content: "some updated content",
    is_done: false
  }
  @invalid_attrs %{content: nil, is_done: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "authentication" do
    test "requires user authentication on all actions", %{conn: conn} do
      Enum.each(
        [
          get(conn, Routes.task_path(conn, :index)),
          get(conn, Routes.task_path(conn, :show, 123)),
          put(conn, Routes.task_path(conn, :update, 123, %{})),
          post(conn, Routes.task_path(conn, :create, %{})),
          delete(conn, Routes.task_path(conn, :delete, 123))
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
      {:ok, task: task, list: list} = create_task(conn)
      {:ok, conn: conn, task: task, list: list}
    end

    test "lists all tasks", %{conn: conn, task: %Task{id: task_id}, list: list} do
      conn = get(conn, Routes.task_path(conn, :index), list_id: list.id)
      assert [%{"id" => ^task_id}] = json_response(conn, 200)["data"]
    end
  end

  describe "create task" do
    setup %{conn: conn} do
      setup_test_session(conn)
    end

    test "renders task when data is valid", %{conn: conn} do
      owner = conn.assigns.current_user
      collection = collection_fixture(owner)
      list = list_fixture(owner, collection)

      attrs = Enum.into(%{list_id: list.id}, @create_attrs)

      conn = post(conn, Routes.task_path(conn, :create), task: attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.task_path(conn, :show, id))

      assert %{
               "id" => id,
               "content" => "some content",
               "is_done" => true
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      owner = conn.assigns.current_user
      collection = collection_fixture(owner)
      list = list_fixture(owner, collection)

      attrs = Enum.into(%{list_id: list.id}, @invalid_attrs)

      conn = post(conn, Routes.task_path(conn, :create), task: attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update task" do
    setup %{conn: conn} do
      {:ok, %{conn: conn}} = setup_test_session(conn)
      {:ok, task: task, list: list} = create_task(conn)
      {:ok, conn: conn, task: task, list: list}
    end

    test "renders task when data is valid", %{conn: conn, task: %Task{id: id} = task} do
      conn = put(conn, Routes.task_path(conn, :update, task), task: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.task_path(conn, :show, id))

      assert %{
               "id" => id,
               "content" => "some updated content",
               "is_done" => false
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, task: task} do
      conn = put(conn, Routes.task_path(conn, :update, task), task: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete task" do
    setup %{conn: conn} do
      {:ok, %{conn: conn}} = setup_test_session(conn)
      {:ok, task: task, list: list} = create_task(conn)
      {:ok, conn: conn, task: task, list: list}
    end

    test "deletes chosen task", %{conn: conn, task: task} do
      conn = delete(conn, Routes.task_path(conn, :delete, task))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.task_path(conn, :show, task))
      end
    end
  end

  defp create_task(conn) do
    owner = conn.assigns.current_user
    collection = collection_fixture(owner)
    list = list_fixture(owner, collection)

    {:ok, task} = Tasks.create_task(owner, list, @create_attrs)

    {:ok, task: task, list: list}
  end
end