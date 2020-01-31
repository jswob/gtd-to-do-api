defmodule GtdToDoApi.Repo.Migrations.UpdateCollection do
  use Ecto.Migration

  def change do
    alter table(:collections) do
      remove :name
      add :title, :string
    end
  end
end
