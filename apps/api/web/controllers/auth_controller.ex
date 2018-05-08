defmodule Api.AuthController do
  alias Api.Validate
  alias Api.Guardian

  use Api.Web, :controller
  plug Ueberauth

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: %{info: %{name: name, email: email, image: image}}}} = conn,
                 _params) do
    IO.puts "google callback: #{inspect auth.info}"
    conn = Guardian.Plug.sign_in(conn, %{name: name, email: email, image: image})
    case Validate.valid(auth) do
      {:ok, info} ->
        redirect(conn, to: data_source_path(conn, :static))
      {:error, reason} ->
        redirect(conn, to: "/")
    end
  end

  def delete(conn, _params) do
    conn |> Guardian.Plug.sign_out() |> redirect(to: page_path(conn, :index))
  end
end
