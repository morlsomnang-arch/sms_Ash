defmodule SmsSchool.Accounts.Job do
  use Ash.Resource,
    otp_app: :sms_school,
    domain: SmsSchool.Accounts,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "jobs"
    repo SmsSchool.Repo

    references do
      reference :employee, index?: true, on_delete: :delete
    end
  end

  actions do
    create :create do
      accept [:title, :description, :employee_id]
      primary? true
    end
    update :update do
      accept [:title, :description]
      primary? true
    end

    read :read do
      primary? true
    end

    destroy :destroy do
      primary? true
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string
    attribute :description, :string
  end

  relationships do
    belongs_to :employee, SmsSchool.Accounts.Employee do
      allow_nil? false
    end
  end
end
