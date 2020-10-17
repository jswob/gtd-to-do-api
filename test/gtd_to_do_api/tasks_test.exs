defmodule GtdToDoApi.TasksTest do
  use GtdToDoApi.DataCase

  alias GtdToDoApi.Tasks

  describe "tasks" do
    alias GtdToDoApi.Tasks.Task

    @valid_attrs %{"content" => "some content", "is_done" => false}
    @update_attrs %{"content" => "some updated content", "is_done" => true}
    @invalid_attrs %{"content" => nil, "is_done" => nil}

    test "list_tasks/0 returns all tasks" do
      %{task: %Task{id: task_id}} = task_fixture()
      assert [%Task{id: ^task_id}] = Tasks.list_tasks()
    end

    test "list_list_tasks/1 returns all tasks for given list" do
      %{task: %Task{id: task_id}, list: list} = task_fixture()
      assert [%Task{id: ^task_id}] = Tasks.list_list_tasks(list)
    end

    test "get_task!/1 returns the task with given id" do
      %{task: %Task{id: task_id}} = task_fixture()
      assert %Task{id: ^task_id} = Tasks.get_task!(task_id)
    end

    test "get_user_task!/1 returns the task with given id and owner" do
      %{task: %Task{id: task_id}, owner: owner} = task_fixture()
      assert %Task{id: ^task_id} = Tasks.get_user_task!(owner, task_id)
    end

    test "create_task/1 with valid data creates a task" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      list = list_fixture(owner, collection)

      assert {:ok, %Task{} = task} = Tasks.create_task(owner, list, @valid_attrs)
      assert task.content == "some content"
      assert task.is_done == false
    end

    test "create_task/1 with invalid data returns error changeset" do
      owner = user_fixture()
      collection = collection_fixture(owner)
      list = list_fixture(owner, collection)

      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(owner, list, @invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      %{task: task} = task_fixture()
      assert {:ok, %Task{} = task} = Tasks.update_task(task, @update_attrs)
      assert task.content == "some updated content"
      assert task.is_done == true
    end

    test "update_task/2 with invalid data returns error changeset" do
      %{task: %Task{id: task_id, content: task_content, is_done: task_is_done} = task} =
        task_fixture()

      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, @invalid_attrs)

      assert %Task{id: ^task_id, content: ^task_content, is_done: ^task_is_done} =
               Tasks.get_task!(task_id)
    end

    test "delete_task/1 deletes the task" do
      %{task: task} = task_fixture()
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      %{task: task} = task_fixture()
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end
  end
end
