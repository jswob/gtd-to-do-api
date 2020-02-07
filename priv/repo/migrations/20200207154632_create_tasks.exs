defmodule GtdToDoApi.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :content, :string
      add :is_done, :boolean, default: false, null: false
      add :owner_id, references(:user, on_delete: :nothing)
      add :list_id, references(:lists, on_delete: :nothing)

      timestamps()
    end

    create index(:tasks, [:owner_id])
    create index(:tasks, [:list_id])
  end
end
