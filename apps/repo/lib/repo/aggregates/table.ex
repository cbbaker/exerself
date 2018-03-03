defmodule Repo.Aggregates.Table do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  def list(pid, start, count) do
    GenServer.call(pid, {:list, start, count})
  end

  def create(pid, entry) do
    GenServer.cast(pid, {:create, entry})
  end

  def update(pid, entry) do
    GenServer.cast(pid, {:update, entry})
  end

  def delete(pid, entry) do
    GenServer.cast(pid, {:delete, entry})
  end

  def handle_call({:list, start, count}, _from, entries) do
    result = entries |> Enum.drop(start) |> Enum.take(count)
    {:reply, result, entries}
  end

  def handle_cast({:create, entry}, entries) do
    {:noreply, [entry | entries]}
  end

  def handle_cast({:update, %{id: id} = new}, entries) do
    updated = entries |> Enum.map(fn 
      (%{id: ^id}) -> new
      (old) -> old
    end)
    {:noreply, updated}
  end

  def handle_cast({:delete, %{id: id}}, entries) do
    deleted = entries |> Enum.reject(fn (entry) -> (entry.id == id) end)
    {:noreply, deleted}
  end
end
