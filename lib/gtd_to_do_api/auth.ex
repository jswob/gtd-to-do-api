defmodule GtdToDoApi.Auth do
  import Plug.Conn
  import Phoenix.Controller
  import Ecto.Query

  alias GtdToDoApi.Accounts.User
  alias GtdToDoApi.Accounts
  alias GtdToDoApi.Repo
  alias GtdToDoApi.Guardian

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user_id = get_session(conn, :user_id)

    cond do
      conn.assigns[:current_user] ->
        conn

      user = current_user_id && Accounts.get_user!(current_user_id) ->
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

    user = Repo.one(query)

    case verify_password(user, password) do
      {:ok, %User{} = user} ->
        generate_tokens(user)

      {:error, message} ->
        {:error, message}
    end
  end

  def authenticate_user(token) do
    case Guardian.decode_and_verify(token, %{"typ" => "refresh"}) do
      {:ok, claims} ->
        user = Accounts.get_user!(claims["sub"])
        generate_tokens(user)

      {:error, :token_expired} ->
        {:error, "Refresh token expired"}

      _ ->
        {:error, "Bad token"}
    end
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

  defp generate_tokens(%User{} = user) do
    exp = 15
    {:ok, access_token, _} = Guardian.encode_and_sign(user, %{}, ttl: {exp, :second})

    {:ok, refresh_token, _} =
      Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {1, :minute})

    {:ok, access_token, refresh_token, exp}
  end
end
