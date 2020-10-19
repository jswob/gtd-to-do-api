defmodule GtdToDoApi.Repo.Migrations.ModifyRelationshipsWithDeleteAll do
  use Ecto.Migration

  def change do
    drop index(:buckets, [:owner_id])
    alter table(:buckets) do
      remove :owner_id

      add :owner_id, references(:users, on_delete: :delete_all)
    end
    create index(:buckets, [:owner_id])

    drop_if_exists index(:collections, [:owner_id])
    drop_if_exists index(:collections, [:bucket_id])
    alter table(:collections) do
      remove :owner_id
      remove :bucket_id

      add :owner_id, references(:users, on_delete: :delete_all)
      add :bucket_id, references(:buckets, on_delete: :delete_all)
    end
    create index(:collections, [:owner_id])
    create index(:collections, [:bucket_id])

    drop index(:lists, [:owner_id])
    drop index(:lists, [:collection_id])
    alter table(:lists) do
      remove :owner_id
      remove :collection_id

      add :owner_id, references(:users, on_delete: :delete_all)
      add :collection_id, references(:collections, on_delete: :delete_all)
    end
    create index(:lists, [:owner_id])
    create index(:lists, [:collection_id])

    drop index(:tasks, [:owner_id])
    drop index(:tasks, [:list_id])
    alter table(:tasks) do
      remove :owner_id
      remove :list_id

      add :owner_id, references(:users, on_delete: :delete_all)
      add :list_id, references(:lists, on_delete: :delete_all)
    end
    create index(:tasks, [:owner_id])
    create index(:tasks, [:list_id])
  end


end
