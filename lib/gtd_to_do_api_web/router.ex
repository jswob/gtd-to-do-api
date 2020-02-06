defmodule GtdToDoApiWeb.Router do
  use GtdToDoApiWeb, :router

  alias GtdToDoApi.Auth

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug Auth
  end

  scope "/api", GtdToDoApiWeb do
    pipe_through :api

    resources "/users", UserController, exept: [:new, :edit, :index]
    post "/users/sign_in", UserController, :sign_in
    post "/users/sign_out", UserController, :sign_out
  end

  scope "/api", GtdToDoApiWeb do
    pipe_through [:api, :ensure_authenticated]

    resources "/collections", CollectionController, exept: [:new, :edit]
    resources "/subcollections", SubcollectionController, exept: [:new, :edit]
    resources "/buckets", BucketController, exept: [:new, :edit]
    resources "/lists", ListController, exept: [:new, :edit]
  end
end
