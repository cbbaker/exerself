defmodule Repo.EventLogTest do
  use ExUnit.Case
  doctest Repo.EventLog

  alias Repo.EventLog

  @event_type "event"

  defp create_payload(data) do
    %{data: data}
  end

  setup do
    Repo.TestLog.reset()
    payload = create_payload("initial")
    EventLog.commit(@event_type, payload)
    [initial_payload: payload]
  end

  test "subscribe returns the already logged terms", %{initial_payload: initial_payload} do
    assert [%{event_type: @event_type, payload: ^initial_payload}] = EventLog.subscribe()
  end

  test "subscribe receives future logged terms" do
    EventLog.subscribe()
    payload = create_payload("payload1")
    EventLog.commit(@event_type, payload)
    assert_receive %{event_type: @event_type, payload: ^payload}
  end

  test "unsubscribe doesn't receive future logged terms" do
    EventLog.subscribe()
    EventLog.commit("test", %{data: "payload"})
    assert_receive %{event_type: "test", payload: %{data: "payload"}}
    EventLog.unsubscribe()
    EventLog.commit("test", %{data: "payload"})
    refute_receive _msg
  end
end
