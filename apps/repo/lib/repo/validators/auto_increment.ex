defmodule Repo.Validators.AutoIncrement do

  defstruct [:pid, :name]

  def start_link(name, table) do
    {:ok, pid} = Repo.Validators.AutoIncrement.Server.start_link(table)
    {:ok, %Repo.Validators.AutoIncrement{pid: pid, name: name}}
  end

  defmodule Server do
    use GenServer

    alias Repo.Aggregates.Table

    defstruct [:next_id]

    def start_link(table) do
      GenServer.start_link(__MODULE__, table)
    end

    def init(table) do
      max_id = Table.stream(table) |>
        Enum.map(&get_id/1) |>
        Enum.max(fn -> 0 end)
      {:ok, max_id + 1}
    end

    defp get_id(%{id: entry_id}), do: entry_id
    defp get_id(_), do: 0

    def handle_call({:create, table, entry}, _from, next_id) do
      entry = Map.put(entry, :id, next_id)
      Repo.EventLog.commit(:create_entry, %{table: table, entry: entry})
      {:reply, entry, next_id + 1}
    end

    def handle_call({:revalidate, entries}, _from, _next_id) do
      {result, next_id} = Enum.map_reduce(entries, 1, &transform/2)
      {:reply, result, next_id}
    end

    defp transform(entry, next_id) do
      {Map.put(entry, :id, next_id), next_id + 1}
    end
  end
end


defimpl Repo.Validator, for: Repo.Validators.AutoIncrement do
  def stop(%{pid: pid}), do: GenServer.stop(pid)
  def create(%{pid: pid, name: name}, entry), do: GenServer.call(pid, {:create, name, entry})
  def revalidate(%{pid: pid}, entries), do: GenServer.call(pid, {:revalidate, entries})
end
