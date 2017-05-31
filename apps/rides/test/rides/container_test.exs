defmodule Rides.ContainerTest do
  use ExUnit.Case
  doctest Rides.Container

  alias Rides.Container

  setup do
    {:ok, pid} = Container.start_link []
    1..10 |> Enum.each(fn _ -> Container.insert(pid, %{}) end)
    [pid: pid]
  end

  test "index", %{pid: pid} do
    assert Container.index(pid, 3) == [%{id: 10}, %{id: 9}, %{id: 8}]
  end

  test "index starting in middle", %{pid: pid} do
    assert Container.index(pid, 2, %{id: 8}) == [%{id: 7}, %{id: 6}]
  end

  test "insert", %{pid: pid} do
    Container.insert(pid, %{})
    assert Container.index(pid, 3) == [%{id: 11}, %{id: 10}, %{id: 9}]
  end

  test "update", %{pid: pid} do
    Container.insert(pid, %{name: "test"})
    assert Container.index(pid, 1) == [%{id: 11, name: "test"}]
    assert %{id: 11, name: "new name"} = Container.update(pid, %{id: 11, name: "new name"})
    assert Container.index(pid, 1) == [%{id: 11, name: "new name"}]
  end


  test "delete", %{pid: pid} do
    Container.delete(pid, %{id: 9})
    assert Container.index(pid, 2) == [%{id: 10}, %{id: 8}]
  end

end
