defmodule GtdToDoApi.Repo.Migrations.CreateSubcollection do
  use Ecto.Migration

  def change do
    create table(:subcollection) do
      add :name, :string
      add :color, :string
      add :owner_id, references(:users, on_delete: :nothing)
      add :collection_id, references(:collections, on_delete: :nothing)

      timestamps()
    end

    create index(:subcollection, [:owner_id])
    create index(:subcollection, [:collection_id])
  end
end
