defmodule GtdToDoApi.Auth.Guardian do
  use Guardian, otp_app: :gtd_to_do_api

  alias GtdToDoApi.Accounts.User

  def subject_for_token(%User{} = user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :bad_user}
  end

  def resource_from_claims(%{"sub" => id}) do
    user = GtdToDoApi.Accounts.get_user!(id)
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end
