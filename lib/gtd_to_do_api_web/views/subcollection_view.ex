defmodule GtdToDoApiWeb.SubcollectionView do
  use GtdToDoApiWeb, :view
  alias GtdToDoApiWeb.SubcollectionView

  def render("index.json", %{subcollection: subcollection}) do
    %{data: render_many(subcollection, SubcollectionView, "subcollection.json")}
  end

  def render("show.json", %{subcollection: subcollection}) do
    %{data: render_one(subcollection, SubcollectionView, "subcollection.json")}
  end

  def render("subcollection.json", %{subcollection: subcollection}) do
    %{
      id: subcollection.id,
      name: subcollection.name,
      color: subcollection.color,
      collection_id: subcollection.id,
      owner_id: subcollection.owner_id
    }
  end
end
