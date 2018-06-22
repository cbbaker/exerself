defmodule Api.DataControllerTest do
  use Api.ConnCase

  require Repo

  @valid_attrs %{"datum" => "blah"}
  # @invalid_attrs %{}
  @user %{email: "test@gmail.com", name: "bob"}

  setup do
    Repo.TestLog.reset()
    Repo.create_table("users")
    Repo.create_table("data_sources")

    user = DataSource.create_or_update_user(@user)

    name = "test"
    schema = %{"datum" => "string"}
    viewers = []
    editors = []
    Repo.blocking do: DataSource.create(user, name, schema, viewers, editors)

    {:ok, user: user, name: name, schema: schema, viewers: viewers, editors: editors}
  end

  defp setup_headers(%{conn: conn, accept: accept}), do: {:ok, conn: put_req_header(conn, "accept", accept)}
  defp setup_headers(%{conn: conn}), do: {:ok, conn: conn}

  setup :setup_headers

  describe "when not logged in" do
    setup %{conn: conn}, do: {:ok, conn: assign(conn, :current_user, nil)}

    test "static", %{conn: conn, name: name} do
      conn = get conn, data_path(conn, :static, name)
      assert html_response(conn, 403)
    end

    @tag accept: "application/json"
    test "index", %{conn: conn, name: name} do
      conn = post conn, data_source_data_path(conn, :create, name, @valid_attrs)
      assert json_response(conn, 403)
    end
  end

  describe "when logged in" do
    setup %{conn: conn, user: user}, do: {:ok, conn: assign(conn, :current_user, user)}

    test "shows the resource", %{conn: conn, user: user, name: name} do
      entry = DataSource.create_entry(user, name, %{})
      conn = get conn, data_source_data_path(conn, :show, name, entry.id)
      assert json_response(conn, 200)["uri"] == data_source_data_path(conn, :show, name, entry.id)
    end

    test "creates and renders resource when data is valid", %{conn: conn, user: user, name: name} do
      conn = Repo.blocking do: post conn, data_source_data_path(conn, :create, name), data: @valid_attrs
      assert json_response(conn, 201)["uri"]
      assert [%{"datum" => "blah"}] = DataSource.get_entries(user, name, 100)
    end

    # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    #   conn = post conn, data_source_path(conn, :create), data_source: @invalid_attrs
    #   assert json_response(conn, 422)["errors"] != %{}
    # end

    test "updates and renders chosen resource when data is valid", %{conn: conn, user: user, name: name} do
      data = DataSource.create_entry(user, name, %{})
      conn = Repo.blocking do: put conn, data_source_data_path(conn, :update, name, data.id), data: @valid_attrs
      assert json_response(conn, 200)["uri"]
      assert [%{"datum" => "blah"}] = DataSource.get_entries(user, name, 100)
    end

    # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    #   data_source = Repo.insert! %DataSource{}
    #   conn = put conn, data_source_path(conn, :update, data_source), data_source: @invalid_attrs
    #   assert json_response(conn, 422)["errors"] != %{}
    # end

    test "deletes chosen resource", %{conn: conn, user: user, name: name} do
      data = DataSource.create_entry(user, name, %{})
      conn = Repo.blocking do: delete conn, data_source_data_path(conn, :delete, name, data.id)
      assert response(conn, 204)
      assert DataSource.get_entries(user, name, 100) == []
    end
  end

end
