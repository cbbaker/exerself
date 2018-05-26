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

  def list_entries(table, count, last) do
    TableList.get() |> Map.get(table) |> Table.list(count, last)
  end

  def list_entries(table, count) do
    TableList.get() |> Map.get(table) |> Table.list(count)
  end

  def create_entry(table, entry) do
    id = TableList.get() |> Map.get(table) |> Table.next_id()
    new = Map.put(entry, :id, id)
    EventLog.commit(:create_entry, %{table: table, entry: new})
    new
  end

  def update_entry(table, entry) do
    EventLog.commit(:update_entry, %{table: table, entry: entry})
  end

  def delete_entry(table, entry) do
    EventLog.commit(:delete_entry, %{table: table, entry: entry})
  end

  defmacro blocking(do: expression) do
    quote do
      Repo.blocking_call(fn -> unquote(expression) end)
    end
  end

  def blocking_call(thunk) do
    EventLog.subscribe()
    result = thunk.()
    receive do
      _ -> EventLog.unsubscribe()
    end
    result
  end
end
