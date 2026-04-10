defmodule SmsSchool.Repo do
  use AshPostgres.Repo,
    otp_app: :sms_school

  @impl true
  def installed_extensions do
    ["ash-functions", "citext", "pg_trgm"]
  end

  @impl true
  def prefer_transaction? do
    false
  end

  @impl true
  def min_pg_version do
    %Version{major: 16, minor: 0, patch: 0}
  end
end

