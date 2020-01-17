defmodule GtdToDoApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :password_hash, :string
      add :avatar_url, :string

      timestamps()
    end
  end
end
