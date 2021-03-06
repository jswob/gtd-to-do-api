defmodule GtdToDoApiWeb.CollectionController do
  use GtdToDoApiWeb, :controller

  alias GtdToDoApi.Collections
  alias GtdToDoApi.Collections.Collection

  action_fallback GtdToDoApiWeb.FallbackController

  def index(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    collections = Collections.list_users_collections(user, params)
    render(conn, "index.json", collections: collections)
  end

  def index_bucket_collections(conn, %{"id" => bucket_id}) do
    user = Guardian.Plug.current_resource(conn)

    params = %{
      "filter" => %{
        "bucket_id" => bucket_id
      }
    }

    collections = Collections.list_users_collections(user, params)
    render(conn, "index.json", collections: collections)
  end

  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    collection = Collections.get_users_collection!(user, id)
    render(conn, "show.json", collection: collection)
  end

  def create(conn, %{"collection" => collection_params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %Collection{} = collection} <-
           Collections.create_collection(user, collection_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.collection_path(conn, :show, collection))
      |> render("show.json", collection: collection)
    end
  end

  def update(conn, %{"id" => id, "collection" => collection_params}) do
    user = Guardian.Plug.current_resource(conn)

    collection = Collections.get_users_collection!(user, id)

    with {:ok, %Collection{} = collection} <-
           Collections.update_collection(collection, collection_params) do
      render(conn, "show.json", collection: collection)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    collection = Collections.get_users_collection!(user, id)

    with {:ok, %Collection{}} <- Collections.delete_collection(collection) do
      send_resp(conn, :no_content, "")
    end
  end
end
