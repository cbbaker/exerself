defmodule Api.RideControllerTest do
  use Api.ConnCase

  # alias Api.Ride
  @valid_attrs %{duration: 42, heart_rate: 42, notes: "some content", power: 42, started_at: 1493387534}
  # @invalid_attrs %{}

  defp stringify_keys(map) do
    for {key, value} <- map, into: %{} do
      {stringify(key), value}
    end
  end

  defp stringify(key) when is_atom(key), do: Atom.to_string(key)
  defp stringify(key), do: key


  setup do
    for ride <- Rides.index(1000) do
      Rides.delete(ride)
    end

    ride = Rides.insert(@valid_attrs)
    [rides: [ride]]
  end


  describe "html page" do
    test "lists all entries on index", %{conn: conn} do
      conn = get conn, ride_path(conn, :static)
      assert html_response(conn, 200)
    end
  end

  describe "api" do

    setup %{conn: conn} do
      {:ok, conn: put_req_header(conn, "accept", "application/json")}
    end

    test "lists all entries on index", %{conn: conn, rides: [%{duration: duration, heart_rate: heart_rate, power: power, started_at: started_at, notes: notes}]} do
      conn = get conn, ride_path(conn, :index)
      assert %{"body" => %{"list" => rides}} = json_response(conn, 200)
      assert [%{"data" => %{"duration" => ^duration, "heart_rate" => ^heart_rate, "notes" => ^notes, "power" => ^power, "started_at" => ^started_at}}] = Map.values(rides)
    end

    test "creates and renders resource when data is valid", %{conn: conn} do
      body_params = %{"feId" => %{data: stringify_keys(@valid_attrs), actions: %{}}}
      conn = post conn, ride_path(conn, :create), body: body_params
      assert %{"feId" => new_item} = json_response(conn, 201)
      assert [%{"data" => _, "actions" => _}] = Map.values(new_item)
    end

  # FIXME--should there be required params--cbb 2017-05-05
  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, ride_path(conn, :create), ride: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  test "updates and renders chosen resource when data is valid", %{conn: conn, rides: [ride]} do
    %{power: power} = ride
    new_power = power + 1
    attrs = %{ride | power: new_power} |> Map.delete(:id)
    conn = put conn, ride_path(conn, :update, ride), body: stringify_keys(Map.from_struct(attrs))
    new_item = json_response(conn, 200) |> Map.values |> List.first
    assert [%{"data" => %{"power" => ^new_power}, "actions" => _}] = Map.values(new_item)
    assert [%{power: ^new_power}] = Rides.index(1)
  end

  # FIXME--should there be required params--cbb 2017-05-05
  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   ride = Repo.insert! %Ride{}
  #   conn = put conn, ride_path(conn, :update, ride), ride: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  test "deletes chosen resource", %{conn: conn, rides: [ride]} do
    conn = delete conn, ride_path(conn, :delete, ride)
    assert response(conn, 204)
    assert [] = Rides.index(1)
  end
    
  end

end
