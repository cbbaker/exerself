defmodule Api.Validate do

  def valid(%{info: info}) do
    valid(info)
  end

  def valid(%{email: _email} = info) do
    if info = DataSource.create_or_update_user(info) do
      {:ok, info}
    else
      {:error, "unauthorized"}
    end
  end
end
