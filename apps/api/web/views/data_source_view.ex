defmodule Api.DataSourceView do
  use Api.Web, :view

  def render("index.json", %{conn: conn, data_sources: data_sources}) do
    %{ uri: data_source_path(conn, :index),
       nav: show_nav(conn, data_sources, :none),
       data: render_many(data_sources, Api.DataSourceView, "data_source.json", conn: conn)
    }
  end

  def render("data_source.json", %{conn: conn, data_source: data_source}) do
    %{name: data_source,
      uri: data_path(conn, :static, data_source)
    }
  end

  def render("show.json", %{conn: conn,
                            data_sources: data_sources,
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
      nav: show_nav(conn, data_sources, name),
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

  def show_nav(conn, data_sources, current) do
    %{ 
      brand: "Exerself",
      menus: [
        %{
          type: "item",
          name: "Overview",
          uri: "/data-sources",
          active: current == :none
        },
        %{
          type: "menu",
          name: "Data",
          items: Enum.map(data_sources, &(show_item(&1, data_path(conn, :static, &1), &1 == current)))
        }
      ]
    }
  end

  defp show_item(name, uri, active) do
    %{type: "item", name: name, uri: uri, active: active}
  end

  defp show_editors(editors) do
    Enum.reverse(editors)
  end

  defp show_viewers(viewers) do
    Enum.reverse(viewers) |> Enum.map(&(&1.row))
  end
end
