defmodule Repo.Aggregates.TableListTest do
  use ExUnit.Case
  
  alias Repo.Aggregates.TableList

  setup do
    TableList.reset()
  end

  defp sleep() do
    Process.sleep(10)
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
