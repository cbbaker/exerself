defmodule RepoTest do
  use ExUnit.Case
  # doctest Repo

  defp sleep(), do: Process.sleep(10)

  setup do
    Repo.TestLog.reset()
    Repo.Aggregates.TableList.reset()

    table = "stuff"
    Repo.create_table(table)
    sleep()
    entry = Repo.create_entry(table, %{data: "test"})
    sleep()

    [table: table, entry: entry]
  end

  test "creates a table" do
    Repo.create_table("other")
    sleep()
    assert Repo.list_tables() |> Map.has_key?("other")
  end

  test "deletes a table", %{table: table} do
    assert Repo.list_tables() |> Map.has_key?(table)

    Repo.delete_table(table)
    sleep()
    refute Repo.list_tables() |> Map.has_key?(table)
  end

  test "lists table entries", %{table: table, entry: entry} do
    assert [^entry] = Repo.list_entries(table, 0, 5)
  end

  test "adds a table entry", %{table: table, entry: entry} do
    other = Repo.create_entry(table, %{data: "other"})
    sleep()
    assert [^other, ^entry] = Repo.list_entries(table, 0, 5)
  end

  test "updates a table entry", %{table: table, entry: %{id: id} = entry} do
    assert [^entry] = Repo.list_entries(table, 0, 5)

    Repo.update_entry(table, %{id: id, data: "updated"})
    sleep()
    assert [%{id: ^id, data: "updated"}] = Repo.list_entries(table, 0, 5)
  end

  test "deletes a table entry", %{table: table, entry: %{id: id} = entry} do
    assert [^entry] = Repo.list_entries(table, 0, 5)

    Repo.delete_entry(table, %{id: id})
    Process.sleep(10)
    assert [] = Repo.list_entries(table, 0, 5)
  end
end
