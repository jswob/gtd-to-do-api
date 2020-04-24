defmodule GtdToDoApi.Guardian do
  use Guardian, otp_app: :gtd_to_do_api

  alias GtdToDoApi.Accounts.User

  def subject_for_token(%User{} = user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :bad_user}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    user = GtdToDoApi.Accounts.get_user!(id)
    {:ok, user}
  end
end
