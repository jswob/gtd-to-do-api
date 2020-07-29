defmodule GtdToDoApiWeb.TaskController do
  use GtdToDoApiWeb, :controller

  alias GtdToDoApi.Tasks
  alias GtdToDoApi.Tasks.Task

  action_fallback GtdToDoApiWeb.FallbackController

  def index(conn, %{"list_id" => list_id}) do
    owner = Guardian.Plug.current_resource(conn)
    list = GtdToDoApi.Collections.get_user_list!(owner, list_id)

    tasks = Tasks.list_list_tasks(list)
    render(conn, "index.json", tasks: tasks)
  end

  def create(conn, %{"task" => %{"list_id" => list_id} = task_params}) do
    owner = Guardian.Plug.current_resource(conn)
    list = GtdToDoApi.Collections.get_user_list!(owner, list_id)

    with {:ok, %Task{} = task} <- Tasks.create_task(owner, list, task_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.task_path(conn, :show, task))
      |> render("show.json", task: task)
    end
  end

  def show(conn, %{"id" => id}) do
    owner = Guardian.Plug.current_resource(conn)
    task = Tasks.get_user_task!(owner, id)
    render(conn, "show.json", task: task)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    owner = Guardian.Plug.current_resource(conn)
    task = Tasks.get_user_task!(owner, id)

    with {:ok, %Task{} = task} <- Tasks.update_task(task, task_params) do
      render(conn, "show.json", task: task)
    end
  end

  def delete(conn, %{"id" => id}) do
    owner = Guardian.Plug.current_resource(conn)
    task = Tasks.get_user_task!(owner, id)

    with {:ok, %Task{}} <- Tasks.delete_task(task) do
      send_resp(conn, :no_content, "")
    end
  end
end
