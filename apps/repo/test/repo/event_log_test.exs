defmodule Repo.EventLogTest do
  use ExUnit.Case
  doctest Repo.EventLog

  alias Repo.EventLog

  test "subscribe returns the already logged terms" do
    Repo.TestLog.reset()
    EventLog.commit("test", %{data: "payload"})
    assert [%{event_type: "test", payload: %{data: "payload"}}] = EventLog.subscribe()
  end

  test "subscribe receives future logged terms" do
    Repo.TestLog.reset()
    EventLog.subscribe()
    EventLog.commit("test", %{data: "payload"})
    assert_receive %{event_type: "test", payload: %{data: "payload"}}
  end

  test "unsubscribe doesn't receive future logged terms" do
    Repo.TestLog.reset()
    EventLog.subscribe()
    EventLog.commit("test", %{data: "payload"})
    assert_receive %{event_type: "test", payload: %{data: "payload"}}
    EventLog.unsubscribe()
    EventLog.commit("test", %{data: "payload"})
    refute_receive _msg
  end
end
