defmodule GtdToDoApi.Repo do
  use Ecto.Repo,
    otp_app: :gtd_to_do_api,
    adapter: Ecto.Adapters.Postgres
end
