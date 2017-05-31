defmodule Api.RideViewTest do
  use Api.ConnCase, async: true

  import Phoenix.View

  @list %Api.RideView.RideList{
    list: [{"item12",
            %{actions: %{delete: %{links: [%{body: %{}, method: "DELETE",
                                             success: "item12Delete", url: "/api/rides/12"}], publishes: []},
                         update: %{links: [%{body: %{}, method: "PUT", success: "item12Update",
                                             url: "/api/rides/12"}], publishes: []}},
              data: %{duration: 60, heart_rate: 128, notes: "", power: 112,
                      started_at: 1496082176, user_id: 1}}},
           {"item11",
            %{actions: %{delete: %{links: [%{body: %{}, method: "DELETE",
                                             success: "item11Delete", url: "/api/rides/11"}], publishes: []},
                         update: %{links: [%{body: %{}, method: "PUT", success: "item11Update",
                                             url: "/api/rides/11"}], publishes: []}},
              data: %{duration: 60, heart_rate: 130, notes: "", power: 112,
                      started_at: 1496082169, user_id: 1}}},
           {"item9",
            %{actions: %{delete: %{links: [%{body: %{}, method: "DELETE",
                                             success: "item9Delete", url: "/api/rides/9"}], publishes: []},
                         update: %{links: [%{body: %{}, method: "PUT", success: "item9Update",
                                             url: "/api/rides/9"}], publishes: []}},
              data: %{duration: 62, heart_rate: 130, notes: "", power: 110,
                      started_at: 1496081035, user_id: 1}}},
           {"item8",
            %{actions: %{delete: %{links: [%{body: %{}, method: "DELETE",
                                             success: "item8Delete", url: "/api/rides/8"}], publishes: []},
                         update: %{links: [%{body: %{}, method: "PUT", success: "item8Update",
                                             url: "/api/rides/8"}], publishes: []}},
              data: %{duration: 60, heart_rate: 130, notes: "", power: 110,
                      started_at: 1496080018, user_id: 1}}},
           {"item6",
            %{actions: %{delete: %{links: [%{body: %{}, method: "DELETE",
                                             success: "item6Delete", url: "/api/rides/6"}], publishes: []},
                         update: %{links: [%{body: %{}, method: "PUT", success: "item6Update",
                                             url: "/api/rides/6"}], publishes: []}},
              data: %{duration: 60, heart_rate: 130, notes: "", power: 103,
                      started_at: 1496078677, user_id: 1}}}]}

  @rides [%Rides.Ride{duration: 60, heart_rate: 128, id: 12, notes: "", power: 112,
                      started_at: 1496082176},
          %Rides.Ride{duration: 60, heart_rate: 130, id: 11, notes: "", power: 112,
                      started_at: 1496082169},
          %Rides.Ride{duration: 62, heart_rate: 130, id: 9, notes: "", power: 110,
                      started_at: 1496081035},
          %Rides.Ride{duration: 60, heart_rate: 130, id: 8, notes: "", power: 110,
                      started_at: 1496080018},
          %Rides.Ride{duration: 60, heart_rate: 130, id: 6, notes: "", power: 103,
                      started_at: 1496078677}]



  test "can encode ride list" do
    assert {:ok, _value} = Poison.encode %{items: @list}
  end

  test "can render to string", %{conn: conn} do
    assert render_to_string(Api.RideView, "index.json", %{conn: conn, rides: @rides})
  end


end
