defmodule RepoTest do
  use ExUnit.Case
  # doctest Repo

  setup do
    Repo.TestLog.reset()
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
    assert [] = Repo.list_entries("stuff", 0, 5)
  end

  test "adds a table entry" do
    Repo.create_entry("stuff", %{data: "test"})
    assert [%{data: "test"}] = Repo.list_entries("stuff", 0, 5)
  end
end
