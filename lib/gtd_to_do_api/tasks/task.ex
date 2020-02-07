defmodule GtdToDoApi.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :content, :string
    field :is_done, :boolean, default: false

    belongs_to :owner, GtdToDoApi.Accounts.User
    belongs_to :list, GtdToDoApi.Collections.List

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:content, :is_done])
    |> validate_required([:content, :is_done])
  end
end
