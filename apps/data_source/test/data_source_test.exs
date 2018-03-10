defmodule DataSourceTest do
  use ExUnit.Case
  doctest DataSource

  setup do
    Repo.TestLog.reset()
    Repo.create_table("data_sources")
    Process.sleep(10)
  end

  test "lists the data sources" do
    assert DataSource.list(5) == []
  end

  test "adds a data source" do
    DataSource.create("test", %{}, [], [])
    assert DataSource.list(5) == ["test"]
  end

  test "gets the schema" do
    DataSource.create("test", %{"startedAt" => "date"}, [], [])
    assert %{"startedAt" => "date"} = DataSource.get_schema("test")
  end

  test "gets the viewers" do
    DataSource.create("test", %{}, [%{"viewer1" => "stuff"}], [])
    assert [%{"viewer1" => "stuff"}] = DataSource.get_viewers("test")
  end

  test "gets the editors" do
    DataSource.create("test", %{}, [], [%{"editor1" => "stuff"}])
    assert [%{"editor1" => "stuff"}] = DataSource.get_editors("test")
  end

  test "gets the entries" do
    DataSource.create("test", %{"field" => "int"}, [], [])
    assert DataSource.get_entries("test", 100) == []
  end

  test "creates an entry" do
    DataSource.create("test", %{"field" => "int"}, [], [])
    entry = DataSource.create_entry("test", %{"field" => 3})
    assert [^entry] = DataSource.get_entries("test", 100)
  end

  test "updates an entry" do
    DataSource.create("test", %{"field" => "int"}, [], [])
    entry = DataSource.create_entry("test", %{"field" => 3})
    assert [^entry] = DataSource.get_entries("test", 100)
    new_entry = Map.put(entry, "field", 4)
    DataSource.update_entry("test", new_entry)
    Process.sleep(10)
    assert [^new_entry] = DataSource.get_entries("test", 100)
  end

  test "deletes an entry" do
    DataSource.create("test", %{"field" => "int"}, [], [])
    entry = DataSource.create_entry("test", %{"field" => 3})
    assert [^entry] = DataSource.get_entries("test", 100)
    DataSource.delete_entry("test", entry)
    Process.sleep(10)
    assert [] = DataSource.get_entries("test", 100)
  end
end
