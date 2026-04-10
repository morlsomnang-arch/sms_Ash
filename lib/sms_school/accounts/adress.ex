defmodule SmsSchool.Accounts.Adress do
  use Ash.Domain,
    otp_app: :sms_school,
    extensions: [AshGraphql.Domain]

  graphql(
    queries: [
      list: [
        SmsSchool.Accounts.Adress.Provie,
        SmsSchool.Accounts.Adress.District,
        SmsSchool.Accounts.Adress.Commune,
        SmsSchool.Accounts.Adress.Village
      ]
    ]
  )

  resources do
    resource SmsSchool.Accounts.Adress.Provie
    resource SmsSchool.Accounts.Adress.District
    resource SmsSchool.Accounts.Adress.Commune
    resource SmsSchool.Accounts.Adress.Village
    resource SmsSchool.Accounts.Adress.StudentAddress
  end
end
