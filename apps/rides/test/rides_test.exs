defmodule RidesTest do
  use ExUnit.Case
  doctest Rides

  @params %{"started_at" => "1493387534",
            "duration" => "60",
            "power" => "104",
            "heart_rate" => "129",
            "notes" => "Light sleep"}

  defp params(hash) do
    Map.merge(@params, hash)
  end

  setup do
    rides = for power <- 104..114 do
      Rides.insert(params(%{"power" => "#{power}"}))
    end
    [rides: Enum.reverse(rides)]
  end

  test "index", %{rides: [a, b, c | _]} do
    assert Rides.index(3) == [a, b, c]
  end

  test "index starting in middle", %{rides: [_, a, b, c | _]} do
    assert Rides.index(2, a) == [b, c]
  end

  test "insert" do
    ride = Rides.insert(@params)
    assert Rides.index(1) == [ride]
  end

  test "update", %{rides: [_, a, b | _]} do
    assert Rides.index(1, a) == [b]
    Rides.update(%{b | power: b.power + 1})
    assert [c] = Rides.index(1, a)
    assert c.power == b.power + 1
  end

  test "delete", %{rides: [a, b, c | _]} do
    Rides.delete(b)
    assert Rides.index(2) == [a, c]
  end

  test "delete when id is a string", %{rides: [a, b, c | _]} do
    Rides.delete(%{id: "#{b.id}"})
    assert Rides.index(2) == [a, c]
  end

end
