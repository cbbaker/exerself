defmodule Repo.Aggregates.TableListTest do
  use ExUnit.Case
  
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

  defp sleep() do
    Process.sleep(10)
  end

  @tag commits: [{:create_table, %{name: "stuff"}},
                 {:create_entry, %{table: "stuff", entry: %{id: 5, data: "data"}}}]
  test "updates the next_id of all tables on init" do
    sleep()
    assert TableList.get() |> Map.get("stuff") |> Table.next_id() == 6
  end

  test "returns the current list of tables" do
    assert %{} = TableList.get()
  end

  test "creates a table" do
    Repo.create_table("blah")
    sleep()
    assert TableList.get() |> Map.has_key?("blah")
  end

  test "deletes a table" do
    Repo.create_table("blah")
    sleep()
    assert TableList.get() |> Map.has_key?("blah")
    Repo.delete_table("blah")
    sleep()
    refute TableList.get() |> Map.has_key?("blah")
  end

  test "creates a table entry" do
    Repo.create_table("blah")
    sleep()
    entry = Repo.create_entry("blah", %{data: "test"})
    sleep()
    assert [^entry] = Repo.list_entries("blah", 0, 5)
  end

  test "updates a table entry" do
    Repo.create_table("blah")
    sleep()
    entry = Repo.create_entry("blah", %{data: "test"})
    sleep()
    assert [^entry] = Repo.list_entries("blah", 0, 5)

    Repo.update_entry("blah", %{id: entry.id, data: "updated"})
    sleep()
    %{id: id} = entry
    assert [%{id: ^id, data: "updated"}] = Repo.list_entries("blah", 0, 5)
  end

  test "deletes a table entry" do
    Repo.create_table("blah")
    sleep()
    entry = Repo.create_entry("blah", %{data: "test"})
    sleep()
    assert [^entry] = Repo.list_entries("blah", 0, 5)

    Repo.delete_entry("blah", %{id: entry.id})
    sleep()
    assert [] = Repo.list_entries("blah", 0, 5)
  end
end
