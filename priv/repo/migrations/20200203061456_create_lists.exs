defmodule GtdToDoApi.Repo.Migrations.CreateLists do
  use Ecto.Migration

  def change do
    create table(:lists) do
      add :title, :string
      add :color, :string
      add :owner_id, references(:users, on_delete: :nothing)
      add :collection_id, references(:collections, on_delete: :nothing)

      timestamps()
    end

    create index(:lists, [:owner_id])
    create index(:lists, [:collection_id])
  end
end
