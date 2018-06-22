defmodule DataSource do
  require Repo

  @moduledoc """
  Documentation for DataSource.

  The DataSource module manages the data sources in the
  application. It uses the Repo to store data and metadata.
  """

  def create_or_update_user(info) do
    Repo.create_entry("users", info)
  end

  @page_size 20
  def all(%{id: owner_id}) do
    Stream.resource(
      fn -> Repo.list_entries("data_sources", @page_size + 1) end,
      fn
        (page) when is_nil(page) ->
          {:halt, nil}
        (page) ->
          retval = Enum.take(page, @page_size)
          if Enum.count(page) > @page_size do
            {get_names(retval, owner_id),
             Repo.list_entries("data_sources", @page_size + 1, List.last(retval).id)}
          else
            {get_names(retval, owner_id), nil}
          end
      end,
      fn _ -> nil end
    )
  end

  @doc """
  List data sources.

  ## Examples

      iex> DataSource.list(%{id: 1}, 100)
      []

  """
  def list(%{id: owner_id}, count, last) do
    Repo.list_entries("data_sources", count, last) |>
      get_names(owner_id)
  end

  def list(%{id: owner_id}, count) do
    Repo.list_entries("data_sources", count) |>
      get_names(owner_id)
  end

  defp get_names(entries, owner_id) do
    Enum.map(entries, &(&1.name)) |>
      Enum.filter(fn
        {_name, ^owner_id} -> true
        _ -> false 
      end) |>
      Enum.map(fn {name, _} -> name end)
  end

  def create(owner, base_name, schema, viewers, editors) do
    name = table_name(owner, base_name)
    Repo.create_entry("data_sources", %{name: name})

    Repo.create_table(schema_table_name(name))
    Repo.create_table(viewers_table_name(name))
    Repo.create_table(editors_table_name(name))
    Repo.blocking do: Repo.create_table(entries_table_name(name))

    Repo.create_entry(schema_table_name(name), schema)
    Enum.each(viewers, &(Repo.create_entry(viewers_table_name(name), &1)))
    Enum.each(editors, &(Repo.create_entry(editors_table_name(name), &1)))
  end

  def get_schema(owner, name) do
    [schema] = table_name(owner, name) |>
      schema_table_name() |> 
      Repo.list_entries(1000)
    schema
  end

  def get_viewers(owner, name) do
    table_name(owner, name) |>
      viewers_table_name() |> 
      Repo.list_entries(1000)
  end

  def get_editors(owner, name) do
    table_name(owner, name) |>
      editors_table_name() |> 
      Repo.list_entries(1000)
  end

  def get_entries(owner, name, count, last) do
    table_name(owner, name) |>
      entries_table_name() |> 
      Repo.list_entries(count, last)
  end

  def get_entries(owner, name, count) do
    table_name(owner, name) |>
      entries_table_name() |> 
      Repo.list_entries(count)
  end

  def create_entry(owner, name, entry) do
    table_name(owner, name) |>
      entries_table_name() |>
      Repo.create_entry(entry)
  end

  def update_entry(owner, name, entry) do
    table_name(owner, name) |>
      entries_table_name() |>
      Repo.update_entry(entry)
  end

  def delete_entry(owner, name, entry) do
    table_name(owner, name) |>
      entries_table_name() |>
      Repo.delete_entry(entry)
  end

  defp table_name(%{id: owner_id}, name), do: {name, owner_id}
  defp schema_table_name(name), do: {:data_source, :schema, name}
  defp viewers_table_name(name), do: {:data_source, :viewers, name}
  defp editors_table_name(name), do: {:data_source, :editors, name}
  defp entries_table_name(name), do: {:data_source, :entries, name}
end
