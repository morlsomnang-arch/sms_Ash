defmodule SmsSchool.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SmsSchoolWeb.Telemetry,
      SmsSchool.Repo,
      {DNSCluster, query: Application.get_env(:sms_school, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SmsSchool.PubSub},
      # Start a worker by calling: SmsSchool.Worker.start_link(arg)
      # {SmsSchool.Worker, arg},
      # Start to serve requests, typically the last entry
      SmsSchoolWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :sms_school]},
      {Absinthe.Subscription, SmsSchoolWeb.Endpoint},
      AshGraphql.Subscription.Batcher
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SmsSchool.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SmsSchoolWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
