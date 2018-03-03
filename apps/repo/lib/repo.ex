defmodule Repo do
  alias Repo.EventLog
  alias Repo.Aggregates.TableList
  alias Repo.Aggregates.Table

  @moduledoc """
  EventSource-based repo for Exerself
  """

  @doc """
  Lists existing tables

  ## Examples

      iex> Repo.list_tables()
      [{"stuff", _pid}]

  """
  def list_tables() do
    TableList.get()
  end

  @doc """
  Creates a new table in the repo

  ## Examples

      iex> Repo.create_table("stuff")
      :ok

  """
  def create_table(name) do
    EventLog.commit(:create_table, %{name: name})
  end

  def delete_table(name) do
    EventLog.commit(:delete_table, %{name: name})
  end

  def list_entries(table, start, count) do
    TableList.get() |> Map.get(table) |> Table.list(start, count)
  end

  def create_entry(table, entry) do
    EventLog.commit(:create_entry, %{table: table, entry: entry})
  end

  def update_entry(table, entry) do
    EventLog.commit(:update_entry, %{table: table, entry: entry})
  end

  def delete_entry(table, entry) do
    EventLog.commit(:delete_entry, %{table: table, entry: entry})
  end
end
