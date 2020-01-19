defmodule GtdToDoApiWeb.ErrorView do
  use GtdToDoApiWeb, :view

  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  def render("401.json", %{message: message}) do
    %{errors: %{detail: message}}
  end
end
