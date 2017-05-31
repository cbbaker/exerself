defmodule Rides.RideTest do
  use ExUnit.Case

  alias Rides.Ride

  doctest Rides.Ride

  @params %{"id" => "3",
            "started_at" => "12341234",
            "duration" => "60",
            "power" => "104",
            "heart_rate" => "130",
            "notes" => "This is a note."}

  test "converts params to structs" do
    assert Ride.from_map(@params) == %Ride{id: 3,
                                           started_at: 12341234,
                                           duration: 60,
                                           power: 104,
                                           heart_rate: 130,
                                           notes: "This is a note."}
  end

  test "ignores missing id" do
    assert Ride.from_map(Map.delete(@params, "id")) == %Ride{started_at: 12341234,
                                                             duration: 60,
                                                             power: 104,
                                                             heart_rate: 130,
                                                             notes: "This is a note."}
  end
end
