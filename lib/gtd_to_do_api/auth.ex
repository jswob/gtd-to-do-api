defmodule GtdToDoApi.Auth do
  import Plug.Conn
  import Phoenix.Controller
  import Ecto.Query

  alias GtdToDoApi.Accounts.User
  alias GtdToDoApi.Repo

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user_id = get_session(conn, :user_id)

    cond do
      conn.assigns[:current_user] ->
        conn

      user = current_user_id && GtdToDoApi.Accounts.get_user!(current_user_id) ->
        assign(conn, :current_user, user)

      true ->
        assign(conn, :current_user, nil)
    end
  end

  def ensure_authenticated(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(GtdToDoApiWeb.ErrorView)
      |> render("401.json", message: "Unauthenticated user")
      |> halt()
    end
  end

  def authenticate_user(email, password) do
    query = from(u in User, where: u.email == ^email)

    query
    |> Repo.one()
    |> verify_password(password)
  end

  defp verify_password(nil, _) do
    Bcrypt.no_user_verify()
    {:error, "Could not find user"}
  end

  defp verify_password(user, password) do
    if Bcrypt.verify_pass(password, user.password_hash) do
      {:ok, user}
    else
      {:error, "Wrong email or password"}
    end
  end
end
