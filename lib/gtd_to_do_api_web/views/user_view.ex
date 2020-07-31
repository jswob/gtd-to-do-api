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

  def render("sign_in.json", %{
        access_token: access_token,
        refresh_token: refresh_token,
        exp: exp,
        user_id: user_id
      }) do
    %{
      access_token: access_token,
      token_type: "bearer",
      refresh_token: refresh_token,
      expires_in: exp,
      user_id: user_id
    }
  end

  def render("sign_out.json", _params) do
    %{
      data: %{
        message: "Signing out successfully finished!"
      }
    }
  end
end
