defmodule Repo.Aggregates.TableList do
  use GenServer

  alias Repo.EventLog
  alias Repo.Aggregates.Table
  alias Repo.Aggregates.LogProcessor
  alias Repo.Validator

  defstruct [:logger, :log, :tables, :validators]

  def start_link() do
    state = %Repo.Aggregates.TableList{tables: %{}, validators: %{}}
    GenServer.start_link(__MODULE__, state, name: TableList)
  end

  def get() do
    GenServer.call(TableList, :get)
  end

  def find_table(name) do
    GenServer.call(TableList, {:find_table, name})
  end

  def find_validator(name) do
    GenServer.call(TableList, {:find_validator, name})
  end

  def reset() do
    GenServer.call(TableList, :reset)
  end

  def init(state) do
    {logger, log} = EventLog.subscribe()
    {:ok, Map.merge(state, %{logger: logger, log: log}), 0}
  end

  def terminate(reason, _state) do
    EventLog.unsubscribe()
    IO.puts("terminate: #{inspect reason} #{inspect self()}")
  end

  def handle_call(:get, _from, state) do
    {:reply, state.tables, state}
  end

  def handle_call({:find_table, name}, _from, state) do
    {:reply, Map.get(state.tables, name), state}
  end

  def handle_call({:find_validator, name}, _from, state) do
    {:reply, Map.get(state.validators, name), state}
  end

  def handle_call(:reset, _from, state) do
    Enum.each(state.validators, fn {_name, validator} ->
      Validator.stop(validator) 
    end)
    Enum.each(state.tables, fn {_name, table} ->
      Table.stop(table)
    end)
    updated = Map.merge(state, %{tables: %{}, validators: %{}}) |> LogProcessor.replay_log()
    {:reply, :ok, Map.merge(state, updated)}
  end

  def handle_info(:timeout, state) do
    updated = LogProcessor.replay_log(state)
    {:noreply, Map.merge(state, updated)}
  end

  def handle_info(msg, state) do
    updated = LogProcessor.process_entry(msg, state)
    {:noreply, Map.merge(state, updated)}
  end
end
