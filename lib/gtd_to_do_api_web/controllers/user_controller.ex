defmodule GtdToDoApiWeb.UserController do
  use GtdToDoApiWeb, :controller

  alias GtdToDoApi.Accounts.User
  alias GtdToDoApi.Accounts
  alias GtdToDoApi.Auth

  action_fallback GtdToDoApiWeb.FallbackController

  plug Auth.AuthPipeline when action in [:show, :update, :delete, :sign_out]

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    else
      {:error, changeset} ->
        conn
        |> put_status(422)
        |> put_view(GtdToDoApiWeb.ErrorView)
        |> render("422.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    cond do
      !user ->
        undefined_user_error(conn)

      to_string(user.id) == id ->
        render(conn, "show.json", user: user)

      true ->
        bad_user_id_error(conn)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Guardian.Plug.current_resource(conn)

    cond do
      !user ->
        undefined_user_error(conn)

      to_string(user.id) == id ->
        with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
          conn
          |> render("show.json", user: user)
        end

      true ->
        bad_user_id_error(conn)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    cond do
      !user ->
        undefined_user_error(conn)

      to_string(user.id) == id ->
        with {:ok, %User{}} <- Accounts.delete_user(user) do
          send_resp(conn, :no_content, "")
        end

      true ->
        bad_user_id_error(conn)
    end
  end

  def sign_in(conn, %{"username" => email, "password" => password, "grant_type" => "password"}) do
    case Auth.authenticate_user(email, password) do
      {:ok, access_token, refresh_token, exp} ->
        conn
        |> put_status(:ok)
        |> render("sign_in.json",
          access_token: access_token,
          refresh_token: refresh_token,
          exp: exp
        )

      {:error, message} ->
        conn
        |> put_status(:unauthorized)
        |> put_view(GtdToDoApiWeb.ErrorView)
        |> render("401.json", message: message)
    end
  end

  def sign_in(conn, %{"refresh_token" => refresh_token, "grant_type" => "refresh_token"}) do
    case Auth.authenticate_user(refresh_token) do
      {:ok, access_token, refresh_token, exp} ->
        conn
        |> put_status(:ok)
        |> render("sign_in.json",
          access_token: access_token,
          refresh_token: refresh_token,
          exp: exp
        )

      {:error, message} ->
        conn
        |> put_status(:unauthorized)
        |> put_view(GtdToDoApiWeb.ErrorView)
        |> render("401.json", message: message)
    end
  end

  def sign_out(conn, _params) do
    conn
    |> GtdToDoApi.Auth.Guardian.Plug.sign_out()
    |> render("sign_out.json", %{})
  end

  defp bad_user_id_error(conn) do
    conn
    |> put_status(:unauthorized)
    |> put_view(GtdToDoApiWeb.ErrorView)
    |> halt()
    |> render("401.json", message: "Bad user id")
  end

  defp undefined_user_error(conn) do
    conn
    |> put_status(:not_found)
    |> put_view(GtdToDoApiWeb.ErrorView)
    |> halt()
    |> render("404.json", message: "User with this id hasn't been found")
  end
end
