defmodule Repo.Aggregates.TableList do
  use GenServer

  alias Repo.EventLog

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: TableList)
  end

  def get() do
    GenServer.call(TableList, :get)
  end

  def reset() do
    GenServer.call(TableList, :reset)
  end

  def init(state) do
    tables = EventLog.subscribe() |> Enum.reduce(state, &process/2)
    {:ok, tables}
  end

  def process({"create_table", %{name: name}}, acc), do: [%{name => "temp"} | acc]
  def process(_, acc), do: acc
  

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:reset, _from, _state) do
    {:reply, [], []}
  end

  def handle_info(msg, state) do
    {:noreply, process(msg, state)}
  end
end
