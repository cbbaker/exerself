defmodule DiskLogTest do
  use ExUnit.Case

  alias Repo.DiskLog

  test "writes terms to disk and reads them back" do
    File.rm("test.LOG")
    {:ok, log} = DiskLog.open(:test)
    DiskLog.write(log, {:test, "test1"})
    DiskLog.write(log, {:test, "test2"})
    assert [{:test, "test1"}, {:test, "test2"}] = DiskLog.get_terms(log) |> Enum.to_list()
  end
end
