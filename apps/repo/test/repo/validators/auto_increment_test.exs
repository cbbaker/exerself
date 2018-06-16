defmodule Repo.Validators.AutoIncrementTest do
  use ExUnit.Case

  alias Repo.Aggregates.Table
  alias Repo.Validators.AutoIncrement

  setup do
    {:ok, table} = Table.start_link()
    Enum.each((1..10), fn id -> Table.create(table, %{id: id}) end)
    {:ok, pid} = AutoIncrement.start_link(table)
    [pid: pid]
  end

  test "adds the next id to the entry", %{pid: pid} do
    assert %{id: 11} = AutoIncrement.create(pid, "blah", %{})
  end
end
