defmodule GtdToDoApi.CollectionsTest do
  use GtdToDoApi.DataCase

  alias GtdToDoApi.Collections
  alias GtdToDoApi.Accounts.User
  alias GtdToDoApi.Collections.Collection

  describe "collections" do
    @valid_attrs %{color: "some color", name: "some name"}
    @update_attrs %{color: "some updated color", name: "some updated name"}
    @invalid_attrs %{color: nil, name: nil}

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
      assert collection.name == "some name"
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
      assert collection.name == "some updated name"
    end

    test "update_collection/2 with invalid data returns error changeset" do
      owner = user_fixture()
      collection = collection_fixture(owner)

      assert {:error, %Ecto.Changeset{}} =
               Collections.update_collection(collection, @invalid_attrs)

      id = collection.id
      name = collection.name
      assert %Collection{id: ^id, name: ^name} = Collections.get_collection!(collection.id)
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

  describe "subcollection" do
    alias GtdToDoApi.Collections.Subcollection

    @valid_attrs %{color: "some color", name: "some name"}
    @update_attrs %{color: "some updated color", name: "some updated name"}
    @invalid_attrs %{color: nil, name: nil, collection_id: nil}

    test "list_subcollection/0 returns all subcollection" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      %Subcollection{id: subcollection_id} = subcollection_fixture(owner, collection)
      assert [%Subcollection{id: ^subcollection_id}] = Collections.list_subcollection()
    end

    test "get_subcollection!/1 returns the subcollection with given id" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      %Subcollection{id: subcollection_id} = subcollection_fixture(owner, collection)

      assert %Subcollection{id: ^subcollection_id} =
               Collections.get_subcollection!(subcollection_id)
    end

    test "create_subcollection/2 with valid data creates a subcollection" do
      owner = user_fixture()
      %Collection{id: collection_id} = collection_fixture(owner)

      attrs = Enum.into(%{collection_id: collection_id}, @valid_attrs)

      {:ok, subcollection} = Collections.create_subcollection(owner, attrs)

      assert subcollection.color == "some color"
      assert subcollection.name == "some name"
      assert subcollection.collection_id == collection_id
    end

    test "create_subcollection/2 with invalid data returns error changeset" do
      owner = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Collections.create_subcollection(owner, @invalid_attrs)
    end

    test "create_subcollection/2 returns error changeset if selected collection has wrong owner" do
      first_owner = user_fixture()
      second_owner = user_fixture(%{email: "some different email"})

      collection = collection_fixture(first_owner)
      attrs = Enum.into(%{collection_id: collection.id}, @valid_attrs)

      assert {:error, %Ecto.Changeset{}} = Collections.create_subcollection(second_owner, attrs)
    end

    test "update_subcollection/2 with valid data updates the subcollection" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      subcollection = subcollection_fixture(owner, collection)

      assert {:ok, %Subcollection{} = subcollection} =
               Collections.update_subcollection(subcollection, @update_attrs)

      assert subcollection.color == "some updated color"
      assert subcollection.name == "some updated name"
    end

    test "update_subcollection/2 with invalid data returns error changeset" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      subcollection = subcollection_fixture(owner, collection)

      assert {:error, %Ecto.Changeset{}} =
               Collections.update_subcollection(subcollection, @invalid_attrs)

      assert subcollection == Collections.get_subcollection!(subcollection.id)
    end

    test "delete_subcollection/1 deletes the subcollection" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      subcollection = subcollection_fixture(owner, collection)

      assert {:ok, %Subcollection{}} = Collections.delete_subcollection(subcollection)
      assert_raise Ecto.NoResultsError, fn -> Collections.get_subcollection!(subcollection.id) end
    end

    test "change_subcollection/1 returns a subcollection changeset" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      subcollection = subcollection_fixture(owner, collection)

      assert %Ecto.Changeset{} = Collections.change_subcollection(subcollection)
    end

    test "list_subcollections_from_collection/1 returns all subcollections from given collection" do
      owner = user_fixture()

      first_collection = collection_fixture(owner)
      second_collection = collection_fixture(owner)

      %Subcollection{id: first_subcollection_id} = subcollection_fixture(owner, first_collection)
      %Subcollection{id: second_subcollection_id} = subcollection_fixture(owner, first_collection)
      subcollection_fixture(owner, second_collection)

      listed_subcollections = Collections.list_subcollections_from_collection(first_collection)

      assert [
               %Subcollection{id: ^second_subcollection_id},
               %Subcollection{id: ^first_subcollection_id}
             ] = listed_subcollections

      assert 2 == Enum.count(listed_subcollections)
    end

    test "get_collection_subcollection/2 return subcollection with given id if in given collection" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      subcollection = subcollection_fixture(owner, collection)

      assert subcollection ==
               Collections.get_collection_subcollection(collection, subcollection.id)
    end
  end
end
