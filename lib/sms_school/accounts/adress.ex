defmodule SmsSchool.Accounts.Adress do
  use Ash.Domain,
    otp_app: :sms_school,
    extensions: [AshGraphql.Domain]

  graphql do
    queries do
      list SmsSchool.Accounts.Adress.Provie, :get_provies, :full
      list SmsSchool.Accounts.Adress.District, :get_districts, :read
      list SmsSchool.Accounts.Adress.Commune, :get_communes, :read
      list SmsSchool.Accounts.Adress.Village, :get_villages, :read
    end

  end
  resources do
    resource SmsSchool.Accounts.Adress.Provie
    resource SmsSchool.Accounts.Adress.District
    resource SmsSchool.Accounts.Adress.Commune
    resource SmsSchool.Accounts.Adress.Village
    resource SmsSchool.Accounts.Adress.StudentAddress
  end
end
