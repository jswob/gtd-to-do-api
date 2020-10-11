defmodule GtdToDoApiWeb.ListView do
  use GtdToDoApiWeb, :view
  alias GtdToDoApiWeb.ListView

  def render("index.json", %{lists: lists}) do
    %{lists: render_many(lists, ListView, "list.json")}
  end

  def render("show.json", %{list: list}) do
    %{list: render_one(list, ListView, "list.json")}
  end

  def render("list.json", %{list: list}) do
    link = "/api/lists/#{list.id}/tasks"

    %{
      id: list.id,
      title: list.title,
      color: list.color,
      collection: list.collection_id,
      links: %{
        tasks: link
      }
    }
  end
end
