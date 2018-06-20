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
  def all() do
    Stream.resource(
      fn -> Repo.list_entries("data_sources", @page_size + 1) end,
      fn
        (page) when is_nil(page) ->
          {:halt, nil}
        (page) ->
          retval = Enum.take(page, @page_size)
          if Enum.count(page) > @page_size do
            {get_names(retval),
             Repo.list_entries("data_sources", @page_size + 1, List.last(retval).id)}
          else
            {get_names(retval), nil}
          end
      end,
      fn _ -> nil end
    )
  end

  @doc """
  List data sources.

  ## Examples

      iex> DataSource.list(100)
      []

  """
  def list(count, last) do
    Repo.list_entries("data_sources", count, last) |> get_names()
  end

  def list(count) do
    Repo.list_entries("data_sources", count) |> get_names()
  end

  defp get_names(entries) do
    Enum.map(entries, &(&1.name))
  end

  def create(name, schema, viewers, editors) do
    Repo.create_entry("data_sources", %{name: name})

    Repo.create_table(schema_table_name(name))
    Repo.create_table(viewers_table_name(name))
    Repo.create_table(editors_table_name(name))
    Repo.blocking do: Repo.create_table(entries_table_name(name))

    Repo.create_entry(schema_table_name(name), schema)
    Enum.each(viewers, &(Repo.create_entry(viewers_table_name(name), &1)))
    Enum.each(editors, &(Repo.create_entry(editors_table_name(name), &1)))
  end

  def get_schema(name) do
    [schema] = Repo.list_entries(schema_table_name(name), 1000)
    schema
  end

  def get_viewers(name) do
    Repo.list_entries(viewers_table_name(name), 1000)
  end

  def get_editors(name) do
    Repo.list_entries(editors_table_name(name), 1000)
  end

  def get_entries(name, count, last) do
    Repo.list_entries(entries_table_name(name), count, last)
  end

  def get_entries(name, count) do
    Repo.list_entries(entries_table_name(name), count)
  end

  def create_entry(name, entry) do
    Repo.create_entry(entries_table_name(name), entry)
  end

  def update_entry(name, entry) do
    Repo.update_entry(entries_table_name(name), entry)
  end

  def delete_entry(name, entry) do
    Repo.delete_entry(entries_table_name(name), entry)
  end

  defp schema_table_name(name), do: {:data_source, :schema, name}
  defp viewers_table_name(name), do: {:data_source, :viewers, name}
  defp editors_table_name(name), do: {:data_source, :editors, name}
  defp entries_table_name(name), do: {:data_source, :entries, name}
end
