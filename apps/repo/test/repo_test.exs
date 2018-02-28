defmodule RepoTest do
  use ExUnit.Case
  doctest Repo

  test "creates a table" do
    assert Repo.create_table("stuff") == {:table, "stuff"}
  end
end
