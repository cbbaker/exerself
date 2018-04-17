defmodule Api.DataSourceController do
  use Api.Web, :controller

  def static(conn, _params) do
    data_sources = DataSource.list(100)
    render(conn, "index.html", data_sources: data_sources)
  end

  def index(conn, _params) do
    data_sources = DataSource.list(100)
    render(conn, "index.json", data_sources: data_sources)
  end

  def show(conn, %{"id" => name} = params) do
    data_sources = DataSource.list(1000)
    if !Enum.member?(data_sources, name) do
      raise Api.NotFound
    end

    data_source = %{
      name: name,
      schema: DataSource.get_schema(name) |> Map.delete(:id),
      viewers: DataSource.get_viewers(name),
      editors: DataSource.get_editors(name),
      entries: get_entries(name, params)
    }
    
    render(conn, "show.json", data_source: data_source, data_sources: data_sources)
  end

  defp get_entries(name, %{"count" => count_string, "last" => last_string}) do
    {count, _} = Integer.parse(count_string)
    {last, _} = Integer.parse(last_string)
    entries_plus_one = DataSource.get_entries(name, count + 1, last)
    entries = Enum.take(entries_plus_one, count)
    next_page = if length(entries_plus_one) > count do
      %{"count" => count, "last" => List.last(entries).id}
    end
    {entries, next_page}
  end

  defp get_entries(name, %{"count" => count_string}) do
    {count, _} = Integer.parse(count_string)
    entries_plus_one = DataSource.get_entries(name, count + 1)
    entries = Enum.take(entries_plus_one, count)
    next_page = if length(entries_plus_one) > count do
      %{"count" => count, "last" => List.last(entries).id}
    end
    {entries, next_page}
  end

  defp get_entries(name, _) do
    get_entries(name, %{"count" => "20"})
  end

  def create(conn, %{"data_source" => %{"name" => name,
                                        "schema" => schema,
                                        "viewers" => viewers,
                                        "editors" => editors}}) do
    data_sources = DataSource.list(1000)
    DataSource.create(name, schema, viewers, editors)
    data_source = %{
      name: name,
      schema: schema,
      viewers: viewers,
      editors: editors,
      entries: {[], nil}
    }
    conn
    |> put_status(:created)
    |> put_resp_header("location", data_source_path(conn, :show, name))
    |> render("show.json", data_source: data_source, data_sources: data_sources)
  end

  # TODO: implement delete--cbb 2018-03-17
  # def delete(conn, %{"id" => name}) do
  #   data_source = DataSource.delete(name)

  #   send_resp(conn, :no_content, "")
  # end
end
