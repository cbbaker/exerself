defmodule Repo do
  alias Repo.EventLog
  alias Repo.Aggregates.TableList

  @moduledoc """
  EventSource-based repo for Exerself
  """

  @doc """
  Lists existing tables

  ## Examples

      iex> Repo.list_tables()
      [{"stuff", _pid}]

  """
  def list_tables() do
    TableList.get()
  end



  @doc """
  Creates a new table in the repo

  ## Examples

      iex> Repo.create_table("stuff")
      :ok

  """
  def create_table(name) do
    EventLog.commit("create_table", %{name: name})
  end
end
