defmodule SmsSchool.Accounts.Adress.StudentAddress do
  use Ash.Resource,
    otp_app: :sms_school,
    domain: SmsSchool.Accounts.Adress,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "student_addresses"
    repo SmsSchool.Repo

    custom_indexes do
      index "student_id", name: "student_addresses_student_id_index"
      index "village_id", name: "student_addresses_village_id_index"
    end

    references do
      reference :student, index?: true, on_delete: :delete
      reference :village, index?: true, on_delete: :delete
    end
  end

  actions do
    create :create do
      accept [:student_id, :village_id]
      primary? true
      change manage_relationship(:student, arg(:student_id), type: :direct_control)
      change manage_relationship(:village, arg(:village_id), type: :direct_control)
    end

    update :update do
      accept [:student_id, :village_id]
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
    attribute :id, :uuid, public?: true
    attribute :student_id, :uuid
    attribute :village_id, :uuid
    timestamps()
  end

  relationships do
    belongs_to :student, SmsSchool.Accounts.Students do
      allow_nil? false
    end

    belongs_to :village, SmsSchool.Accounts.Adress.Village do
      allow_nil? false
    end
  end
end
