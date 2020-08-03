defmodule GtdToDoApiWeb.CollectionView do
  use GtdToDoApiWeb, :view
  alias GtdToDoApiWeb.CollectionView

  def render("index.json", %{collections: collections}) do
    %{collections: render_many(collections, CollectionView, "collection.json")}
  end

  def render("show.json", %{collection: collection}) do
    %{collection: render_one(collection, CollectionView, "collection.json")}
  end

  def render("collection.json", %{collection: collection}) do
    link = "/collections/#{collection.id}/lists"

    %{
      id: collection.id,
      title: collection.title,
      color: collection.color,
      bucket: collection.bucket_id,
      links: %{
        lists: link
      }
    }
  end
end
