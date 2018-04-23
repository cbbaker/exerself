defmodule Api.DataController do
  use Api.Web, :controller
  alias Api.Pagination
  alias Api.Validate

  def action(%{assigns: %{current_user: current_user}} = conn, _) when not is_nil(current_user) do
    if Validate.valid(current_user) do
      apply(__MODULE__, action_name(conn), [conn, conn.params, current_user])
    else
      not_authorized(conn, "You don't have access to this resource")
    end
  end

  def action(conn, _) do
    not_authorized(conn, "You must be logged in to do this")
  end

  def static(conn, %{"data_source" => name} = params, _current_user) do
    data_sources = DataSource.list(1000)
    if !Enum.member?(data_sources, name) do
      raise Api.NotFound
    end

    data_source = %{
      name: name,
      schema: DataSource.get_schema(name) |> Map.delete(:id),
      viewers: DataSource.get_viewers(name),
      editors: DataSource.get_editors(name),
      entries: Pagination.get_entries(name, params)
    }
    
    render(conn, "index.html", data_source: data_source, data_sources: data_sources)
  end

  def create(conn, %{"data_source_id" => name, "data" => data}, _current_user) do
    entry = DataSource.create_entry(name, data)
    conn
    |> put_status(:created)
    |> put_resp_header("location", data_source_data_path(conn, :show, name, entry.id))
    |> render("show.json", name: name, data: entry)
  end

  def show(conn, %{"id" => id_string, "data_source_id" => name}, _current_user) do
    {id, _} = Integer.parse(id_string)
    entry = DataSource.get_entries(name, 1000) |> Enum.find(&(&1.id == id))
    render(conn, "show.json", name: name, data: entry)
  end

  def update(conn, %{"data_source_id" => name, "id" => id_string, "data" => data_params}, _current_user) do
    {id, _} = Integer.parse(id_string)
    entry = Map.put(data_params, :id, id)
    DataSource.update_entry(name, entry)
    render(conn, "show.json", name: name, data: entry)
  end

  def delete(conn, %{"id" => id_string, "data_source_id" => name}, _current_user) do
    {id, _} = Integer.parse(id_string)
    DataSource.delete_entry(name, %{id: id})
    send_resp(conn, :no_content, "")
  end

  defp not_authorized(conn, message) do
    if accepts_json(conn) do
      conn
      |> put_status(:forbidden)
      |> json(%{message: message})
    else
      conn
      |> put_status(:forbidden)
      |> render("error.html", message: message)
    end
  end

  defp accepts_json(%{req_headers: req_headers}) do
    req_headers |> List.keyfind("accept", 0) |> test_headers()
  end

  defp test_headers({"accept", "application/json"}), do: true
  defp test_headers(_), do: false
end
