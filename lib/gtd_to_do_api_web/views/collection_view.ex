defmodule GtdToDoApiWeb.CollectionView do
  use GtdToDoApiWeb, :view
  alias GtdToDoApiWeb.CollectionView

  def render("index.json", %{collections: collections}) do
    %{data: render_many(collections, CollectionView, "collection.json")}
  end

  def render("show.json", %{collection: collection}) do
    %{data: render_one(collection, CollectionView, "collection.json")}
  end

  def render("collection.json", %{collection: collection}) do
    %{
      id: collection.id,
      name: collection.name,
      color: collection.color,
      has_childs: collection.has_childs
    }
  end
end
