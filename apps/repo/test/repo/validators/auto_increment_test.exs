defmodule Repo.Validators.AutoIncrementTest do
  use ExUnit.Case

  alias Repo.Validators.AutoIncrement

  setup do
    {:ok, pid} = AutoIncrement.start_link()
    [pid: pid]
  end

  test "adds the next id to the entry", %{pid: pid} do
    assert %{id: 1} = AutoIncrement.create(pid, "blah", %{})
  end

  test "sets the next id", %{pid: pid} do
    AutoIncrement.set_next_id(pid, 10)
    assert %{id: 10} = AutoIncrement.create(pid, "blah", %{})
  end
end
