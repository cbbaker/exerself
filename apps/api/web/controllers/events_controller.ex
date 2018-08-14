defmodule Api.EventsController do
  use Api.Web, :controller

  alias Api.Validate

  plug :put_layout, "admin.html"

  def action(%{assigns: %{current_user: current_user}} = conn, _) when not is_nil(current_user) do
    if Validate.valid(current_user) && current_user.id == 1 do
      apply(__MODULE__, action_name(conn), [conn, conn.params, current_user])
    else
      conn
      |> put_status(:forbidden)
      |> render("error.html", message: "You don't have access to this resource")
    end
  end

  def action(conn, _) do
    redirect(conn, to: page_path(conn, :index))
  end

  def index(conn, _params, _current_user) do
    {logger, log} = Repo.EventLog.subscribe()
    terms = logger.get_terms(log) |> Enum.reverse() |> Enum.take(2000)
    render(conn, "index.html", terms: terms)
  end

end
