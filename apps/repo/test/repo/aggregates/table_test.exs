defmodule Repo.Aggregates.TableTest do
  use ExUnit.Case

  alias Repo.Aggregates.Table

  setup do
    {:ok, pid} = Table.start_link()
    [pid: pid]
  end

  defp seed_table(%{pid: pid, num_entries: num_entries}) do
    Enum.each((1..num_entries), fn id ->
      Table.create(pid, %{id: id, name: "name: #{id}"})
    end)
    :ok
  end

  defp seed_table(_) do
    :ok
  end

  setup :seed_table

  test "lists the entries in the table", %{pid: pid} do
    assert [] = Table.list(pid, 5)
  end

  @tag num_entries: 50
  test "streams all the entries in the table", %{pid: pid} do
    assert length(Table.stream(pid)) == 50
  end

  test "adds an entry", %{pid: pid} do
    Table.create(pid, %{data: "test"})
    assert [%{data: "test"}] = Table.list(pid, 5)
  end

  test "updates an entry", %{pid: pid} do
    Table.create(pid, %{id: 6, data: "test"})
    Table.create(pid, %{id: 7, data: "don't change"})
    assert [%{id: 7, data: "don't change"}, %{id: 6, data: "test"}] = Table.list(pid, 5)
    Table.update(pid, %{id: 6, data: "updated"})
    assert [%{id: 7, data: "don't change"}, %{id: 6, data: "updated"}] = Table.list(pid, 5)
  end

  test "deletes an entry", %{pid: pid} do
    Table.create(pid, %{id: 6, data: "test"})
    Table.create(pid, %{id: 7, data: "don't change"})
    assert [%{id: 7, data: "don't change"}, %{id: 6, data: "test"}] = Table.list(pid, 5)
    Table.delete(pid, %{id: 6})
    assert [%{id: 7, data: "don't change"}] = Table.list(pid, 5)
  end
end
