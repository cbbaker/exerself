defmodule Import do
  use HTTPoison.Base

  def process_url(path) do
    Application.get_env(:import, :exerself_url) <> path
  end

  def import() do
    Repo.create_table("data_sources")
    cookies = sign_in()
    get_stationary_bike_rides(cookies) |> import_stationary_bike_rides()
    get_road_bike_rides(cookies) |> import_road_bike_rides()
  end

  def get_token() do
    %{body: body, headers: headers} = get!("/users/sign_in")
    [token] = body |> Floki.find("input[name='authenticity_token']") |> Floki.attribute("value")
    cookies = get_cookies(headers)
    {token, cookies}
  end

  def sign_in() do
    email = Application.get_env(:import, :exerself_user)
    password = Application.get_env(:import, :exerself_password)
    {token, cookies} = get_token()
    form = [{"user[email]", email},
            {"user[password]", password},
            {"authenticity_token", token}]
    headers = [{"Accept", "text/html"}]
    %{headers: headers} = post!("/users/sign_in", {:form, form}, set_cookies(cookies, headers))
    get_cookies(headers)
  end

  def get_stationary_bike_rides(cookies) do
    %{body: body} = get!("/users/1/stationary_bike_rides", set_cookies(cookies, [{"Accept", "application/json"}]))
    Poison.decode!(body)
  end

  def get_road_bike_rides(cookies) do
    %{body: body} = get!("/users/1/road_bike_rides", set_cookies(cookies, [{"Accept", "application/json"}]))
    Poison.decode!(body)
  end

  def import_stationary_bike_rides(rides) do
    DataSource.create("stationary_bike_rides", %{"started_at" => "date",
                                                 "duration" => "int",
                                                 "power" => "int",
                                                 "heart_rate" => "int",
                                                 "notes" => "text"},
      [], [])
    Enum.reverse(rides) |> Enum.map(&(DataSource.create_entry("stationary_bike_rides", &1)))
  end

  def import_road_bike_rides(rides) do
    DataSource.create("road_bike_rides", %{"started_at" => "date",
                                           "duration" => "int",
                                           "distance" => "float",
                                           "heart_rate" => "int",
                                           "notes" => "text"},
      [], [])
    Enum.reverse(rides) |> Enum.map(&(DataSource.create_entry("road_bike_rides", &1)))
  end

  def get_cookies(headers) do
    get_cookies(headers, [])
  end

  defp get_cookies([], result), do: result

  defp get_cookies([{"Set-Cookie", cookie} | rest], result), do: get_cookies(rest, [cookie | result])

  defp get_cookies([_ | rest], result), do: get_cookies(rest, result)

  def set_cookies(cookies, headers \\ [])
  def set_cookies([], headers), do: headers
  def set_cookies([cookie | rest], headers), do: set_cookies(rest, [{"Cookie", cookie} | headers])
end
