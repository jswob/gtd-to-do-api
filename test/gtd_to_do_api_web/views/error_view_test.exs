defmodule GtdToDoApiWeb.ErrorViewTest do
  use GtdToDoApiWeb.ConnCase, async: true

  alias GtdToDoApiWeb.ErrorView

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(ErrorView, "404.json", []) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 422.json" do
    bad_changeset = %Ecto.Changeset{errors: [{:key, {"detail", "dummy"}}]}

    assert render(ErrorView, "422.json", %{changeset: bad_changeset}) == %{
             errors: [%{key: "detail"}]
           }
  end

  test "renders 500.json" do
    assert render(ErrorView, "500.json", []) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
