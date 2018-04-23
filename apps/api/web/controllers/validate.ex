defmodule Api.Validate do
  @authorized_emails Poison.decode!(Application.get_env(:api, :authorized_emails))

  def valid(%{info: %{email: email}}) do
    valid(email)
  end

  def valid(email) do
    IO.puts("got email: #{email}")
    if Enum.member?(@authorized_emails, email) do
      {:ok, email}
    else
      {:error, "unauthorized"}
    end
  end
end
