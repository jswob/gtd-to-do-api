defmodule GtdToDoApiWeb.ErrorView do
  use GtdToDoApiWeb, :view

  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  def render("401.json", %{message: message}) do
    %{errors: %{detail: message}}
  end

  def render("422.json", %{changeset: changeset}) do
    errors =
      Enum.map(changeset.errors, fn error ->
        {key, {detail, _}} = error

        %{key => detail}
      end)

    %{errors: errors}
  end
end
