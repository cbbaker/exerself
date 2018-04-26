defmodule Api.Pagination do
    def get_entries(name, %{"count" => count_string, "last" => last_string}) do
    {count, _} = Integer.parse(count_string)
    {last, _} = Integer.parse(last_string)
    entries_plus_one = DataSource.get_entries(name, count + 1, last)
    entries = Enum.take(entries_plus_one, count)
    next_page = if length(entries_plus_one) > count do
      %{"count" => count, "last" => List.last(entries).id}
    end
    {entries, next_page}
  end

  def get_entries(name, %{"count" => count_string}) do
    {count, _} = Integer.parse(count_string)
    entries_plus_one = DataSource.get_entries(name, count + 1)
    entries = Enum.take(entries_plus_one, count)
    next_page = if length(entries_plus_one) > count do
      %{"count" => count, "last" => List.last(entries).id}
    end
    {entries, next_page}
  end

  def get_entries(name, _) do
    get_entries(name, %{"count" => "20"})
  end
end
