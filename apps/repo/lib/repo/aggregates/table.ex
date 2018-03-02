defmodule Repo.Aggregates.Table do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def list(pid, start, count) do
    GenServer.call(pid, {:list, start, count})
  end

  def create(pid, entry) do
    GenServer.cast(pid, {:create, entry})
  end

  def handle_call({:list, start, count}, _from, entries) do
    result = entries |> Enum.drop(start) |> Enum.take(count)
    {:reply, result, entries}
  end

  def handle_cast({:create, entry}, entries) do
    {:noreply, [entry | entries]}
  end
end
