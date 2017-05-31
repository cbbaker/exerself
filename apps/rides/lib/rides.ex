defmodule Rides do
  alias Rides.Container
  alias Rides.Ride

  def start_link do
    Container.start_link name: :rides
  end

  def index(count) do
    Container.index(:rides, count)
  end

  def index(count, last) do
    Container.index(:rides, count, last)
  end

  def insert(item) do
    Container.insert :rides, Ride.from_map(item)
  end

  def update(item) do
    Container.update :rides, Ride.from_map(item)
  end

  def delete(%{id: id}) when is_binary(id) do
    {result, _} = Integer.parse(id)
    Container.delete(:rides, %{id: result})
  end

  def delete(item) do
    Container.delete(:rides, item)
  end
end
