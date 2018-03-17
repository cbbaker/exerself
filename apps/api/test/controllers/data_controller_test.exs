defmodule Api.DataControllerTest do
  use Api.ConnCase

  @valid_attrs %{"datum" => "blah"}
  # @invalid_attrs %{}

  setup %{conn: conn} do
    Repo.TestLog.reset()
    Repo.create_table("data_sources")

    name = "test"
    schema = %{"datum" => "string"}
    viewers = []
    editors = []
    DataSource.create(name, schema, viewers, editors)
    Process.sleep(10)

    {:ok, 
     conn: put_req_header(conn, "accept", "application/json"), 
     name: name,
     schema: schema,
     viewers: viewers,
     editors: editors
    }
  end

  test "shows the resource", %{conn: conn, name: name} do
    entry = DataSource.create_entry(name, %{})
    conn = get conn, data_source_data_path(conn, :show, name, entry.id)
    assert json_response(conn, 200)["uri"] == data_source_data_path(conn, :show, name, entry.id)
  end

  test "creates and renders resource when data is valid", %{conn: conn, name: name} do
    conn = post conn, data_source_data_path(conn, :create, name), data: @valid_attrs
    assert json_response(conn, 201)["uri"]
    Process.sleep(10)
    assert [%{"datum" => "blah"}] = DataSource.get_entries(name, 100)
  end

  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, data_source_path(conn, :create), data_source: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  test "updates and renders chosen resource when data is valid", %{conn: conn, name: name} do
    data = DataSource.create_entry(name, %{})
    conn = put conn, data_source_data_path(conn, :update, name, data.id), data: @valid_attrs
    assert json_response(conn, 200)["uri"]
    assert [%{"datum" => "blah"}] = DataSource.get_entries(name, 100)
  end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   data_source = Repo.insert! %DataSource{}
  #   conn = put conn, data_source_path(conn, :update, data_source), data_source: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  test "deletes chosen resource", %{conn: conn, name: name} do
    data = DataSource.create_entry(name, %{})
    conn = delete conn, data_source_data_path(conn, :delete, name, data.id)
    assert response(conn, 204)
    assert DataSource.get_entries(name, 100) == []
  end
end
