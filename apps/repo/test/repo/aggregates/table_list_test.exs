defmodule Repo.Aggregates.TableListTest do
  use ExUnit.Case
  
  alias Repo.EventLog
  alias Repo.Aggregates.TableList
  alias Repo.Aggregates.Table

  setup do
    TableList.reset()
  end

  test "returns the current list of tables" do
    assert %{} = TableList.get()
  end

  test "creates a table" do
    EventLog.commit("create_table", %{name: "blah"})
    Process.sleep(10)
    assert %{"blah" => _pid} = TableList.get()
  end

  test "creates a table entry" do
    EventLog.commit("create_table", %{name: "blah"})
    EventLog.commit("create_entry", %{table: "blah", entry: %{data: "test"}})
    Process.sleep(10)
    assert [%{data: "test"}] = TableList.get() |> Map.get("blah") |> Table.list(0, 5)
  end

end
