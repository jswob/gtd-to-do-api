defmodule GtdToDoApi.Auth.ErrorHandler do
  use Phoenix.Controller, namespace: GtdToDoApiWeb

  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    body = to_string(type)

    conn
    |> put_status(:unauthorized)
    |> put_view(GtdToDoApiWeb.ErrorView)
    |> render("401.json", message: body)
  end
end
