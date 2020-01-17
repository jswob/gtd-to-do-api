defmodule GtdToDoApiWeb.Router do
  use GtdToDoApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GtdToDoApiWeb do
    pipe_through :api

    resources "/users", UserController, exept: [:new, :edit, :index]
  end
end
