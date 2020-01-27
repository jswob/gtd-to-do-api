defmodule GtdToDoApi.Repo.Migrations.RemoveHasChildsFromCollection do
  use Ecto.Migration

  def change do
    alter table(:collections) do
      remove :has_childs
    end
  end
end
