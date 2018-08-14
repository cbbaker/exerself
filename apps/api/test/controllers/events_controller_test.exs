defmodule Api.EventsControllerTest do
  use Api.ConnCase

  require Repo

  setup do
    Repo.TestLog.reset()
    Repo.create_table("users", Repo.Validators.Upsert, [:email])
    Repo.blocking do: Repo.create_table("stuff")
    Repo.create_entry("stuff", %{data: "this is data"})

    :ok
  end

  describe "when not logged in" do
    setup %{conn: conn}, do: {:ok, conn: assign(conn, :current_user, nil)}

    test "redirects to login", %{conn: conn} do
      conn = get conn, events_path(conn, :index)
      assert redirected_to(conn) == page_path(conn, :index)
    end
  end

  describe "when not an admin" do
    setup %{conn: conn}, do: {:ok, conn: assign(conn, :current_user, %{id: 2, email: "nonadmin@exerself.com"})}

    test "forbidden error", %{conn: conn} do
      conn = get conn, events_path(conn, :index)
      assert html_response(conn, :forbidden)
    end
  end

  describe "when an admin" do
    setup %{conn: conn}, do: {:ok, conn: assign(conn, :current_user, %{id: 1, email: "admin@exerself.com"})}

    test "list of events", %{conn: conn} do
      conn = get conn, events_path(conn, :index)
      assert html_response(conn, 200)
    end
  end
  
end
