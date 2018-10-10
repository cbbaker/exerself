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

  def process({:create_table, %{name: name, validator: validator_name, args: args}}, {tables, validators, create_list}) do
    {:ok, table} = Table.start_link()
    {Map.put(tables, name, table), validators, [{name, String.to_existing_atom(validator_name), [name, table] ++ args} | create_list]}
  end

  def process({:create_table, %{name: name}}, {tables, validators, create_list}) do
    {:ok, table} = Table.start_link()
    {Map.put(tables, name, table), validators, [{name, Repo.Validators.AutoIncrement, [name, table]} | create_list]}
  end

  def process({:delete_table, %{name: name}}, {tables, validators, create_list}) do
    {table, new_tables} = Map.pop(tables, name)
    Table.stop(table)
    {validator, new_validators} = Map.pop(validators, name)
    Validator.stop(validator)
    {new_tables, new_validators, create_list}
  end

  def process({:create_entry, %{table: table, entry: entry}}, {tables, _, _} = acc) do
    tables |> Map.get(table) |> Table.create(entry)
    acc
  end

  def process({:update_entry, %{table: table, entry: entry}}, {tables, _, _} = acc) do
    tables |> Map.get(table) |> Table.update(entry)
    acc
  end

  def process({:delete_entry, %{table: table, entry: entry}}, {tables, _, _} = acc) do
    tables |> Map.get(table) |> Table.delete(entry)
    acc
  end

  def process(_event, acc) do
    acc
  end
  
  defp replay_log(%{logger: logger, log: log, tables: tables, validators: validators}) do
    logger.get_terms(log) |>
      Enum.reduce({tables, validators, []}, &process/2)
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
    {tables, validators, create_list} = Map.merge(state, %{tables: %{}, validators: %{}}) |> replay_log()
    new_validators = create_validators(validators, create_list)
    {:reply, :ok, Map.merge(state, %{tables: tables, validators: new_validators})}
  end

  def handle_info(:timeout, state) do
    {tables, validators, create_list} = replay_log(state)
    new_validators = create_validators(validators, create_list)
    {:noreply, Map.merge(state, %{tables: tables, validators: new_validators})}
  end

  def handle_info(msg, state) do
    {tables, validators, create_list} = process(msg, {state.tables, state.validators, []})
    new_validators = create_validators(validators, create_list)
    {:noreply, Map.merge(state, %{tables: tables, validators: new_validators})}
  end

  defp create_validators(validators, [{name, mod, args} | rest]) do
    {:ok, validator} = apply(mod, :start_link, args)
    create_validators(Map.put(validators, name, validator), rest)
  end

  defp create_validators(validators, []) do
    validators
  end
end
