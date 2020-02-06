defmodule GtdToDoApiWeb.ListController do
  use GtdToDoApiWeb, :controller

  alias GtdToDoApi.Collections
  alias GtdToDoApi.Collections.List

  action_fallback GtdToDoApiWeb.FallbackController

  def index(conn, %{"collection" => collection}) do
    lists = Collections.list_collection_lists(collection)
    render(conn, "index.json", lists: lists)
  end

  def create(conn, %{"list" => %{"collection_id" => collection_id} = list_params}) do
    owner = conn.assigns.current_user
    collection = Collections.get_users_collection!(owner, collection_id)

    with {:ok, %List{} = list} <-
           Collections.create_list(conn.assigns.current_user, collection, list_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.list_path(conn, :show, list))
      |> render("show.json", list: list)
    end
  end

  def show(conn, %{"id" => id}) do
    list = Collections.get_user_list!(conn.assigns.current_user, id)
    render(conn, "show.json", list: list)
  end

  def update(conn, %{"id" => id, "list" => list_params}) do
    list = Collections.get_user_list!(conn.assigns.current_user, id)

    with {:ok, %List{} = list} <- Collections.update_list(list, list_params) do
      render(conn, "show.json", list: list)
    end
  end

  def delete(conn, %{"id" => id}) do
    list = Collections.get_user_list!(conn.assigns.current_user, id)

    with {:ok, %List{}} <- Collections.delete_list(list) do
      send_resp(conn, :no_content, "")
    end
  end
end
