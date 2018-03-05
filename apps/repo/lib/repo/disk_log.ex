defmodule Repo.DiskLog do
  defstruct [:log]

  def open(name) do
    case :disk_log.open([{:name, name}]) do
      {:ok, log} ->
        {:ok, %Repo.DiskLog{log: log}}
      {:repaired, log, _, _} ->
        {:ok, %Repo.DiskLog{log: log}}
    end
  end

  def close(%{log: log}) do
    :disk_log.close(log)
  end

  def write(%{log: log}, term) do
    :disk_log.alog(log, term)
  end

  def get_terms(%{log: log}) do
    Stream.resource(
      fn -> {log, :start} end,
      fn ({log, current}) ->
        case :disk_log.chunk(log, current) do
          :eof ->
            {:halt, log}
          {next, terms} ->
            {terms, {log, next}}
        end
      end,
      fn (_log) -> :ok end
    )
  end
end
