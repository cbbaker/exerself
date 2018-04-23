defmodule Api.Router do
  use Api.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Api.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Api.Auth
  end

  scope "/auth", Api do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  scope "/", Api do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/data-sources", DataSourceController, :static
    get "/data-sources/:data_source", DataController, :static
  end

  # Other scopes may use custom stacks.
  scope "/api", Api do
    pipe_through :api

    resources "/data-sources", DataSourceController, only: [:index, :create, :show, :delete] do
      resources "/data", DataController, only: [:show, :create, :update, :delete]
    end
  end
end
