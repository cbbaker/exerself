defmodule Api.EventsView do
  use Api.Web, :view

  def render_value(%{__struct__: _} = value) do
    value |> Map.from_struct |> render_value()
  end

  def render_value(value) when is_map(value) do
    render(Api.EventsView, "map.html", map: value)
  end

  def render_value(value) when is_list(value) do
    render(Api.EventsView, "list.html", list: value)
  end

  def render_value(value) do
    inspect(value)
  end
end
  
