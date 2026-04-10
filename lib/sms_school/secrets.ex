defmodule SmsSchool.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        SmsSchool.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:sms_school, :token_signing_secret)
  end
end
