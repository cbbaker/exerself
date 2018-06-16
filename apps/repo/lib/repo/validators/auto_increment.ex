defmodule Repo.Validators.AutoIncrement do
  use GenServer

  alias Repo.Aggregates.Table

  def start_link(table) do
    GenServer.start_link(__MODULE__, table)
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  def init(table) do
    max_id = Table.stream(table) |>
      Enum.map(&(&1.id)) |>
      Enum.max(fn -> 0 end)
    {:ok, max_id + 1}
  end

  def create(pid, table, entry) do
    GenServer.call(pid, {:create, table, entry})
  end

  def handle_call({:create, table, entry}, _from, next_id) do
    entry = Map.put(entry, :id, next_id)
    Repo.EventLog.commit(:create_entry, %{table: table, entry: entry})
    {:reply, entry, next_id + 1}
  end
end
