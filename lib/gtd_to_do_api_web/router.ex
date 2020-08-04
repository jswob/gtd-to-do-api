defmodule GtdToDoApiWeb.Router do
  use GtdToDoApiWeb, :router

  alias GtdToDoApi.Auth.AuthPipeline

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GtdToDoApiWeb do
    pipe_through :api

    resources "/users", UserController, exept: [:new, :edit, :index]
    post "/users/sign_in", UserController, :sign_in
    post "/users/sign_out", UserController, :sign_out
  end

  scope "/api", GtdToDoApiWeb do
    pipe_through [:api, AuthPipeline]

    resources "/buckets", BucketController, exept: [:new, :edit]
    resources "/collections", CollectionController, exept: [:new, :edit]
    get "/buckets/:id/collections", CollectionController, :index_bucket_collections
    resources "/lists", ListController, exept: [:new, :edit]
    resources "/tasks", TaskController, exept: [:new, :edit]
  end
end
