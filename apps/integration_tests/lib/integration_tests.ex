defmodule IntegrationTests do
  use Hound.Helpers

  require Repo

  @moduledoc """
  Documentation for IntegrationTests.
  """

  @doc """
  Hello world.

  ## Examples

      iex> IntegrationTests.hello
      :world

  """
  def hello do
    :world
  end

  # @session Application.get_env(:integration_tests, :session)

  def do_test do
    Hound.start_session()
    login()
    navigate_to("http://localhost:4000/data-sources")
    find_element(:id, "source/1") |> click()
    create_new(%{duration: "45",
                 power: "120",
                 heart_rate: "128",
                 notes: "this is a test"})
    create_new(%{duration: "65",
                 power: "102",
                 heart_rate: "130",
                 notes: "this is another test"})
    create_new(%{duration: "65",
                 power: "102",
                 heart_rate: "130",
                 notes: "this is a third test"})
    delete(1)
    edit(1, %{heart_rate: "132", notes: "edited"})
    Hound.end_session()
  end

  @test_password Application.get_env(:api, :test_password)

  defp login() do
    navigate_to("http://localhost:4000/auth/test")
    fill_field({:id, "auth_email"}, "test@gmail.com")
    fill_field({:id, "auth_name"}, "Bob")
    fill_field({:id, "auth_image"}, "http://r.ddmcdn.com/w_606/s_f/o_1/cx_0/cy_15/cw_606/ch_404/APL/uploads/2014/06/10-kitten-cuteness-1.jpg")
    fill_field({:id, "auth_password"}, @test_password)
    click({:css, "button"})
  end

  defp create_new(map) do
    click_new()
    fill_fields(0, map)
    click_save(0)
    
  end

  defp click_new() do
    find_element(:id, "newButton") |> click()
  end

  defp fill_fields(i, map) do
    form = find_element(:id, "item/#{i}")
    Enum.each(map, fn {k, v} -> 
      find_within_element(form, :id, Atom.to_string(k)) |> fill_field(v)
    end)
  end

  defp click_save(i) do
    find_element(:id, "save/#{i}") |> click()
  end

  defp edit(i, map) do
    find_element(:id, "item/#{i}") |> click()
    fill_fields(i, map)
    click_save(i)
  end

  defp delete(i) do
    find_element(:id, "item/#{i}") |> click()
    find_element(:id, "delete/#{i}") |> click()
  end

end
