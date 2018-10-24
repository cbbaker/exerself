defmodule Repo.Aggregates.LogProcessor do
  alias Repo.Aggregates.Table
  alias Repo.Validator

  def replay_log(%{logger: logger, log: log, tables: tables, validators: validators}) do
    {tables, validators, deferred_actions} = logger.get_terms(log) |> Enum.reduce({tables, validators, []}, &process/2)
    Enum.reverse(deferred_actions) |> do_deferred(tables, validators)
  end

  def process_entry(msg, state) do
    {tables, validators, deferred_actions} = process(msg, {state.tables, state.validators, []})
    Enum.reverse(deferred_actions) |> do_deferred(tables, validators)
  end

  defp process({:create_table, %{name: name, validator: validator_name, args: args}}, {tables, validators, deferred_actions}) do
    {:ok, table} = Table.start_link()
    {Map.put(tables, name, table), 
     validators,
     [{:create_validator, name, String.to_existing_atom(validator_name), [name, table] ++ args} | deferred_actions]
    }
  end

  defp process({:create_table, %{name: name}}, {tables, validators, deferred_actions}) do
    {:ok, table} = Table.start_link()
    {Map.put(tables, name, table),
     validators,
     [{:create_validator, name, Repo.Validators.AutoIncrement, [name, table]} | deferred_actions]
    }
  end

  defp process({:delete_table, %{name: name}}, {tables, validators, deferred_actions}) do
    {table, new_tables} = Map.pop(tables, name)
    Table.stop(table)
    {validator, new_validators} = Map.pop(validators, name)
    Validator.stop(validator)
    {new_tables, new_validators, deferred_actions}
  end

  defp process({:revalidate_table, %{name: name}}, {tables, validators, deferred_actions}) do
    {tables, validators, [{:revalidate_table, name} | deferred_actions]}
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

  defp do_deferred([{:create_validator, name, mod, args} | rest], tables, validators) do
    {:ok, validator} = apply(mod, :start_link, args)
    do_deferred(rest, tables, Map.put(validators, name, validator))
  end

  defp do_deferred([{:revalidate_table, name} | rest], tables, validators) do
    table = Map.get(tables, name)
    validator = Map.get(validators, name)
    Table.revalidate(table, validator)
    do_deferred(rest, tables, validators)
  end

  defp do_deferred([], tables, validators) do
    %{tables: tables, validators: validators}
  end
end
