defmodule GtdToDoApi.ContainersTest do
  use GtdToDoApi.DataCase, async: true

  alias GtdToDoApi.Containers
  alias GtdToDoApi.Collections

  describe "buckets" do
    alias GtdToDoApi.Containers.Bucket

    @valid_attrs %{"color" => "some color", "title" => "some title"}
    @update_attrs %{"color" => "some updated color", "title" => "some updated title"}
    @invalid_attrs %{"color" => nil, "title" => nil}

    test "list_buckets/0 returns all buckets" do
      owner = user_fixture()
      %Bucket{id: bucket_id} = bucket_fixture(owner)
      assert [%Bucket{id: ^bucket_id}] = Containers.list_buckets()
    end

    test "list_user_buckets/1 returns all buckets for given user" do
      first_owner = user_fixture()
      second_owner = user_fixture(%{email: "different name"})

      %Bucket{id: bucket_id_1} = bucket_fixture(first_owner)
      %Bucket{id: bucket_id_2} = bucket_fixture(first_owner)
      bucket_fixture(second_owner)

      assert [
               %Bucket{id: ^bucket_id_1},
               %Bucket{id: ^bucket_id_2}
             ] = Containers.list_user_buckets(first_owner)

      assert Enum.count(Containers.list_user_buckets(first_owner)) == 2
    end

    test "get_bucket!/1 returns the bucket with given id" do
      owner = user_fixture()
      %Bucket{id: bucket_id} = bucket_fixture(owner)
      assert %Bucket{id: ^bucket_id} = Containers.get_bucket!(bucket_id)
    end

    test "get_user_bucket!/2 if data are correct returns the bucket with given id and owner_id" do
      owner = user_fixture()
      %Bucket{id: bucket_id} = bucket_fixture(owner)
      assert %Bucket{id: ^bucket_id} = Containers.get_user_bucket!(owner, bucket_id)
    end

    test "get_user_bucket!/2 if owner_id won't match return an error" do
      first_owner = user_fixture()
      second_owner = user_fixture(%{email: "different name"})

      %Bucket{id: bucket_id} = bucket_fixture(first_owner)

      assert_raise Ecto.NoResultsError, fn ->
        Containers.get_user_bucket!(second_owner, bucket_id)
      end
    end

    test "create_bucket/1 with valid data creates a bucket" do
      owner = user_fixture()
      assert {:ok, %Bucket{} = bucket} = Containers.create_bucket(owner, @valid_attrs)

      assert bucket.color == "some color"
      assert bucket.title == "some title"
    end

    test "create_bucket/1 assigns collections if they were sent" do
      owner = user_fixture()
      collection_params_1 = collection_params_fixture(owner)
      collection_params_2 = collection_params_fixture(owner)
      collection_params_3 = collection_params_fixture(owner)

      bucket_attrs =
        Enum.into(@valid_attrs, %{"collections" => [collection_params_1, collection_params_2]})

      assert {:ok, %Bucket{} = bucket} = Containers.create_bucket(owner, bucket_attrs)

      %{"id" => collection_id_1} = collection_params_1
      %{"id" => collection_id_2} = collection_params_2
      %{"id" => collection_id_3} = collection_params_3

      %{bucket_id: bucket_id_1} = Collections.get_collection!(collection_id_1)
      %{bucket_id: bucket_id_2} = Collections.get_collection!(collection_id_2)
      %{bucket_id: bucket_id_3} = Collections.get_collection!(collection_id_3)

      # Buckets are properly set
      assert bucket_id_1 == bucket.id
      assert bucket_id_2 == bucket.id
      assert bucket_id_3 == nil
    end

    test "create_bucket/1 with invalid data returns error changeset" do
      owner = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Containers.create_bucket(owner, @invalid_attrs)
    end

    test "update_bucket/2 with valid data updates the bucket" do
      owner = user_fixture()

      collection_params_1 = collection_params_fixture(owner)
      collection_params_2 = collection_params_fixture(owner)
      collection_params_3 = collection_params_fixture(owner)

      bucket_attrs =
        Enum.into(@valid_attrs, %{"collections" => [collection_params_1, collection_params_2]})

      bucket = bucket_fixture(owner, bucket_attrs)

      bucket_update_attrs = Enum.into(@update_attrs, %{"collections" => [collection_params_3]})

      assert {:ok, %Bucket{} = updated_bucket} =
               Containers.update_bucket(owner, bucket, bucket_update_attrs)

      %{"id" => collection_id_1} = collection_params_1
      %{"id" => collection_id_2} = collection_params_2
      %{"id" => collection_id_3} = collection_params_3

      %{bucket_id: bucket_id_1} = Collections.get_collection!(collection_id_1)
      %{bucket_id: bucket_id_2} = Collections.get_collection!(collection_id_2)
      %{bucket_id: bucket_id_3} = Collections.get_collection!(collection_id_3)

      updated_bucket = GtdToDoApi.Repo.preload(updated_bucket, [:collections])

      assert updated_bucket.title == "some updated title"
      assert updated_bucket.color == "some updated color"
      assert bucket_id_1 == nil
      assert bucket_id_2 == nil
      assert bucket_id_3 == updated_bucket.id
    end

    test "update_bucket/2 with invalid data returns error changeset" do
      owner = user_fixture()
      %Bucket{id: bucket_id} = bucket = bucket_fixture(owner)
      assert {:error, %Ecto.Changeset{}} = Containers.update_bucket(owner, bucket, @invalid_attrs)
      assert %Bucket{id: ^bucket_id} = Containers.get_bucket!(bucket_id)
    end

    test "delete_bucket/1 deletes the bucket and removes relationships" do
      owner = user_fixture()
      bucket = bucket_fixture(owner)
      assert {:ok, %Bucket{}} = Containers.delete_bucket(bucket)
      assert_raise Ecto.NoResultsError, fn -> Containers.get_bucket!(bucket.id) end
    end

    test "change_bucket/1 returns a bucket changeset" do
      owner = user_fixture()
      bucket = bucket_fixture(owner)
      assert %Ecto.Changeset{} = Containers.change_bucket(bucket)
    end
  end
end
