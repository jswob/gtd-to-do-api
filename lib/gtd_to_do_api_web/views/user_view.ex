defmodule GtdToDoApiWeb.UserView do
  use GtdToDoApiWeb, :view
  alias GtdToDoApiWeb.UserView

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      password_hash: user.password_hash,
      avatar_url: user.avatar_url
    }
  end
end