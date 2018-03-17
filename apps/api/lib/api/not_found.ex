defmodule Api.NotFound do
  defexception message: "not found"
end

defimpl Plug.Exception, for: Api.NotFound do
  def status(_exception), do: 404
end


