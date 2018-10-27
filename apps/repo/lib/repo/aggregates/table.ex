defmodule Repo.Aggregates.Table do
  use GenServer

  alias Repo.Validator

  defstruct [:entries]

  def start_link() do
    GenServer.start_link(__MODULE__, %Repo.Aggregates.Table{entries: []})
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  def init(args) do
    {:ok, args}
  end

  def list(pid, count, last) do
    GenServer.call(pid, {:list, count, last})
  end

  def list(pid, count) do
    GenServer.call(pid, {:list, count})
  end

  def stream(pid) do
    GenServer.call(pid, :stream)
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

  def revalidate(pid, validator) do
    GenServer.call(pid, {:revalidate, validator})
  end

  def handle_call({:list, count, last}, _from, %{entries: entries} = state) do
    result = entries |> Enum.drop_while(fn (entry) -> entry.id >= last end) |> Enum.take(count)
    {:reply, result, state}
  end

  def handle_call({:list, count}, _from, %{entries: entries} = state) do
    result = entries |> Enum.take(count)
    {:reply, result, state}
  end

  def handle_call(:stream, _from, %{entries: entries} = state) do
    {:reply, Enum.reverse(entries), state}
  end

  def handle_call({:revalidate, validator}, _from, %{entries: entries}) do
    new_entries =  Validator.revalidate(validator, Enum.reverse(entries))
    {:reply, new_entries, %{entries: Enum.reverse(new_entries)}}
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
