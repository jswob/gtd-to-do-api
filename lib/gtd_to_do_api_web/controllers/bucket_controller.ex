defmodule GtdToDoApiWeb.BucketController do
  use GtdToDoApiWeb, :controller

  alias GtdToDoApi.Containers
  alias GtdToDoApi.Containers.Bucket

  action_fallback GtdToDoApiWeb.FallbackController

  def index(conn, _params) do
    buckets = Containers.list_user_buckets(conn.assigns.current_user)
    render(conn, "index.json", buckets: buckets)
  end

  def create(conn, %{"bucket" => bucket_params}) do
    with {:ok, %Bucket{} = bucket} <-
           Containers.create_bucket(conn.assigns.current_user, bucket_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.bucket_path(conn, :show, bucket))
      |> render("show.json", bucket: bucket)
    end
  end

  def show(conn, %{"id" => id}) do
    bucket = Containers.get_user_bucket!(conn.assigns.current_user, id)
    render(conn, "show.json", bucket: bucket)
  end

  def update(conn, %{"id" => id, "bucket" => bucket_params}) do
    bucket = Containers.get_user_bucket!(conn.assigns.current_user, id)

    with {:ok, %Bucket{} = bucket} <- Containers.update_bucket(bucket, bucket_params) do
      render(conn, "show.json", bucket: bucket)
    end
  end

  def delete(conn, %{"id" => id}) do
    bucket = Containers.get_user_bucket!(conn.assigns.current_user, id)

    with {:ok, %Bucket{}} <- Containers.delete_bucket(bucket) do
      send_resp(conn, :no_content, "")
    end
  end
end
