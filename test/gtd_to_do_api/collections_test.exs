defmodule GtdToDoApi.CollectionsTest do
  use GtdToDoApi.DataCase

  alias GtdToDoApi.Collections
  alias GtdToDoApi.Accounts.User
  alias GtdToDoApi.Collections.Collection

  describe "collections" do
    @valid_attrs %{"color" => "some color", "title" => "some title"}
    @update_attrs %{"color" => "some updated color", "title" => "some updated title"}
    @invalid_attrs %{"color" => nil, "title" => nil}

    test "list_collections/0 returns all collections" do
      owner = user_fixture()
      %Collection{id: id} = collection_fixture(owner)
      assert [%Collection{id: ^id}] = Collections.list_collections()
    end

    test "list_users_collections/1 returns all users collections" do
      owner = user_fixture()
      second_user = user_fixture(%{email: "second user"})
      %Collection{id: owners_collection_id} = collection_fixture(owner)
      collection_fixture(second_user)
      collections = Collections.list_users_collections(owner)

      assert 1 == Enum.count(collections)
      assert [%Collection{id: ^owners_collection_id}] = collections
    end

    test "list_non_bucket_collections/1 returns all users collections that don't have bucket_id" do
      owner = user_fixture()

      # Create collection for different user
      sneaky_user = user_fixture(%{email: "sneaky email"})
      collection_fixture(sneaky_user)

      # Create collection with bucket
      bucket = bucket_fixture(owner)
      collection_fixture(owner, Map.put(@valid_attrs, "bucket", bucket.id))

      # Create two collections without buckets and with correct user
      %Collection{id: collection_1_id} = collection_fixture(owner)
      %Collection{id: collection_2_id} = collection_fixture(owner)

      collections = Collections.list_non_bucket_collections(owner)

      assert [%{id: ^collection_1_id}, %{id: ^collection_2_id}] = collections
      assert 2 = Enum.count(collections)
    end

    test "list_bucket_collections/1 returns all collections with given bucket id" do
      owner = user_fixture()

      # Create collection for different user
      sneaky_user = user_fixture(%{email: "sneaky email"})
      collection_fixture(sneaky_user)

      # Create two collections without buckets and with correct user
      collection_fixture(owner)

      # Create collection with bucket
      bucket = bucket_fixture(owner)

      %Collection{id: collection_1_id} =
        collection_fixture(owner, Map.put(@valid_attrs, "bucket", bucket.id))

      %Collection{id: collection_2_id} =
        collection_fixture(owner, Map.put(@valid_attrs, "bucket", bucket.id))

      collections = Collections.list_bucket_collections(bucket)

      assert [%{id: ^collection_1_id}, %{id: ^collection_2_id}] = collections
      assert 2 = Enum.count(collections)
    end

    test "get_collection!/1 returns the collection with given id" do
      owner = user_fixture()
      %Collection{id: id} = collection_fixture(owner)
      assert %Collection{id: ^id} = Collections.get_collection!(id)
    end

    test "get_users_collection!/2 returns the collection if user and id are correct" do
      %User{id: owner_id} = owner = user_fixture()
      %Collection{id: collection_id} = collection_fixture(owner)

      assert %Collection{id: ^collection_id, owner_id: ^owner_id} =
               Collections.get_users_collection!(owner, collection_id)
    end

    test "get_users_collection!/2 returns error if user or id are wrong" do
      owner = user_fixture()
      second_user = user_fixture(%{email: "second user"})
      %Collection{id: collection_id} = collection_fixture(owner)

      assert nil == Collections.get_users_collection!(second_user, collection_id)
    end

    test "create_collection/1 with valid data creates a collection" do
      owner = user_fixture()

      assert {:ok, %Collection{} = collection} =
               Collections.create_collection(owner, @valid_attrs)

      assert collection.color == "some color"
      assert collection.title == "some title"
    end

    test "create_collection/1 with invalid data returns error changeset" do
      owner = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Collections.create_collection(owner, @invalid_attrs)
    end

    test "update_collection/2 with valid data updates the collection" do
      owner = user_fixture()
      collection = collection_fixture(owner)

      assert {:ok, %Collection{} = collection} =
               Collections.update_collection(collection, @update_attrs)

      assert collection.color == "some updated color"
      assert collection.title == "some updated title"
    end

    test "update_collection/2 with invalid data returns error changeset" do
      owner = user_fixture()
      collection = collection_fixture(owner)

      assert {:error, %Ecto.Changeset{}} =
               Collections.update_collection(collection, @invalid_attrs)

      id = collection.id
      title = collection.title
      assert %Collection{id: ^id, title: ^title} = Collections.get_collection!(collection.id)
    end

    test "delete_collection/1 deletes the collection" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      assert {:ok, %Collection{}} = Collections.delete_collection(collection)
      assert_raise Ecto.NoResultsError, fn -> Collections.get_collection!(collection.id) end
    end

    test "change_collection/1 returns a collection changeset" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      assert %Ecto.Changeset{} = Collections.change_collection(collection)
    end
  end

  describe "lists" do
    alias GtdToDoApi.Collections.List

    @valid_attrs %{color: "some color", title: "some title"}
    @update_attrs %{color: "some updated color", title: "some updated title"}
    @invalid_attrs %{color: nil, title: nil}

    test "list_lists/0 returns all lists" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      %List{id: list_id} = list_fixture(owner, collection)
      assert [%List{id: ^list_id}] = Collections.list_lists()
    end

    test "list_collection_lists/1 returns all lists for given collection" do
      owner = user_fixture()

      collection_1 = collection_fixture(owner)
      collection_2 = collection_fixture(owner)

      %List{id: list_id_1} = list_fixture(owner, collection_1)
      %List{id: list_id_2} = list_fixture(owner, collection_1)
      list_fixture(owner, collection_2)

      assert [
               %List{id: ^list_id_1},
               %List{id: ^list_id_2}
             ] = Collections.list_collection_lists(collection_1)

      assert Enum.count(Collections.list_collection_lists(collection_1)) == 2
    end

    test "get_list!/1 returns the list with given id" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      %List{id: list_id} = list_fixture(owner, collection)
      assert %List{id: ^list_id} = Collections.get_list!(list_id)
    end

    test "get_user_list!/2 returns the list with given collection and id" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      %List{id: list_id} = list_fixture(owner, collection)
      assert %List{id: ^list_id} = Collections.get_user_list!(owner, list_id)
    end

    test "create_list/3 with valid data creates a list" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      assert {:ok, %List{} = list} = Collections.create_list(owner, collection, @valid_attrs)
      assert list.color == "some color"
      assert list.title == "some title"
    end

    test "create_list/3 with invalid data returns error changeset" do
      owner = user_fixture()
      collection = collection_fixture(owner)

      assert {:error, %Ecto.Changeset{}} =
               Collections.create_list(owner, collection, @invalid_attrs)
    end

    test "update_list/2 with valid data updates the list" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      list = list_fixture(owner, collection)
      assert {:ok, %List{} = list} = Collections.update_list(list, @update_attrs)
      assert list.color == "some updated color"
      assert list.title == "some updated title"
    end

    test "update_list/2 with invalid data returns error changeset" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      %List{id: list_id} = list = list_fixture(owner, collection)
      assert {:error, %Ecto.Changeset{}} = Collections.update_list(list, @invalid_attrs)
      assert %List{id: ^list_id} = Collections.get_list!(list_id)
    end

    test "delete_list/1 deletes the list" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      list = list_fixture(owner, collection)
      assert {:ok, %List{}} = Collections.delete_list(list)
      assert_raise Ecto.NoResultsError, fn -> Collections.get_list!(list.id) end
    end

    test "change_list/1 returns a list changeset" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      list = list_fixture(owner, collection)
      assert %Ecto.Changeset{} = Collections.change_list(list)
    end
  end
end
