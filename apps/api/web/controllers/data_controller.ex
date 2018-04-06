defmodule Api.DataController do
  use Api.Web, :controller

  def static(conn, %{"data_source" => name}) do
    data_sources = DataSource.list(1000)
    if !Enum.member?(data_sources, name) do
      raise Api.NotFound
    end

    data_source = %{
      name: name,
      schema: DataSource.get_schema(name) |> Map.delete(:id),
      viewers: DataSource.get_viewers(name),
      editors: DataSource.get_editors(name),
      entries: DataSource.get_entries(name, 100)
    }
    
    render(conn, "index.html", data_source: data_source, data_sources: data_sources)
  end

  def create(conn, %{"data_source_id" => name, "data" => data}) do
    entry = DataSource.create_entry(name, data)
    conn
    |> put_status(:created)
    |> put_resp_header("location", data_source_data_path(conn, :show, name, entry.id))
    |> render("show.json", name: name, data: entry)
  end

  def show(conn, %{"id" => id_string, "data_source_id" => name}) do
    {id, _} = Integer.parse(id_string)
    entry = DataSource.get_entries(name, 1000) |> Enum.find(&(&1.id == id))
    render(conn, "show.json", name: name, data: entry)
  end

  def update(conn, %{"data_source_id" => name, "id" => id_string, "data" => data_params}) do
    {id, _} = Integer.parse(id_string)
    entry = Map.put(data_params, :id, id)
    DataSource.update_entry(name, entry)
    render(conn, "show.json", name: name, data: entry)
  end

  def delete(conn, %{"id" => id_string, "data_source_id" => name}) do
    {id, _} = Integer.parse(id_string)
    DataSource.delete_entry(name, %{id: id})
    send_resp(conn, :no_content, "")
  end
end
