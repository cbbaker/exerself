defmodule Api.DataSourceView do
  use Api.Web, :view

  def render("index.json", %{conn: conn, user: user, data_sources: data_sources}) do
    %{ uri: data_source_path(conn, :index, user),
       nav: show_nav(conn, user, data_sources, :none),
       data: render_many(data_sources, Api.DataSourceView, "data_source.json", conn: conn)
    }
  end

  def render("data_source.json", %{conn: conn, user: user, data_source: data_source}) do
    %{name: data_source,
      uri: data_path(conn, :static, data_source, user)
    }
  end

  def render("show.json", %{conn: conn,
                            user: user,
                            data_sources: data_sources,
                            data_source: %{
                               name: name,
                               schema: schema,
                               viewers: viewers,
                               editors: editors,
                               entries: {entries, next_page}
                            }}) do
    retval = %{
      uri: data_source_path(conn, :show, user, name),
      name: name,
      nav: show_nav(conn, user, data_sources, name),
      schema: schema,
      editors: show_editors(editors),
      viewers: show_viewers(viewers),
      data: Enum.map(entries, &show_entry(conn, user, name, &1)),
      links: %{
        create: %{
          url: data_source_data_path(conn, :create, user, name),
          param: "data"
        }
      }
    }
    if next_page do
      Map.put(retval, :nextPage, data_source_path(conn, :show, user, name, next_page))
    else
      retval
    end
  end

  def render("auth.json", %{conn: conn, message: message}) do
    %{
      uri: page_path(conn, :index),
      title: "Sign in",
      message: message,
      nav:
      %{
        brand: "Exerself",
        menus: []
      },
      links:
      %{
        login: %{
          text: "Sign in via Google",
          url: "/auth/google"
        }
      }
    }
  end

  def show_entry(conn, user, name, entry) do
    %{ uri: data_source_data_path(conn, :show, user, name, entry.id),
       data: entry,
       links: %{
         update: %{
           url: data_source_data_path(conn, :update, user, name, entry.id),
           param: "data"
         },
         delete: %{
           url: data_source_data_path(conn, :delete, user, name, entry.id)
         }

       }
    }
  end

  def show_nav(%{assigns: %{current_user: info}} = conn, user, data_sources, current) do
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
          items: Enum.map(data_sources, &(show_item(&1, data_path(conn, :static, user, &1), &1 == current)))
        }
      ],
      auth: %{
        info: info,
        url: auth_path(conn, :delete)
      }
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
