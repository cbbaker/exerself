defmodule Api.Validate do
  @authorized_emails Poison.decode!(Application.get_env(:api, :authorized_emails))

  def valid(%{info: info}) do
    valid(info)
  end

  def valid(%{email: email} = info) do
    if info = DataSource.create_or_update_user(info) do
      {:ok, info}
    else
      {:error, "unauthorized"}
    end
  end
end
