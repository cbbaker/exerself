defmodule Repo.Aggregates.TableList do
  use GenServer

  alias Repo.EventLog
  alias Repo.Aggregates.Table

  defstruct [:logger, :log, :tables]

  def start_link() do
    GenServer.start_link(__MODULE__, %Repo.Aggregates.TableList{tables: %{}}, name: TableList)
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
  
  defp replay_log(%{logger: logger, log: log, tables: tables}) do
    logger.get_terms(log) |>
      Enum.reduce(tables, &process/2) |> 
      init_next_ids()
  end

  defp init_next_ids(tables) do
    Map.values(tables) |> Enum.each(&Table.init_next_id/1)
    tables
  end

  def handle_call(:get, _from, state) do
    {:reply, state.tables, state}
  end

  def handle_call(:reset, _from, state) do
    new = replay_log(state)
    {:reply, :ok, Map.put(state, :tables, new)}
  end

  def handle_info(:timeout, state) do
    new = replay_log(state)
    {:noreply, Map.put(state, :tables, new)}
  end

  def handle_info(msg, state) do
    tables = process(msg, state.tables)
    {:noreply, Map.put(state, :tables, tables)}
  end
end
