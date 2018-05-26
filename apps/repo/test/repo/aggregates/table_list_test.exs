defmodule Repo.Aggregates.TableListTest do
  use ExUnit.Case
  require Repo
  
  alias Repo.Aggregates.TableList
  alias Repo.Aggregates.Table
  alias TestLog

  setup context do
    Repo.TestLog.reset()
    if context[:commits] do
      Enum.each(context[:commits], fn commit -> Repo.TestLog.write(TestLog, commit) end)
    end
    TableList.reset()
  end

  @tag commits: [{:create_table, %{name: "stuff"}},
                 {:create_entry, %{table: "stuff", entry: %{id: 5, data: "data"}}}]
  test "updates the next_id of all tables on init" do
    assert TableList.get() |> Map.get("stuff") |> Table.next_id() == 6
  end

  test "returns the current list of tables" do
    assert %{} = TableList.get()
  end

  test "creates a table" do
    Repo.blocking do: Repo.create_table("blah")
    assert TableList.get() |> Map.has_key?("blah")
  end

  test "deletes a table" do
    Repo.blocking do: Repo.create_table("blah")
    assert TableList.get() |> Map.has_key?("blah")
    Repo.blocking do: Repo.delete_table("blah")
    refute TableList.get() |> Map.has_key?("blah")
  end

  test "creates a table entry" do
    Repo.blocking do: Repo.create_table("blah")
    entry = Repo.blocking do: Repo.create_entry("blah", %{data: "test"})
    assert [^entry] = Repo.list_entries("blah", 5)
  end

  test "updates a table entry" do
    Repo.blocking do: Repo.create_table("blah")
    entry = Repo.blocking do: Repo.create_entry("blah", %{data: "test"})
    assert [^entry] = Repo.list_entries("blah", 5)

    Repo.blocking do: Repo.update_entry("blah", %{id: entry.id, data: "updated"})
    %{id: id} = entry
    assert [%{id: ^id, data: "updated"}] = Repo.list_entries("blah", 5)
  end

  test "deletes a table entry" do
    Repo.blocking do: Repo.create_table("blah")
    entry = Repo.blocking do: Repo.create_entry("blah", %{data: "test"})
    assert [^entry] = Repo.list_entries("blah", 5)

    Repo.blocking do: Repo.delete_entry("blah", %{id: entry.id})
    assert [] = Repo.list_entries("blah", 5)
  end
end
