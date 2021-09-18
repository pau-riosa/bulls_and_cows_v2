defmodule BullsAndCowsV2.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      # Start the Ecto repository
      BullsAndCowsV2.Repo,
      # Start the Telemetry supervisor
      BullsAndCowsV2Web.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: BullsAndCowsV2.PubSub},
      {Cluster.Supervisor, [topologies, [name: BullsAndCowsV2.ClusterSupervisor]]},
      {Horde.Registry, [name: BullsAndCowsV2.GameRegistry, keys: :unique, members: :auto]},
      {Horde.DynamicSupervisor,
       [
         name: BullsAndCowsV2.DistributedSupervisor,
         shutdown: 1_000,
         strategy: :one_for_one,
         members: :auto
       ]},
      # Start the Endpoint (http/https)
      BullsAndCowsV2Web.Endpoint
      # Start a worker by calling: BullsAndCowsV2.Worker.start_link(arg)
      # {BullsAndCowsV2.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BullsAndCowsV2.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BullsAndCowsV2Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
