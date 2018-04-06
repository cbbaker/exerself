defmodule Api.DataView do
  use Api.Web, :view

  def render("show.json", %{conn: conn, name: name, data: data}) do
    Api.DataSourceView.show_entry(conn, name, data)
  end

  def render("index.json", %{conn: conn, data_source: data_source, data_sources: data_sources}) do
    Api.DataSourceView.render("show.json", %{conn: conn, data_source: data_source, data_sources: data_sources})
  end
end
