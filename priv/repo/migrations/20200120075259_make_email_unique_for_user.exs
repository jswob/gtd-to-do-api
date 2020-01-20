defmodule GtdToDoApi.Repo.Migrations.MakeEmailUniqueForUser do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:email])
  end
end
