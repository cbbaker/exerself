defmodule Repo.Validators.AutoIncrementTest do
  use ExUnit.Case

  alias Repo.Aggregates.Table
  alias Repo.Validator
  alias Repo.Validators.AutoIncrement

  setup do
    {:ok, table} = Table.start_link()
    Enum.each((1..10), fn id -> Table.create(table, %{id: id}) end)
    {:ok, validator} = AutoIncrement.start_link("blah", table)
    [validator: validator]
  end

  test "adds the next id to the entry", %{validator: validator} do
    assert %{id: 11} = Validator.create(validator, %{})
  end
end
