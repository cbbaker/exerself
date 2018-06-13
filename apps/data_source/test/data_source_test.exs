defmodule DataSourceTest do
  use ExUnit.Case
  doctest DataSource

  require Repo

  setup do
    Repo.TestLog.reset()
    Repo.blocking do: Repo.create_table("data_sources")
    :ok
  end

  defp create_fixtures(%{create_count: create_count}) do
    1..create_count |> Enum.each(fn i -> DataSource.create("test#{i}", %{"startedAt" => "date"}, [], []) end)
    :ok
  end

  defp create_fixtures(_) do
    :ok
  end

  setup :create_fixtures

  # test "creates or updates a user" do
  #   email = "test@test.com"
  #   stuff = "nonsense"
  #   assert %{id: 1, email: ^email, stuff: ^stuff} =
  #     DataSource.create_or_update_user(%{email: email, stuff: stuff})
  # end

  @tag create_count: 50
  test "streams the data sources" do
    assert DataSource.all() |> Enum.count() == 50
  end

  @tag create_count: 10
  test "lists the data sources" do
    assert DataSource.list(5) |> Enum.count() == 5
  end

  test "adds a data source" do
    Repo.blocking do: DataSource.create("test", %{}, [], [])
    assert DataSource.list(5) == ["test"]
  end

  test "gets the schema" do
    Repo.blocking do: DataSource.create("test", %{"startedAt" => "date"}, [], [])
    assert %{"startedAt" => "date"} = DataSource.get_schema("test")
  end

  test "gets the viewers" do
    Repo.blocking do: DataSource.create("test", %{}, [%{"viewer1" => "stuff"}], [])
    assert [%{"viewer1" => "stuff"}] = DataSource.get_viewers("test")
  end

  test "gets the editors" do
    Repo.blocking do: DataSource.create("test", %{}, [], [%{"editor1" => "stuff"}])
    assert [%{"editor1" => "stuff"}] = DataSource.get_editors("test")
  end

  test "gets the entries" do
    Repo.blocking do: DataSource.create("test", %{"field" => "int"}, [], [])
    assert DataSource.get_entries("test", 100) == []
  end

  test "creates an entry" do
    DataSource.create("test", %{"field" => "int"}, [], [])
    entry = Repo.blocking do: DataSource.create_entry("test", %{"field" => 3})
    assert [^entry] = DataSource.get_entries("test", 100)
  end

  test "updates an entry" do
    DataSource.create("test", %{"field" => "int"}, [], [])
    entry = Repo.blocking do: DataSource.create_entry("test", %{"field" => 3})
    assert [^entry] = DataSource.get_entries("test", 100)
    new_entry = Map.put(entry, "field", 4)
    Repo.blocking do: DataSource.update_entry("test", new_entry)
    assert [^new_entry] = DataSource.get_entries("test", 100)
  end

  test "deletes an entry" do
    DataSource.create("test", %{"field" => "int"}, [], [])
    entry = Repo.blocking do: DataSource.create_entry("test", %{"field" => 3})
    assert [^entry] = DataSource.get_entries("test", 100)
    Repo.blocking do: DataSource.delete_entry("test", entry)
    assert [] = DataSource.get_entries("test", 100)
  end
end
