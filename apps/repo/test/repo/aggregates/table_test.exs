defmodule Repo.Aggregates.TableTest do
  use ExUnit.Case

  alias Repo.Aggregates.Table

  setup do
    {:ok, pid} = Table.start_link()
    [pid: pid]
  end

  test "lists the entries in the table", %{pid: pid} do
    assert [] = Table.list(pid, 0, 5)
  end

  test "adds an entry", %{pid: pid} do
    Table.create(pid, %{data: "test"})
    assert [%{data: "test"}] = Table.list(pid, 0, 5)
  end
end
