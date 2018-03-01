defmodule Repo.EventLog do
  use GenServer
  
  @logger Application.get_env(:repo, :event_logger)

  defstruct [:log, :subscribers]

  def start_link() do
    {:ok, log} = @logger.open(:repo)
    GenServer.start_link(__MODULE__, %Repo.EventLog{log: log, subscribers: []}, name: EventLog)
  end

  def commit(event_type, payload) do
    GenServer.cast(EventLog, {:commit, event_type, payload})
  end

  def subscribe() do
    GenServer.call(EventLog, :subscribe)
  end

  def unsubscribe() do
    GenServer.call(EventLog, :unsubscribe)
  end

  def handle_cast({:commit, event_type, payload}, %{log: log, subscribers: subscribers} = state) do
    message = {event_type, payload}
    @logger.write(log, message)
    Enum.each(subscribers, fn subscriber -> send(subscriber, message) end)
    {:noreply, state}
  end

  def handle_call(:subscribe, {from, _}, %{log: log, subscribers: subscribers} = state) do
    {:reply, @logger.get_terms(log), %{state | subscribers: [from | subscribers]}}
  end


  def handle_call(:unsubscribe, {from, _}, %{log: log, subscribers: subscribers} = state) do
    {:reply, @logger.get_terms(log), %{state | subscribers: List.delete(subscribers, from)}}
  end

end
