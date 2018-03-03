defmodule Repo.Aggregates.TableList do
  use GenServer

  alias Repo.EventLog
  alias Repo.Aggregates.Table

  defstruct [:logger, :log, :tables]

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: TableList)
  end

  def get() do
    GenServer.call(TableList, :get)
  end

  def reset() do
    GenServer.call(TableList, :reset)
  end

  def init(state) do
    {logger, log} = EventLog.subscribe()
    {:ok, Map.merge(state, %{logger: logger, log: log}), 0}
  end

  def process({:create_table, %{name: name}}, acc) do
    {:ok, pid} = Table.start_link()
    Map.put(acc, name, pid)
  end

  def process({:delete_table, %{name: name}}, acc) do
    {pid, new} = Map.pop(acc, name)
    Table.stop(pid)
    new
  end

  def process({:create_entry, %{table: table, entry: entry}}, acc) do
    acc |> Map.get(table) |> Table.create(entry)
    acc
  end

  def process({:update_entry, %{table: table, entry: entry}}, acc) do
    acc |> Map.get(table) |> Table.update(entry)
    acc
  end

  def process({:delete_entry, %{table: table, entry: entry}}, acc) do
    acc |> Map.get(table) |> Table.delete(entry)
    acc
  end

  def process(_event, acc) do
    acc
  end
  

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:reset, _from, _state) do
    {:reply, %{}, %{}}
  end

  def handle_info(:timeout, %{logger: logger, log: log, tables: tables} = state) do
    new = logger.get_terms(log) |> Enum.reduce(tables, &process/2)
    {:noreply, Map.put(state, :tables, new)}
  end

  def handle_info(msg, state) do
    {:noreply, process(msg, state)}
  end
end
