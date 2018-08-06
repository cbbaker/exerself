defmodule Api.DataController do
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

  def static(conn, %{"data_source" => name} = params, current_user) do
    data_sources = DataSource.list(current_user, 1000)
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
    
    render(conn, "index.html", data_source: data_source, data_sources: data_sources)
  end

  def create(conn, %{"data_source_id" => name, "data" => data}, current_user) do
    entry = DataSource.create_entry(current_user, name, data)
    conn
    |> put_status(:created)
    |> put_resp_header("location", data_source_data_path(conn, :show, name, entry.id))
    |> render("show.json", name: name, data: entry)
  end

  def show(conn, %{"id" => id_string, "data_source_id" => name}, current_user) do
    {id, _} = Integer.parse(id_string)
    entry = DataSource.get_entries(current_user, name, 1000) |> Enum.find(&(&1.id == id))
    render(conn, "show.json", name: name, data: entry)
  end

  def update(conn, %{"data_source_id" => name, "id" => id_string, "data" => data_params}, current_user) do
    {id, _} = Integer.parse(id_string)
    entry = Map.put(data_params, :id, id)
    DataSource.update_entry(current_user, name, entry)
    render(conn, "show.json", name: name, data: entry)
  end

  def delete(conn, %{"id" => id_string, "data_source_id" => name}, current_user) do
    {id, _} = Integer.parse(id_string)
    DataSource.delete_entry(current_user, name, %{id: id})
    send_resp(conn, :no_content, "")
  end

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
