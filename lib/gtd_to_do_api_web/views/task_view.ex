defmodule GtdToDoApiWeb.TaskView do
  use GtdToDoApiWeb, :view
  alias GtdToDoApiWeb.TaskView

  def render("index.json", %{tasks: tasks}) do
    %{tasks: render_many(tasks, TaskView, "task.json")}
  end

  def render("show.json", %{task: task}) do
    %{task: render_one(task, TaskView, "task.json")}
  end

  def render("task.json", %{task: task}) do
    %{
      id: task.id,
      content: task.content,
      is_done: task.is_done,
      list: task.list_id,
      owner: task.owner_id
    }
  end
end
