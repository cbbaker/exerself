defmodule RepoTest do
  use ExUnit.Case
  # doctest Repo

  setup do
    Repo.TestLog.reset()
    Repo.Aggregates.TableList.reset()
  end

  test "lists existing tables" do
    assert %{} = Repo.list_tables()
  end

  test "creates a table" do
    Repo.create_table("stuff")
    Process.sleep(10)
    assert %{"stuff" => _pid} = Repo.list_tables()
  end

  test "lists table entries" do
    Repo.create_table("stuff")
    Process.sleep(10)
    assert [] = Repo.list_entries("stuff", 0, 5)
  end

  test "adds a table entry" do
    Repo.create_table("stuff")

    Repo.create_entry("stuff", %{data: "test"})
    Process.sleep(10)
    assert [%{data: "test"}] = Repo.list_entries("stuff", 0, 5)
  end

  test "updates a table entry" do
    Repo.create_table("stuff")

    Repo.create_entry("stuff", %{id: 5, data: "test"})
    Process.sleep(10)
    assert [%{id: 5, data: "test"}] = Repo.list_entries("stuff", 0, 5)

    Repo.update_entry("stuff", %{id: 5, data: "updated"})
    Process.sleep(10)
    assert [%{id: 5, data: "updated"}] = Repo.list_entries("stuff", 0, 5)
  end

  test "deletes a table entry" do
    Repo.create_table("stuff")
    Repo.create_entry("stuff", %{id: 5, data: "test"})
    Process.sleep(10)
    assert [%{id: 5, data: "test"}] = Repo.list_entries("stuff", 0, 5)

    Repo.delete_entry("stuff", %{id: 5})
    Process.sleep(10)
    assert [] = Repo.list_entries("stuff", 0, 5)
  end
end
