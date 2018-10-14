defmodule Repo.Aggregates.LogProcessor do
  alias Repo.Aggregates.Table
  alias Repo.Validator

  def replay_log(%{logger: logger, log: log, tables: tables, validators: validators}) do
    {tables, validators, create_list} = logger.get_terms(log) |> Enum.reduce({tables, validators, []}, &process/2)
    %{tables: tables, validators: create_validators(validators, create_list)}
  end

  def process_entry(msg, state) do
    {tables, validators, create_list} = process(msg, {state.tables, state.validators, []})
    %{tables: tables, validators: create_validators(validators, create_list)}
  end

  defp process({:create_table, %{name: name, validator: validator_name, args: args}}, {tables, validators, create_list}) do
    {:ok, table} = Table.start_link()
    {Map.put(tables, name, table), validators, [{name, String.to_existing_atom(validator_name), [name, table] ++ args} | create_list]}
  end

  defp process({:create_table, %{name: name}}, {tables, validators, create_list}) do
    {:ok, table} = Table.start_link()
    {Map.put(tables, name, table), validators, [{name, Repo.Validators.AutoIncrement, [name, table]} | create_list]}
  end

  defp process({:delete_table, %{name: name}}, {tables, validators, create_list}) do
    {table, new_tables} = Map.pop(tables, name)
    Table.stop(table)
    {validator, new_validators} = Map.pop(validators, name)
    Validator.stop(validator)
    {new_tables, new_validators, create_list}
  end

  defp process({:create_entry, %{table: table, entry: entry}}, {tables, _, _} = acc) do
    tables |> Map.get(table) |> Table.create(entry)
    acc
  end

  defp process({:update_entry, %{table: table, entry: entry}}, {tables, _, _} = acc) do
    tables |> Map.get(table) |> Table.update(entry)
    acc
  end

  defp process({:delete_entry, %{table: table, entry: entry}}, {tables, _, _} = acc) do
    tables |> Map.get(table) |> Table.delete(entry)
    acc
  end

  defp process(_event, acc) do
    acc
  end

  defp create_validators(validators, [{name, mod, args} | rest]) do
    {:ok, validator} = apply(mod, :start_link, args)
    create_validators(Map.put(validators, name, validator), rest)
  end

  defp create_validators(validators, []) do
    validators
  end
end
