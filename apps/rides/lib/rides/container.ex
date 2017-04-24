defmodule Rides.Container do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, {[], 0}, opts)
  end

  def index(pid, count) do
    GenServer.call(pid, {:index, count})
  end

  def index(pid, count, last) do
    GenServer.call(pid, {:index, count, last})
  end

  def insert(pid, item) do
    GenServer.call(pid, {:insert, item})
  end

  def update(pid, item) do
    GenServer.cast(pid, {:update, item})
    item
  end

  def delete(pid, item) do
    GenServer.cast(pid, {:delete, item})
  end


  def handle_call({:index, count}, _from, {items, _} = state) do
    {:reply, Enum.take(items, count), state}
  end

  def handle_call({:index, count, %{id: last_id}}, _from, {items, _} = state) do
    result = items
    |> Enum.drop_while(fn %{id: id} -> id >= last_id end)
    |> Enum.take(count)
    {:reply, result, state}
  end

  def handle_call({:insert, item}, _from, {items, last_id}) do
    id = last_id + 1
    new_item = Map.put(item, :id, id)
    {:reply, new_item, {[ new_item | items ], id}}
  end

  def handle_cast({:update, %{id: id} = new_item}, {items, last_id}) do
    new_items = Enum.map items, fn
      %{id: ^id} -> new_item
      old_item -> old_item
    end
    {:noreply, {new_items, last_id}}
  end


  def handle_cast({:delete, %{id: delete}}, {items, last_id}) do
    {:noreply, {Enum.filter(items, fn %{id: id} -> id != delete end), last_id}}
  end
end
