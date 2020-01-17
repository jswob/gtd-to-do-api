ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(GtdToDoApi.Repo, :manual)

defmodule GtdToDoApi.TestHelpers do
  alias GtdToDoApi.Accounts
  alias GtdToDoApi.Accounts.User

  @current_user_attrs %{
    avatar_url: "some avatar_url",
    email: "some email",
    password: "some password"
  }

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@current_user_attrs)
      |> Accounts.create_user()

    user
  end
end
