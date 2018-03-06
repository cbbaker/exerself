defmodule Repo.Aggregates.Table do
  use GenServer

  defstruct [:entries, :next_id]

  def start_link() do
    GenServer.start_link(__MODULE__, %Repo.Aggregates.Table{entries: [], next_id: 1})
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  def list(pid, start, count) do
    GenServer.call(pid, {:list, start, count})
  end

  def next_id(pid) do
    GenServer.call(pid, :next_id)
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

  def handle_call({:list, start, count}, _from, %{entries: entries} = state) do
    result = entries |> Enum.drop(start) |> Enum.take(count)
    {:reply, result, state}
  end

  def handle_call(:next_id, _from, %{next_id: next_id} = state) do
    {:reply, next_id, %{state | next_id: (next_id + 1)}}
  end

  def handle_cast({:create, entry}, %{entries: entries} = state) do
    {:noreply, %{state | entries: [entry | entries]}}
  end

  def handle_cast({:update, %{id: id} = new}, %{entries: entries} = state) do
    updated = entries |> Enum.map(fn 
      (%{id: ^id}) -> new
      (old) -> old
    end)
    {:noreply, %{state | entries: updated}}
  end

  def handle_cast({:delete, %{id: id}}, %{entries: entries} = state) do
    deleted = entries |> Enum.reject(fn (entry) -> (entry.id == id) end)
    {:noreply, %{state | entries: deleted}}
  end
end
