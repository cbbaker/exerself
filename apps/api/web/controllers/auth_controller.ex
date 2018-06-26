defmodule Api.AuthController do
  alias Api.Validate

  use Api.Web, :controller
  plug Ueberauth

  @test_password Application.get_env(:api, :test_password)

  def test_form(conn, _params) do
    render(conn, "test_form.html")
  end

  def test_login(conn, %{"auth" => %{"email" => email,
                                     "name" => name,
                                     "image" => image,
                                     "password" => password}}) do
    if password == @test_password do
      {:ok, user} = Validate.valid(%{email: email, name: name, image: image})
      conn
      |> put_session(:current_user, user)
      |> redirect(to: data_source_path(conn, :static, user.id))
    else
      conn
      |> redirect(to: "/")
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    IO.puts "google callback: #{inspect auth.info}"
    case Validate.valid(auth) do
      {:ok, info} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, info)
        |> redirect(to: data_source_path(conn, :static, info.id))
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  def delete(conn, _params) do
    conn |> put_session(:current_user, nil) |> redirect(to: page_path(conn, :index))
  end
end
