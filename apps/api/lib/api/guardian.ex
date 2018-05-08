defmodule Api.Guardian do
  use Guardian, otp_app: :api

  alias Api.Validate

  def subject_for_token(%{email: _, name: _, image: _} = user, _claims) do
    {:ok, user}
  end

  def subject_for_token(_, _) do
    {:error, :no_info}
  end

  def resource_from_claims(%{"sub" => user}) do
    Validate.valid(user)
  end
    
  def resource_from_claims(_) do
    {:error, :no_subject}
  end
end
