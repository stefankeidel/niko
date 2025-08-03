defmodule Niko.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NikoWeb.Telemetry,
      Niko.Repo,
      {DNSCluster, query: Application.get_env(:niko, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Niko.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Niko.Finch},
      # Start a worker by calling: Niko.Worker.start_link(arg)
      # {Niko.Worker, arg},
      # Start to serve requests, typically the last entry
      NikoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Niko.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NikoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
