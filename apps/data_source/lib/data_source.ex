defmodule DataSource do
  @moduledoc """
  Documentation for DataSource.

  The DataSource module manages the data sources in the
  application. It uses the Repo to store data and metadata.
  """

  @doc """
  List data sources.

  ## Examples

      iex> DataSource.list(100)
      []

  """
  def list(count, start \\ 0) do
    Repo.list_entries("data_sources", start, count) |>
      Enum.map(&(&1.name))
  end

  def create(name, schema, viewers, editors) do
    Repo.create_entry("data_sources", %{name: name})

    Repo.create_table(schema_table_name(name))
    Repo.create_table(viewers_table_name(name))
    Repo.create_table(editors_table_name(name))
    Repo.create_table(entries_table_name(name))

    Process.sleep(10)

    Repo.create_entry(schema_table_name(name), schema)
    Enum.each(viewers, &(Repo.create_entry(viewers_table_name(name), &1)))
    Enum.each(editors, &(Repo.create_entry(editors_table_name(name), &1)))
  end

  def get_schema(name) do
    [schema] = Repo.list_entries(schema_table_name(name), 0, 1000)
    schema
  end

  def get_viewers(name) do
    Repo.list_entries(viewers_table_name(name), 0, 1000)
  end

  def get_editors(name) do
    Repo.list_entries(editors_table_name(name), 0, 1000)
  end

  def get_entries(name, count, start \\ 0) do
    Repo.list_entries(entries_table_name(name), start, count)
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
