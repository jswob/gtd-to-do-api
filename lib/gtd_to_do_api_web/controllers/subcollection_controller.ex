defmodule GtdToDoApiWeb.SubcollectionController do
  use GtdToDoApiWeb, :controller

  alias GtdToDoApi.Accounts
  alias GtdToDoApi.Collections
  alias GtdToDoApi.Collections.Subcollection

  action_fallback GtdToDoApiWeb.FallbackController

  def index(conn, _params) do
    subcollection = Collections.list_subcollection()
    render(conn, "index.json", subcollection: subcollection)
  end

  def create(conn, %{"subcollection" => subcollection_params}) do
    with {:ok, %Subcollection{} = subcollection} <-
           Collections.create_subcollection(conn.assigns.current_user, subcollection_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.subcollection_path(conn, :show, subcollection))
      |> render("show.json", subcollection: subcollection)
    end
  end

  def show(conn, %{"id" => id}) do
    subcollection = Collections.get_subcollection!(id)
    render(conn, "show.json", subcollection: subcollection)
  end

  def update(conn, %{"id" => id, "subcollection" => subcollection_params}) do
    subcollection = Collections.get_subcollection!(id)

    with {:ok, %Subcollection{} = subcollection} <-
           Collections.update_subcollection(subcollection, subcollection_params) do
      render(conn, "show.json", subcollection: subcollection)
    end
  end

  def delete(conn, %{"id" => id}) do
    subcollection = Collections.get_subcollection!(id)

    with {:ok, %Subcollection{}} <- Collections.delete_subcollection(subcollection) do
      send_resp(conn, :no_content, "")
    end
  end
end
