defmodule Api.DataSourceView do
  use Api.Web, :view

  def render("index.json", %{"data-sources": data_sources}) do
    %{data: render_many(data_sources, Api.DataSourceView, "data_source.json")}
  end

  def render("data_source.json", %{data_source: data_source}) do
    data_source
  end

  def render("show.json", %{conn: conn,
                            data_source: %{
                               name: name,
                               schema: schema,
                               viewers: viewers,
                               editors: editors,
                               entries: entries
                            }}) do
    %{
      uri: data_source_path(conn, :show, name),
      name: name,
      schema: schema,
      editors: show_editors(editors),
      viewers: show_viewers(viewers),
      data: Enum.map(entries, &show_entry(conn, name, &1)),
      links: %{
        create: %{
          url: data_source_data_path(conn, :create, name),
          param: "data"
        }
      }
    }
  end

  def show_entry(conn, name, entry) do
    %{ uri: data_source_data_path(conn, :show, name, entry.id),
       data: entry,
       links: %{
         update: %{
           url: data_source_data_path(conn, :update, name, entry.id),
           param: "data"
         },
         delete: %{
           url: data_source_data_path(conn, :delete, name, entry.id)
         }

       }
    }
  end

  defp show_editors(editors) do
    Enum.reverse(editors)
  end

  defp show_viewers(viewers) do
    Enum.reverse(viewers) |> Enum.map(&(&1.row))
  end
end
