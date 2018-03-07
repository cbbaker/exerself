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

  test "gets the next id and increments it", %{pid: pid} do
    assert Table.next_id(pid) == 1
    assert Table.next_id(pid) == 2
  end

  test "initializes next_id when empty", %{pid: pid} do
    Table.init_next_id(pid)
    assert Table.next_id(pid) == 1
  end

  test "initializes next_id when non-empty", %{pid: pid} do
    Table.create(pid, %{id: 5})
    Table.init_next_id(pid)
    assert Table.next_id(pid) == 6
  end

  test "adds an entry", %{pid: pid} do
    Table.create(pid, %{data: "test"})
    assert [%{data: "test"}] = Table.list(pid, 0, 5)
  end

  test "updates an entry", %{pid: pid} do
    Table.create(pid, %{id: 6, data: "test"})
    Table.create(pid, %{id: 7, data: "don't change"})
    assert [%{id: 7, data: "don't change"}, %{id: 6, data: "test"}] = Table.list(pid, 0, 5)
    Table.update(pid, %{id: 6, data: "updated"})
    assert [%{id: 7, data: "don't change"}, %{id: 6, data: "updated"}] = Table.list(pid, 0, 5)
  end

  test "deletes an entry", %{pid: pid} do
    Table.create(pid, %{id: 6, data: "test"})
    Table.create(pid, %{id: 7, data: "don't change"})
    assert [%{id: 7, data: "don't change"}, %{id: 6, data: "test"}] = Table.list(pid, 0, 5)
    Table.delete(pid, %{id: 6})
    assert [%{id: 7, data: "don't change"}] = Table.list(pid, 0, 5)
  end
end
