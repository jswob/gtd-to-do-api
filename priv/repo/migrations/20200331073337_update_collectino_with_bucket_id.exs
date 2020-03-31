defmodule GtdToDoApi.Repo.Migrations.UpdateCollectinoWithBucketId do
  use Ecto.Migration

  def change do
    alter table(:collections) do
      add :bucket_id, references(:buckets, on_delete: :nothing)
    end
  end
end
