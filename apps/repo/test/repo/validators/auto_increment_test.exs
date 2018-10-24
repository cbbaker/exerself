defmodule Repo.Validators.AutoIncrementTest do
  use ExUnit.Case

  alias Repo.Aggregates.Table
  alias Repo.Validator
  alias Repo.Validators.AutoIncrement

  setup do
    {:ok, table} = Table.start_link()
    [table: table]
  end

  test "adds the next id to the entry", %{table: table} do
    Enum.each((1..10), fn id -> Table.create(table, %{id: id}) end)
    {:ok, validator} = AutoIncrement.start_link("blah", table)

    assert %{id: 11} = Validator.create(validator, %{})
  end

  test "revalidate reassigns ids in order", %{table: table} do
    Enum.each((1..10), fn _ -> Table.create(table, %{}) end)
    {:ok, validator} = AutoIncrement.start_link("blah", table)

    assert [%{id: 1}, %{id: 2}, %{id: 3}, %{id: 4}, %{id: 5}, %{id: 6}, %{id: 7}, %{id: 8}, %{id: 9}, %{id: 10}] =
      Validator.revalidate(validator, Table.stream(table))
  end
end
