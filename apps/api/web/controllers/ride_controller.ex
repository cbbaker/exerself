defmodule Api.RideController do
  use Api.Web, :controller

  # alias Api.Ride

  def static(conn, params) do
    per_page = Map.get(params, "per_page", 10)
    rides = if last = Map.get(params, "last", nil) do
      Rides.index(per_page, last)
    else
      Rides.index(per_page)
    end
    render(conn, "index.html", rides: rides)
  end

  def index(conn, params) do
    per_page = Map.get(params, "per_page", 10)
    rides = if last = Map.get(params, "last", nil) do
      Rides.index(per_page, last)
    else
      Rides.index(per_page)
    end
    render(conn, "index.json", rides: rides)
  end

  def create(conn, %{"body" => body}) do
    old_id = body |> Map.keys |> List.first
    %{"data" => data} = body[old_id]
    ride = Rides.insert(data)

    conn
    |> put_status(:created)
    |> put_resp_header("location", ride_path(conn, :show, ride))
    |> render("show.json", old_id: old_id, ride: ride)
  end

  def update(conn, %{"id" => id, "body" => ride_params}) do
    ride = ride_params |> Map.put("id", id) |> Rides.update
    render(conn, "show.json", ride: ride)
  end

  def delete(conn, %{"id" => id}) do
    Rides.delete(%{id: id})

    send_resp(conn, :no_content, "")
  end
end
