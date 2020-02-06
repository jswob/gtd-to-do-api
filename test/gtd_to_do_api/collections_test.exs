defmodule GtdToDoApi.CollectionsTest do
  use GtdToDoApi.DataCase

  alias GtdToDoApi.Collections
  alias GtdToDoApi.Accounts.User
  alias GtdToDoApi.Collections.Collection

  describe "collections" do
    @valid_attrs %{color: "some color", title: "some title"}
    @update_attrs %{color: "some updated color", title: "some updated title"}
    @invalid_attrs %{color: nil, title: nil}

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

  # describe "subcollection" do
  #   alias GtdToDoApi.Collections.Subcollection

  #   @valid_attrs %{color: "some color", name: "some name"}
  #   @update_attrs %{color: "some updated color", name: "some updated name"}
  #   @invalid_attrs %{color: nil, name: nil, collection_id: nil}

  #   test "list_subcollection/0 returns all subcollection" do
  #     owner = user_fixture()
  #     collection = collection_fixture(owner)
  #     %Subcollection{id: subcollection_id} = subcollection_fixture(owner, collection)
  #     assert [%Subcollection{id: ^subcollection_id}] = Collections.list_subcollection()
  #   end

  #   test "get_subcollection!/1 returns the subcollection with given id" do
  #     owner = user_fixture()
  #     collection = collection_fixture(owner)
  #     %Subcollection{id: subcollection_id} = subcollection_fixture(owner, collection)

  #     assert %Subcollection{id: ^subcollection_id} =
  #              Collections.get_subcollection!(subcollection_id)
  #   end

  #   test "create_subcollection/2 with valid data creates a subcollection" do
  #     owner = user_fixture()
  #     %Collection{id: collection_id} = collection_fixture(owner)

  #     attrs = Enum.into(%{collection_id: collection_id}, @valid_attrs)

  #     {:ok, subcollection} = Collections.create_subcollection(owner, attrs)

  #     assert subcollection.color == "some color"
  #     assert subcollection.name == "some name"
  #     assert subcollection.collection_id == collection_id
  #   end

  #   test "create_subcollection/2 with invalid data returns error changeset" do
  #     owner = user_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Collections.create_subcollection(owner, @invalid_attrs)
  #   end

  #   test "create_subcollection/2 returns error changeset if selected collection has wrong owner" do
  #     first_owner = user_fixture()
  #     second_owner = user_fixture(%{email: "some different email"})

  #     collection = collection_fixture(first_owner)
  #     attrs = Enum.into(%{collection_id: collection.id}, @valid_attrs)

  #     assert {:error, %Ecto.Changeset{}} = Collections.create_subcollection(second_owner, attrs)
  #   end

  #   test "update_subcollection/2 with valid data updates the subcollection" do
  #     owner = user_fixture()
  #     collection = collection_fixture(owner)
  #     subcollection = subcollection_fixture(owner, collection)

  #     assert {:ok, %Subcollection{} = subcollection} =
  #              Collections.update_subcollection(subcollection, @update_attrs)

  #     assert subcollection.color == "some updated color"
  #     assert subcollection.name == "some updated name"
  #   end

  #   test "update_subcollection/2 with invalid data returns error changeset" do
  #     owner = user_fixture()
  #     collection = collection_fixture(owner)
  #     subcollection = subcollection_fixture(owner, collection)

  #     assert {:error, %Ecto.Changeset{}} =
  #              Collections.update_subcollection(subcollection, @invalid_attrs)

  #     assert subcollection == Collections.get_subcollection!(subcollection.id)
  #   end

  #   test "delete_subcollection/1 deletes the subcollection" do
  #     owner = user_fixture()
  #     collection = collection_fixture(owner)
  #     subcollection = subcollection_fixture(owner, collection)

  #     assert {:ok, %Subcollection{}} = Collections.delete_subcollection(subcollection)
  #     assert_raise Ecto.NoResultsError, fn -> Collections.get_subcollection!(subcollection.id) end
  #   end

  #   test "change_subcollection/1 returns a subcollection changeset" do
  #     owner = user_fixture()
  #     collection = collection_fixture(owner)
  #     subcollection = subcollection_fixture(owner, collection)

  #     assert %Ecto.Changeset{} = Collections.change_subcollection(subcollection)
  #   end

  #   test "list_subcollections_from_collection/1 returns all subcollections from given collection" do
  #     owner = user_fixture()

  #     first_collection = collection_fixture(owner)
  #     second_collection = collection_fixture(owner)

  #     %Subcollection{id: first_subcollection_id} = subcollection_fixture(owner, first_collection)
  #     %Subcollection{id: second_subcollection_id} = subcollection_fixture(owner, first_collection)
  #     subcollection_fixture(owner, second_collection)

  #     listed_subcollections = Collections.list_subcollections_from_collection(first_collection)

  #     assert [
  #              %Subcollection{id: ^second_subcollection_id},
  #              %Subcollection{id: ^first_subcollection_id}
  #            ] = listed_subcollections

  #     assert 2 == Enum.count(listed_subcollections)
  #   end

  #   test "get_collection_subcollection/2 return subcollection with given id if in given collection" do
  #     owner = user_fixture()
  #     collection = collection_fixture(owner)
  #     subcollection = subcollection_fixture(owner, collection)

  #     assert subcollection ==
  #              Collections.get_collection_subcollection(collection, subcollection.id)
  #   end
  # end

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
               %List{id: ^list_id_2},
               %List{id: ^list_id_1}
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
      assert %List{id: ^list_id} = Collections.get_collection_list!(owner, list_id)
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
