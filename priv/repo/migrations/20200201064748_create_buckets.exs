defmodule GtdToDoApi.Repo.Migrations.CreateBuckets do
  use Ecto.Migration

  def change do
    create table(:buckets) do
      add :title, :string
      add :color, :string

      add :owner_id, references(:users, on_delete: :nothing)
      add :collections, references(:collections, on_delete: :nothing)

      timestamps()
    end

    create index(:buckets, [:owner_id])
    create index(:buckets, [:collections])
  end
end
