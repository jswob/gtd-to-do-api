defmodule GtdToDoApi.Repo.Migrations.CreateCollections do
  use Ecto.Migration

  def change do
    create table(:collections) do
      add :name, :string
      add :color, :string
      add :has_childs, :boolean, default: false, null: false
      add :owner, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:collections, [:owner])
  end
end
