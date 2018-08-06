defmodule Api.DataSourceControllerTest do
  use Api.ConnCase

  require Repo

  @valid_attrs %{
    "name" => "test",
    "schema" => %{},
    "viewers" => [],
    "editors" => []
  }

  @user %{email: "test@gmail.com", name: "bob"}

  setup do
    Repo.TestLog.reset()
    Repo.create_table("users")
    Repo.create_table("data_sources")

    user = Repo.blocking do: DataSource.create_or_update_user(@user)
    %{user: user}
  end

  defp setup_headers(%{conn: conn, accept: accept}), do: {:ok, conn: put_req_header(conn, "accept", accept)}
  defp setup_headers(%{conn: conn}), do: {:ok, conn: conn}

  setup :setup_headers

  describe "when not logged in" do
    setup %{conn: conn}, do: {:ok, conn: assign(conn, :current_user, nil)}

    test "static", %{conn: conn} do
      conn = get conn, data_source_path(conn, :static)
      assert redirected_to(conn) == page_path(conn, :index)
    end

    @tag accept: "application/json"
    test "index", %{conn: conn} do
      conn = get conn, data_source_path(conn, :index)
      assert %{"links" => %{"login" => _}} = json_response(conn, 200)
    end
  end


  describe "when logged in" do
    setup %{conn: conn, user: user}, do: {:ok, conn: assign(conn, :current_user, user)}

    test "lists data sources", %{conn: conn} do
      conn = get conn, data_source_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all entries on index", %{conn: conn, user: user} do
      data_source = "test"
      DataSource.create(user, data_source, %{}, [], [])
      conn = get conn, data_source_path(conn, :show, data_source, data_sources: [data_source])
      assert %{"name" => ^data_source} = json_response(conn, 200)
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, data_source_path(conn, :show, -1)
      end
    end

    test "creates and renders resource when data is valid", %{conn: conn, user: user} do
      conn = post conn, data_source_path(conn, :create), data_source: @valid_attrs
      assert json_response(conn, 201)["name"]
      assert DataSource.list(user, 1) == [@valid_attrs["name"]]
    end

    # test "deletes chosen resource", %{conn: conn} do
    #   %{"name" => name,
    #     "schema" => schema,
    #     "viewers" => viewers,
    #     "editors" => editors} = @valid_attrs
    #   DataSource.create(name, schema, viewers, editors)
    #   conn = delete conn, data_source_path(conn, :delete, name)
    #   assert response(conn, 204)
    #   assert DataSource.list(1) == []
    # end
  end
end
