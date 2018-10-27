defmodule Repo.Validators.UpsertTest do
  use ExUnit.Case

  require Repo

  alias Repo.Aggregates.Table
  alias Repo.Validator

  setup do
    {:ok, table} = Table.start_link()
    Table.create(table, 2)      # bogus element
    ["asdf", "sdfg", "qwer"] |>
      Enum.with_index() |> 
      Enum.each(fn {name, id} -> Table.create(table, %{id: (id + 1), name: name, updated: false}) end)
    {:ok, validator} = Repo.Validators.Upsert.start_link("blah", table, :name)
    [validator: validator]
  end

  test "adds next id to the entry", %{validator: validator} do
    assert %{id: 4, name: "zxcv"} = Validator.create(validator, %{name: "zxcv"})
  end

  test "updates the entry if the key exists", %{validator: validator} do
    assert %{id: 3, name: "qwer"} = Validator.create(validator, %{name: "qwer", updated: true})
  end
end
