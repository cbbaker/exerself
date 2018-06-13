defmodule Repo.Validators.AutoIncrement do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, 1)
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  def init(args) do
    {:ok, args}
  end

  def set_next_id(pid, value) do
    GenServer.cast(pid, {:set_next_id, value})
  end

  def create(pid, table, entry) do
    GenServer.call(pid, {:create, table, entry})
  end

  def handle_cast({:set_next_id, value}, _next_id) do
    {:noreply, value}
  end

  def handle_call({:create, table, entry}, _from, next_id) do
    entry = Map.put(entry, :id, next_id)
    Repo.EventLog.commit(:create_entry, %{table: table, entry: entry})
    {:reply, entry, next_id + 1}
  end
end
