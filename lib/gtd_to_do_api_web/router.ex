defmodule GtdToDoApiWeb.Router do
  use GtdToDoApiWeb, :router

  alias GtdToDoApi.Auth

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug Auth
  end

  pipeline :api_auth do
    plug Auth, :ensure_authenticated
  end

  scope "/api", GtdToDoApiWeb do
    pipe_through :api

    resources "/users", UserController, exept: [:new, :edit, :index]
    post "/users/sign_in", UserController, :sign_in
    post "/users/sign_out", UserController, :sign_out
  end

  scope "/api", GtdToDoApiWeb do
    pipe_through [:api, :api_auth]
  end
end
