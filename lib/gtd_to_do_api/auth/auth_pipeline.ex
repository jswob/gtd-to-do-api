defmodule GtdToDoApi.Auth.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :gtd_to_do_api,
    module: Guardian.Token,
    error_handler: GtdToDoApi

  @claims %{}

  plug Guardian.Plug.VerifySession, claims: @claims
  plug Guardian.Plug.VerifyHeader, claims: @claims, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
