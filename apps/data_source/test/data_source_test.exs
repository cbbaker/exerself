defmodule DataSourceTest do
  use ExUnit.Case
  doctest DataSource

  require Repo

  setup do
    Repo.TestLog.reset()
    Repo.create_table("users", Repo.Validators.Upsert, [:email])
    Repo.blocking do: Repo.create_table("data_sources")
    user = DataSource.create_or_update_user(%{email: "bob@bob.net"})
    %{user: user}
  end

  defp create_fixtures(%{user: user, create_count: create_count}) do
    1..create_count |> Enum.each(fn
      i -> DataSource.create(user, "test#{i}", %{"startedAt" => "date"}, [], []) 
    end)
    :ok
  end

  defp create_fixtures(_) do
    :ok
  end

  setup :create_fixtures

  test "creates or updates a user" do
    email = "test@test.com"
    stuff = "nonsense"
    assert %{id: 2, email: ^email, stuff: ^stuff} =
      DataSource.create_or_update_user(%{email: email, stuff: stuff})
    assert %{id: 2, email: ^email, stuff: ^stuff} =
      DataSource.create_or_update_user(%{email: email, stuff: stuff})
  end

  @tag create_count: 50
  test "streams the data sources", %{user: user} do
    assert DataSource.all(user) |> Enum.count() == 50
  end

  @tag create_count: 10
  test "lists the data sources", %{user: user} do
    assert DataSource.list(user, 5) |> Enum.count() == 5
  end

  test "adds a data source", %{user: user} do
    Repo.blocking do: DataSource.create(user, "test", %{}, [], [])
    assert DataSource.list(user, 5) == ["test"]
  end

  test "gets the schema", %{user: user} do
    Repo.blocking do: DataSource.create(user, "test", %{"startedAt" => "date"}, [], [])
    assert %{"startedAt" => "date"} = DataSource.get_schema(user, "test")
  end

  test "gets the viewers", %{user: user} do
    Repo.blocking do: DataSource.create(user, "test", %{}, [%{"viewer1" => "stuff"}], [])
    assert [%{"viewer1" => "stuff"}] = DataSource.get_viewers(user, "test")
  end

  test "gets the editors", %{user: user} do
    Repo.blocking do: DataSource.create(user, "test", %{}, [], [%{"editor1" => "stuff"}])
    assert [%{"editor1" => "stuff"}] = DataSource.get_editors(user, "test")
  end

  test "gets the entries", %{user: user} do
    Repo.blocking do: DataSource.create(user, "test", %{"field" => "int"}, [], [])
    assert DataSource.get_entries(user, "test", 100) == []
  end

  test "creates an entry", %{user: user} do
    DataSource.create(user, "test", %{"field" => "int"}, [], [])
    entry = Repo.blocking do: DataSource.create_entry(user, "test", %{"field" => 3})
    assert [^entry] = DataSource.get_entries(user, "test", 100)
  end

  test "updates an entry", %{user: user} do
    DataSource.create(user, "test", %{"field" => "int"}, [], [])
    entry = Repo.blocking do: DataSource.create_entry(user, "test", %{"field" => 3})
    assert [^entry] = DataSource.get_entries(user, "test", 100)
    new_entry = Map.put(entry, "field", 4)
    Repo.blocking do: DataSource.update_entry(user, "test", new_entry)
    assert [^new_entry] = DataSource.get_entries(user, "test", 100)
  end

  test "deletes an entry", %{user: user} do
    DataSource.create(user, "test", %{"field" => "int"}, [], [])
    entry = Repo.blocking do: DataSource.create_entry(user, "test", %{"field" => 3})
    assert [^entry] = DataSource.get_entries(user, "test", 100)
    Repo.blocking do: DataSource.delete_entry(user, "test", entry)
    assert [] = DataSource.get_entries(user, "test", 100)
  end
end
