defmodule GtdToDoApiWeb.UserController do
  use GtdToDoApiWeb, :controller

  alias GtdToDoApi.Accounts.User
  alias GtdToDoApi.Accounts
  alias GtdToDoApi.Auth

  action_fallback GtdToDoApiWeb.FallbackController

  plug :ensure_authenticated when action in [:show, :update, :delete, :sign_out]

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> put_session(:user_id, user.id)
      |> render("show.json", user: user)
    end

    case Accounts.create_user(user_params) do
      {:ok, %User{} = user} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", Routes.user_path(conn, :show, user))
        |> put_session(:user_id, user.id)
        |> render("show.json", user: user)

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> put_view(GtdToDoApiWeb.ErrorView)
        |> render("422.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      conn
      |> put_session(:user_id, user.id)
      |> render("show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def sign_in(conn, %{"username" => email, "password" => password}) do
    case Auth.authenticate_user(email, password) do
      {:ok, token} ->
        conn
        |> put_status(:ok)
        |> render("sign_in.json", token: token)

      {:error, message} ->
        conn
        |> delete_session(:user_id)
        |> put_status(:unauthorized)
        |> put_view(GtdToDoApiWeb.ErrorView)
        |> render("401.json", message: message)
    end
  end

  def sign_out(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> render("sign_out.json", %{})
  end
end
