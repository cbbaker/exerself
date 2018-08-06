defmodule Api.DataSourceController do
  use Api.Web, :controller
  alias Api.Pagination
  alias Api.Validate

  def action(%{assigns: %{current_user: current_user}} = conn, _) when not is_nil(current_user) do
    if Validate.valid(current_user) do
      apply(__MODULE__, action_name(conn), [conn, conn.params, current_user])
    else
      not_authorized(conn, action_name(conn), "You don't have access to this resource")
    end
  end

  def action(conn, _) do
    not_authenticated(conn, action_name(conn), "You must be logged in to do this")
  end

  def static(conn, _params, current_user) do
    data_sources = DataSource.list(current_user, 100)
    render(conn, "index.html", data_sources: Enum.take(data_sources, 20))
  end

  def index(conn, _params, current_user) do
    data_sources = DataSource.list(current_user, 100)
    render(conn, "index.json", data_sources: Enum.take(data_sources, 20))
  end

  def show(conn, %{"id" => name} = params, current_user) do
    data_sources = DataSource.all(current_user)
    if !Enum.member?(data_sources, name) do
      raise Api.NotFound
    end

    data_source = %{
      name: name,
      schema: DataSource.get_schema(current_user, name) |> Map.delete(:id),
      viewers: DataSource.get_viewers(current_user, name),
      editors: DataSource.get_editors(current_user, name),
      entries: Pagination.get_entries(current_user, name, params)
    }
    
    render(conn, "show.json", data_source: data_source, data_sources: Enum.take(data_sources, 20))
  end

  def create(conn, %{"data_source" => %{"name" => name,
                                        "schema" => schema,
                                        "viewers" => viewers,
                                        "editors" => editors}}, current_user) do
    data_sources = DataSource.list(current_user, 20)
    DataSource.create(current_user, name, schema, viewers, editors)
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

  defp not_authenticated(conn, :static, _message) do
    redirect(conn, to: page_path(conn, :index))
  end

  defp not_authenticated(conn, _action, message) do
    conn
    |> render("auth.json", message: message)
  end

  defp not_authorized(conn, :static, message) do
    conn
    |> put_status(:forbidden)
    |> render("error.html", message: message)
  end

  defp not_authorized(conn, _action, message) do
    conn
    |> put_status(:forbidden)
    |> json(%{message: message})
  end
end
