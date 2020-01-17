defmodule GtdToDoApiWeb.UserView do
  use GtdToDoApiWeb, :view
  alias GtdToDoApiWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email,
      password_hash: user.password_hash,
      password: user.password,
      avatar_url: user.avatar_url}
  end
end
