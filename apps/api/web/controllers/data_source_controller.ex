defmodule Api.DataSourceController do
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

  def static(conn, _params, _current_user) do
    data_sources = DataSource.list(100)
    render(conn, "index.html", data_sources: data_sources)
  end

  def index(conn, _params, _current_user) do
    data_sources = DataSource.list(100)
    render(conn, "index.json", data_sources: data_sources)
  end

  def show(conn, %{"id" => name} = params, _current_user) do
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
    
    render(conn, "show.json", data_source: data_source, data_sources: data_sources)
  end

  def create(conn, %{"data_source" => %{"name" => name,
                                        "schema" => schema,
                                        "viewers" => viewers,
                                        "editors" => editors}}, _current_user) do
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
