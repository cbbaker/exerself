defmodule RepoTest do
  use ExUnit.Case

  require Repo

  # doctest Repo

  setup do
    Repo.TestLog.reset()
    Repo.Aggregates.TableList.reset()

    table = "stuff"
    Repo.blocking do: Repo.create_table(table)
    entry = Repo.blocking do: Repo.create_entry(table, %{data: "test"})

    [table: table, entry: entry]
  end

  test "creates a table" do
    Repo.blocking do: Repo.create_table("other")
    assert Repo.list_tables() |> Map.has_key?("other")
  end

  test "deletes a table", %{table: table} do
    assert Repo.list_tables() |> Map.has_key?(table)

    Repo.blocking do: Repo.delete_table(table)
    refute Repo.list_tables() |> Map.has_key?(table)
  end

  test "lists table entries", %{table: table, entry: entry} do
    assert [^entry] = Repo.list_entries(table, 5)
  end

  test "adds a table entry", %{table: table, entry: entry} do
    other = Repo.blocking do: Repo.create_entry(table, %{data: "other"})
    assert [^other, ^entry] = Repo.list_entries(table, 5)
  end

  test "updates a table entry", %{table: table, entry: %{id: id} = entry} do
    assert [^entry] = Repo.list_entries(table, 5)

    Repo.blocking do: Repo.update_entry(table, %{id: id, data: "updated"})
    assert [%{id: ^id, data: "updated"}] = Repo.list_entries(table, 5)
  end

  test "deletes a table entry", %{table: table, entry: %{id: id} = entry} do
    assert [^entry] = Repo.list_entries(table, 5)

    Repo.blocking do: Repo.delete_entry(table, %{id: id})
    assert [] = Repo.list_entries(table, 5)
  end
end
