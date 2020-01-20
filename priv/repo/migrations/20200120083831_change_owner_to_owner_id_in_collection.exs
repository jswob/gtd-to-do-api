defmodule GtdToDoApi.Repo.Migrations.ChangeOwnerToOwnerIdInCollection do
  use Ecto.Migration

  def change do
    alter table(:collections) do
      remove :owner
      add :owner_id, references(:users, on_delete: :nothing)
    end
  end
end
