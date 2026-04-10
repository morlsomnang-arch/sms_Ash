defmodule SmsSchool.Accounts.Students do
  use Ash.Resource.Preparation

  use Ash.Resource,
    otp_app: :sms_school,
    domain: SmsSchool.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource]

  graphql do
    type :students
  end

  postgres do
    table "students"
    repo SmsSchool.Repo

    custom_indexes do
      index "first_name gin_trgm_ops",
        name: "students_first_name_gin_index",
        using: "GIN"

      index "last_name gin_trgm_ops",
        name: "students_last_name_gin_index",
        using: "GIN"
    end
  end

  actions do
    defaults [:destroy]

    read :read do
      primary? true

      prepare fn query, _context ->
        IO.inspect(self(), label: " Request Process PID (Runtime)")
        query
      end

      pagination do
        offset? true
        default_limit 500
        max_page_size 500
        countable true
      end

      prepare build(
                load: [
                  student_addresses: [
                    village: [
                      commune: [
                        district: [
                          :provie
                        ]
                      ]
                    ]
                  ]
                ]
              )
    end

    create :create do
      primary? true
      argument :student_addresses, type: {:array, :map}, public?: true

      change manage_relationship(:student_addresses, arg(:student_addresses),
               type: :direct_control
             )

      accept [:id_card_number, :first_name, :last_name, :gender, :dob, :phone, :image]
    end
  end

  policies do
    bypass actor_attribute_equals(:role, :admin) do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if actor_attribute_equals(:role, :admin)
    end

    policy action(:update) do
      authorize_if actor_attribute_equals(:role, :editor)
    end

    policy action(:destroy) do
      authorize_if actor_attribute_equals(:role, :admin)
    end
  end

  attributes do
    uuid_primary_key :id do
      public? true
    end

    attribute :id_card_number, :string do
      public? true
      allow_nil? false
    end

    attribute :first_name, :string do
      public? true
      allow_nil? false
    end

    attribute :last_name, :string do
      public? true
      allow_nil? false
    end

    attribute :gender, :string do
      public? true
      allow_nil? false
    end

    attribute :dob, :date do
      public? true
      allow_nil? false
    end

    attribute :phone, :string do
      public? true
      allow_nil? false
    end

    attribute :image, :string do
      public? true
    end

    timestamps()
  end

  relationships do
    has_many :student_addresses, SmsSchool.Accounts.Adress.StudentAddress do
      destination_attribute :student_id
    end
  end

  calculations do
    calculate :formatted_dob,
              :string,
              expr(fragment("to_char(?, 'DD/MM/YYYY')", dob)) do
      public? true
    end

    calculate :full_name, :string, expr(fragment("? || ' ' || ?", first_name, last_name)) do
      public? true
    end

    calculate :formatted_phone,
              :string,
              expr(fragment("concat('+855', substring(?, 4))", phone)) do
      public? true
    end

    calculate :age, :integer, expr(fragment("date_part('year', age(?))", dob)) do
      public? true
    end
  end
end
