defmodule GtdToDoApi.AccountsTest do
  use GtdToDoApi.DataCase

  alias GtdToDoApi.Accounts

  describe "users" do
    alias GtdToDoApi.Accounts.User

    @valid_attrs %{
      avatar_url: "some avatar_url",
      email: "some email",
      password: "some password"
    }
    @update_attrs %{
      avatar_url: "some updated avatar_url",
      email: "some updated email",
      password: "some updated password"
    }
    @invalid_attrs %{avatar_url: nil, email: nil, password: nil}

    test "list_users/0 returns all users" do
      %User{id: id} = user_fixture()
      assert [%User{id: ^id}] = Accounts.list_users()
    end

    test "get_user!/1 returns the user with given id" do
      %User{id: id} = user_fixture()
      assert %User{id: ^id} = Accounts.get_user!(id)
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.avatar_url == "some avatar_url"
      assert user.email == "some email"
      assert Bcrypt.verify_pass("some password", user.password_hash)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.avatar_url == "some updated avatar_url"
      assert user.email == "some updated email"

      assert Bcrypt.verify_pass("some updated password", user.password_hash)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user.avatar_url == "some avatar_url"
      assert user.email == "some email"
      assert Bcrypt.verify_pass("some password", user.password_hash)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
