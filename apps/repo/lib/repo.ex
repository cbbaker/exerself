defmodule Repo do
  @moduledoc """
  EventSource-based repo for Exerself
  """

  @doc """
  Creates a new table in the repo

  ## Examples

      iex> Repo.create_table("stuff")
      {:table, "stuff"}

  """
  def create_table(name) do
    {:table, name}
  end
end
