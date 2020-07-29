defmodule GtdToDoApi.Auth do
  import Ecto.Query

  alias GtdToDoApi.Accounts.User
  alias GtdToDoApi.Accounts
  alias GtdToDoApi.Repo
  alias GtdToDoApi.Auth.Guardian

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
    exp = 10
    {:ok, access_token, _} = Guardian.encode_and_sign(user, %{}, ttl: {exp, :second})

    {:ok, refresh_token, _} =
      Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {30, :second})

    {:ok, access_token, refresh_token, exp}
  end
end
