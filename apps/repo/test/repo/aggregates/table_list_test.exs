defmodule Repo.Aggregates.TableListTest do
  use ExUnit.Case
  
  alias Repo.Aggregates.TableList

  setup do
    TableList.reset()
  end

  test "returns the current list of tables" do
    assert %{} = TableList.get()
  end

  test "creates a table" do
    Repo.create_table("blah")
    Process.sleep(10)
    assert TableList.get() |> Map.has_key?("blah")
  end

  test "deletes a table" do
    Repo.create_table("blah")
    Process.sleep(10)
    assert TableList.get() |> Map.has_key?("blah")
    Repo.delete_table("blah")
    Process.sleep(10)
    refute TableList.get() |> Map.has_key?("blah")
  end

  test "creates a table entry" do
    Repo.create_table("blah")
    Repo.create_entry("blah", %{data: "test"})
    Process.sleep(10)
    assert [%{data: "test"}] = Repo.list_entries("blah", 0, 5)
  end

  test "updates a table entry" do
    Repo.create_table("blah")
    Repo.create_entry("blah", %{id: 6, data: "test"})
    Process.sleep(10)
    assert [%{id: 6, data: "test"}] = Repo.list_entries("blah", 0, 5)

    Repo.update_entry("blah", %{id: 6, data: "updated"})
    Process.sleep(10)
    assert [%{id: 6, data: "updated"}] = Repo.list_entries("blah", 0, 5)
  end

  test "deletes a table entry" do
    Repo.create_table("blah")
    Repo.create_entry("blah", %{id: 6, data: "test"})
    Process.sleep(10)
    assert [%{id: 6, data: "test"}] = Repo.list_entries("blah", 0, 5)

    Repo.delete_entry("blah", %{id: 6})
    Process.sleep(10)
    assert [] = Repo.list_entries("blah", 0, 5)
  end
end
