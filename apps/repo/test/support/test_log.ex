defmodule Repo.TestLog do
  use GenServer

  defstruct name: nil, terms: []

  def open(name) do
    GenServer.start_link(__MODULE__, %Repo.TestLog{name: name}, name: TestLog)
  end

  def write(pid, term) do
    GenServer.cast(pid, {:write, term})
  end

  def get_terms(pid) do
    GenServer.call(pid, :get_terms)
  end

  def reset() do
    GenServer.call(TestLog, :reset)
  end

  def handle_cast({:write, term}, %{terms: terms} = log) do
    {:noreply, %{ log | terms: [term | terms]}}
  end

  def handle_call(:get_terms, _from, %{terms: terms} = log) do
    {:reply, Enum.reverse(terms), log}
  end

  def handle_call(:reset, _from, log) do
    {:reply, :ok, %{log | terms: []}}
  end
end
