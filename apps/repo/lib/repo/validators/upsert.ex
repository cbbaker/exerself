defmodule Repo.Validators.Upsert do
  defstruct [:pid, :name]

  def start_link(name, table, key) do
    {:ok, pid} = Repo.Validators.Upsert.Server.start_link(table, key)
    {:ok, %Repo.Validators.Upsert{pid: pid, name: name}}
  end

  defmodule Server do
    use GenServer

    alias Repo.Aggregates.Table

    defstruct [:key, :last_id, :id_map]

    def start_link(table, key) do
      GenServer.start_link(__MODULE__, [table, key])
    end

    def init([table, key]) do
      state = Table.stream(table) |>
        Enum.reduce(%Repo.Validators.Upsert.Server{key: key, last_id: 0, id_map: %{}}, &update/2)
      {:ok, state}
    end

    defp update(%{id: entry_id} = entry, %{key: key, last_id: last_id, id_map: id_map} = state) do
      Map.merge(state, 
        %{last_id: Enum.max([last_id, entry_id]),
          id_map: Map.put(id_map, Map.fetch!(entry, key), entry_id)
        }
      )
    end

    defp update(_, state) do
      state
    end

    def handle_call({:create, table, entry}, _from, %{key: key, last_id: last_id, id_map: id_map} = state) do
      this_key = Map.fetch!(entry, key)
      id = Map.get(id_map, this_key)
      if id do
        new_entry = Map.put(entry, :id, id)
        Repo.EventLog.commit(:update_entry, %{table: table, entry: new_entry})
        {:reply, new_entry, state}
      else
        new_last_id = last_id + 1
        new_entry = Map.put(entry, :id, new_last_id)
        Repo.EventLog.commit(:create_entry, %{table: table, entry: new_entry})
        new_id_map = Map.put(id_map, this_key, new_last_id)
        {:reply, new_entry, Map.merge(state, %{last_id: new_last_id, id_map: new_id_map})}
      end
    end
  end
end

defimpl Repo.Validator, for: Repo.Validators.Upsert do
  def stop(%{pid: pid}), do: GenServer.stop(pid)
  def create(%{pid: pid, name: name}, entry), do: GenServer.call(pid, {:create, name, entry})
  def revalidate(%{pid: _pid}, entries), do: entries
end
