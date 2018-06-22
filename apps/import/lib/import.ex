defmodule Import do
  use HTTPoison.Base

  def process_url(path) do
    Application.get_env(:import, :exerself_url) <> path
  end

  def import(email, password) do
    Repo.create_table("users", Repo.Validators.Upsert, [:email])
    user = DataSource.create_or_update_user(%{email: email})
    Repo.create_table("data_sources")
    cookies = sign_in(email, password)
    get_stationary_bike_rides(cookies) |> import_stationary_bike_rides(user)
    get_road_bike_rides(cookies) |> import_road_bike_rides(user)
  end

  def get_token() do
    %{body: body, headers: headers} = get!("/users/sign_in")
    [token] = body |> Floki.find("input[name='authenticity_token']") |> Floki.attribute("value")
    cookies = get_cookies(headers)
    {token, cookies}
  end

  def sign_in(email, password) do
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

  def import_stationary_bike_rides(rides, user) do
    DataSource.create(user, "stationary_bike_rides", %{"started_at" => "date",
                                                       "duration" => "int",
                                                       "power" => "int",
                                                       "heart_rate" => "int",
                                                       "notes" => "text"},
      [
        %{row:
          [
            [%{tag: "date", name: "started_at", format: "%Y-%m-%d"}],
            [%{tag: "variable", name: "duration"},
             %{tag: "string", text: " min"}]
          ]
         },
        %{row:
          [
            [%{tag: "variable", name: "power"},
             %{tag: "string", text: " W"}],
            [%{tag: "variable", name: "heart_rate"},
             %{tag: "string", text: " BPM"}],
            [%{tag: "ratio", numerator: "power", denominator: "heart_rate", precision: 3}]
          ]},
        %{row:
          [
            [%{tag: "variable", name: "notes"}]
          ]}
      ], [
        %{
          init: %{
            type: "date",
            name: "started_at",
            label: "Started at"
          },
          default: %{
            type: "currentTime"
          }
        },
        %{
          init: %{
            type: "int",
            name: "duration",
            label: "Duration"
          },
          default: %{
            type: "lastCreated",
            variable: "duration"
          }
        },
        %{
          init: %{
            type: "int",
            name: "power",
            label: "Power"
          },
          default: %{
            type: "lastCreated",
            variable: "power"
          }
        },
        %{
          init: %{
            type: "int",
            name: "heart_rate",
            label: "Heart rate"
          },
          default: %{
            type: "lastCreated",
            variable: "heart_rate"
          }
        },
        %{
          init: %{
            type: "text",
            name: "notes",
            label: "Notes"
          }
        }

      ])
    Enum.reverse(rides) |> Enum.map(&(DataSource.create_entry(user, "stationary_bike_rides", &1)))
  end

  def import_road_bike_rides(rides, user) do
    DataSource.create(user, "road_bike_rides", %{"started_at" => "date",
                                                 "duration" => "int",
                                                 "distance" => "float",
                                                 "heart_rate" => "int",
                                                 "notes" => "text"},
      [
        %{row:
          [
            [%{tag: "date", name: "started_at", format: "%Y-%m-%d"}]
          ]},
        %{row:
          [
            [%{tag: "hms", name: "duration"}],
            [%{tag: "variable", name: "distance"},
             %{tag: "string", text: " mi"}],
            [%{tag: "variable", name: "heart_rate"},
             %{tag: "string", text: " BPM"}]
          ]},
        %{row:
          [
            [%{tag: "variable", name: "notes"}]
          ]}
      ], [
        %{
          init: %{
            type: "date",
            name: "started_at",
            label: "Started at"
          },
          default: %{
            type: "currentTime"
          }
        },
        %{
          init: %{
            type: "hms",
            name: "duration",
            label: "Duration"
          },
          default: %{
            type: "lastCreated",
            variable: "duration"
          }
        },
        %{
          init: %{
            type: "float",
            name: "distance",
            label: "Distance"
          },
          default: %{
            type: "lastCreated",
            variable: "distance"
          }
        },
        %{
          init: %{
            type: "int",
            name: "heart_rate",
            label: "Heart rate"
          },
          default: %{
            type: "lastCreated",
            variable: "heart_rate"
          }
        },
        %{
          init: %{
            type: "text",
            name: "notes",
            label: "Notes"
          }
        }

      ])
    Enum.reverse(rides) |> Enum.map(&(DataSource.create_entry(user, "road_bike_rides", &1)))
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
