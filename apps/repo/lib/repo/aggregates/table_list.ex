defmodule Repo.Aggregates.TableList do
  use GenServer

  alias Repo.EventLog
  alias Repo.Aggregates.Table
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
    IO.puts("terminate: #{inspect reason} #{inspect self()}")
  end

  def process({:create_table, %{name: name, validator: validator_name}}, {tables, validators}) do
    {:ok, table} = Table.start_link()
    {:ok, validator} = apply(String.to_existing_atom(validator_name), :start_link, [name, table])
    {Map.put(tables, name, table), Map.put(validators, name, validator)}
  end

  def process({:create_table, %{name: name}}, {tables, validators}) do
    {:ok, table} = Table.start_link()
    {:ok, validator} = Repo.Validators.AutoIncrement.start_link(name, table)
    {Map.put(tables, name, table), Map.put(validators, name, validator)}
  end

  def process({:delete_table, %{name: name}}, {tables, validators}) do
    {table, new_tables} = Map.pop(tables, name)
    Table.stop(table)
    {validator, new_validators} = Map.pop(validators, name)
    Validator.stop(validator)
    {new_tables, new_validators}
  end

  def process({:create_entry, %{table: table, entry: entry}}, {tables, _} = acc) do
    tables |> Map.get(table) |> Table.create(entry)
    acc
  end

  def process({:update_entry, %{table: table, entry: entry}}, {tables, _} = acc) do
    tables |> Map.get(table) |> Table.update(entry)
    acc
  end

  def process({:delete_entry, %{table: table, entry: entry}}, {tables, _} = acc) do
    tables |> Map.get(table) |> Table.delete(entry)
    acc
  end

  def process(_event, acc) do
    acc
  end
  
  defp replay_log(%{logger: logger, log: log, tables: tables, validators: validators}) do
    logger.get_terms(log) |>
      Enum.reduce({tables, validators}, &process/2)
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
    {tables, validators} = Map.merge(state, %{tables: %{}, validators: %{}}) |> replay_log()
    {:reply, :ok, Map.merge(state, %{tables: tables, validators: validators})}
  end

  def handle_info(:timeout, state) do
    {tables, validators} = replay_log(state)
    {:noreply, Map.merge(state, %{tables: tables, validators: validators})}
  end

  def handle_info(msg, state) do
    {tables, validators} = process(msg, {state.tables, state.validators})
    {:noreply, Map.merge(state, %{tables: tables, validators: validators})}
  end
end
