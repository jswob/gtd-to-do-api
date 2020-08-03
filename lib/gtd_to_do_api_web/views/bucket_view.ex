defmodule GtdToDoApiWeb.BucketView do
  use GtdToDoApiWeb, :view
  alias GtdToDoApiWeb.BucketView

  def render("index.json", %{buckets: buckets}) do
    %{buckets: render_many(buckets, BucketView, "bucket.json")}
  end

  def render("show.json", %{bucket: bucket}) do
    %{bucket: render_one(bucket, BucketView, "bucket.json")}
  end

  def render("bucket.json", %{bucket: bucket}) do
    link = "/buckets/#{bucket.id}/collections"

    %{
      id: bucket.id,
      title: bucket.title,
      color: bucket.color,
      links: %{
        collections: link
      }
    }
  end
end
