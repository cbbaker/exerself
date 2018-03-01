defmodule Repo.Aggregates.TableListTest do
  use ExUnit.Case
  
  alias Repo.EventLog
  alias Repo.Aggregates.TableList

  setup do
    TableList.reset()
  end

  test "returns the current list of tables" do
    assert [] = TableList.get()
  end

  test "creates a table" do
    EventLog.commit("create_table", %{name: "blah"})
    Process.sleep(10)
    assert [%{"blah" => _pid}] = TableList.get()
  end
end
