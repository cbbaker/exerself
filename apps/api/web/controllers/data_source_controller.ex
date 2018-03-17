defmodule Api.DataSourceController do
  use Api.Web, :controller

  def static(conn, _params) do
    data_sources = DataSource.list(100)
    render(conn, "index.html", data_sources: data_sources)
  end

  def index(conn, _params) do
    data_sources = DataSource.list(100)
    render(conn, "index.json", "data-sources": data_sources)
  end

  def show(conn, %{"id" => name}) do
    if !Enum.member?(DataSource.list(1000), name) do
      raise Api.NotFound
    end

    data_source = %{
      name: name,
      schema: DataSource.get_schema(name) |> Map.delete(:id),
      viewers: DataSource.get_viewers(name),
      editors: DataSource.get_editors(name),
      entries: DataSource.get_entries(name, 100)
    }
    
    render(conn, "show.json", data_source: data_source)
  end

  def create(conn, %{"data_source" => %{"name" => name,
                                        "schema" => schema,
                                        "viewers" => viewers,
                                        "editors" => editors}}) do
    DataSource.create(name, schema, viewers, editors)
    data_source = %{
      name: name,
      schema: schema,
      viewers: viewers,
      editors: editors,
      entries: []
    }
    conn
    |> put_status(:created)
    |> put_resp_header("location", data_source_path(conn, :show, name))
    |> render("show.json", data_source: data_source)
  end

  # TODO: implement delete--cbb 2018-03-17
  # def delete(conn, %{"id" => name}) do
  #   data_source = DataSource.delete(name)

  #   send_resp(conn, :no_content, "")
  # end
end
