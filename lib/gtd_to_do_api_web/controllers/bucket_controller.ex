defmodule GtdToDoApiWeb.BucketController do
  use GtdToDoApiWeb, :controller

  alias GtdToDoApi.Containers
  alias GtdToDoApi.Containers.Bucket
  alias GtdToDoApi.Auth.Guardian

  action_fallback GtdToDoApiWeb.FallbackController

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    buckets = Containers.list_user_buckets(user)
    render(conn, "index.json", buckets: buckets)
  end

  def create(conn, %{"bucket" => bucket_params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %Bucket{} = bucket} <-
           Containers.create_bucket(user, bucket_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.bucket_path(conn, :show, bucket))
      |> render("show.json", bucket: bucket)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    bucket = Containers.get_user_bucket!(user, id)
    render(conn, "show.json", bucket: bucket)
  end

  def update(conn, %{"id" => id, "bucket" => bucket_params}) do
    owner = Guardian.Plug.current_resource(conn)

    bucket = Containers.get_user_bucket!(owner, id)

    with {:ok, %Bucket{} = bucket} <- Containers.update_bucket(owner, bucket, bucket_params) do
      conn
      |> put_status(204)
      |> put_resp_header("location", Routes.bucket_path(conn, :show, bucket))
      |> render("show.json", bucket: bucket)
    end
  end

  @spec delete(Plug.Conn.t(), map) :: any
  def delete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    bucket = Containers.get_user_bucket!(user, id)

    with {:ok, %Bucket{}} <- Containers.delete_bucket(bucket) do
      send_resp(conn, :no_content, "")
    end
  end
end
