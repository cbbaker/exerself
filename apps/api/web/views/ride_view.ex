defmodule Api.RideView do
  use Api.Web, :view

  defmodule RideList do
    defstruct [:list]
  end

  defimpl Poison.Encoder, for: RideList do
    use Poison.Encode
    
    def encode(%{list: list}, _) when length(list) < 1, do: "{}"

    def encode(%{list: list}, options) do
      fun = fn {key, value}, acc ->
        [?,,
         Poison.Encoder.BitString.encode(encode_name(key), options),
         ?:,
         Poison.Encoder.encode(value, options)
         | acc
        ]
      end

      [?{, tl(:lists.foldl(fun, [], :lists.reverse(list))), ?}]
    end
  end

  def render("index.json", %{conn: conn, rides: rides}) do
    %{heading: %{
         text: "Listing rides",
         level: 3,
         classes: ["panel-title"]
      },
      body: %{
        newButton: %{
          type: "NewRideButton",
          text: "Create new",
          idPrefix: "newRide",
          defaults: %{
            user_id: %{
              type: "const_int",
              value: 1
            },
            started_at: %{
              type: "current_time"
            },
            duration: %{
              type: "last_create"
            },
            power: %{
              type: "last_create"
            },
            heart_rate: %{
              type: "last_create"
            },
            notes: %{
              type: "const_string",
              value: ""
            }
          },
          last: defaults(rides),
          newItemActions: %{
            update: %{
              links: [%{url: ride_path(conn, :create),
                        method: "POST",
                        body: %{},
                        success: "updateRide"
                      }],
              publishes: []
            }
          },
          enabled: true,
          actions: %{
            press: %{
              links: [],
              publishes: [%{channel: "newRideButton",
                            payload: %{}
                          }]
            }
          }
        },
        list: render_rides(rides, %{conn: conn})
      }
    }
  end

  def render("show.json", %{conn: conn, old_id: old_id, ride: ride}) do
    {new_id, value} = render_one(ride, Api.RideView, "ride.json", %{conn: conn})
    %{old_id => %{new_id => value}}
  end

  def render("show.json", %{conn: conn, ride: ride}) do
    {new_id, value} = render_one(ride, Api.RideView, "ride.json", %{conn: conn})
    %{new_id => %{new_id => value}}
  end


  def render("ride.json", %{conn: conn, ride: ride}) do
    {"item#{ride.id}",
     %{data: %{
          user_id: 1,
          started_at: ride.started_at,
          duration: ride.duration,
          power: ride.power,
          heart_rate: ride.heart_rate,
          notes: ride.notes
       },
       actions: %{
         update: %{
           links: [
             %{url: ride_path(conn, :update, ride),
               method: "PUT",
               body: %{},
               success: "item#{ride.id}Update"
              }
           ],
           publishes: []
         },
         delete: %{
           links: [
             %{url: ride_path(conn, :delete, ride),
               method: "DELETE",
               body: %{},
               success: "item#{ride.id}Delete"
              }
           ],
           publishes: []
         }
       }
     }
    }
  end

  defp render_rides(rides, assigns) do
    list = %Api.RideView.RideList{
      list: render_many(rides, Api.RideView, "ride.json", assigns)
    }
  end

  defp defaults([ride | _]) do
    %{user_id: 1,
      started_at: ride.started_at,
      duration: ride.duration,
      power: ride.power,
      heart_rate: ride.heart_rate,
      notes: ride.notes
    }
  end

  defp defaults(_) do
    %{user_id: 1,
      started_at: 0,
      duration: 0,
      power: 0,
      heart_rate: 0,
      notes: ""
    }
  end
end
