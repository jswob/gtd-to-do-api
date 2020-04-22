defmodule GtdToDoApiWeb.UserView do
  use GtdToDoApiWeb, :view
  alias GtdToDoApiWeb.UserView

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("user.json", %{user: user}) do
    %{
      users: %{
        id: user.id,
        email: user.email,
        password_hash: user.password_hash,
        avatar_url: user.avatar_url
      }
    }
  end

  def render("sign_in.json", %{token: token}) do
    %{
      access_token: token,
      token_type: "bearer",
      expires_in: 15
    }
  end

  def render("sign_out.json", _params) do
    %{
      data: %{
        message: "session was succesfully deleted"
      }
    }
  end
end
