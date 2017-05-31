defmodule Rides.Ride do
  defstruct [:id, :started_at, :duration, :power, :heart_rate, :notes]

  alias Rides.Ride

  def from_map(%{"id" => id,
                 "started_at" => started_at,
                 "duration" => duration,
                 "power" => power,
                 "heart_rate" => heart_rate,
                 "notes" => notes}) do
    %Ride{id: make_int(id),
          started_at: make_int(started_at),
          duration: make_int(duration),
          power: make_int(power),
          heart_rate: make_int(heart_rate),
          notes: notes}
  end

  def from_map(%{"started_at" => started_at,
                 "duration" => duration,
                 "power" => power,
                 "heart_rate" => heart_rate,
                 "notes" => notes}) do
    %Ride{started_at: make_int(started_at),
          duration: make_int(duration),
          power: make_int(power),
          heart_rate: make_int(heart_rate),
          notes: notes}
  end

  def from_map(%{id: id,
                 started_at: started_at,
                 duration: duration,
                 power: power,
                 heart_rate: heart_rate,
                 notes: notes}) do
    %Ride{id: id,
          started_at: started_at,
          duration: duration,
          power: power,
          heart_rate: heart_rate,
          notes: notes}
  end

  def from_map(%{started_at: started_at,
                 duration: duration,
                 power: power,
                 heart_rate: heart_rate,
                 notes: notes}) do
    %Ride{started_at: started_at,
          duration: duration,
          power: power,
          heart_rate: heart_rate,
          notes: notes}
  end


  defp make_int(param) when is_integer(param) do
    param
  end

  defp make_int(param) when is_binary(param) do
    param |> Integer.parse |> with_parsed
  end


  defp with_parsed({result, _}), do: result
end
