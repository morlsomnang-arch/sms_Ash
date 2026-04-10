defmodule SmsSchool.Accounts.ClassType do
  use Ash.Resource,
    otp_app: :sms_school,
    domain: SmsSchool.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type :class_type
  end

  postgres do
    table "class_types"
    repo SmsSchool.Repo

    references do
      reference :class, index?: true, on_delete: :delete
    end

    custom_indexes do
      index "name gin_trgm_ops", name: "class_type_name_gin_index", using: "GIN"
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:name, :class_id]
    end

    update :update do
      accept [:name, :class_id]
    end

    read :search do
      argument :query, :ci_string do
        constraints allow_empty?: true
        default ""
      end

      pagination offset?: true, default_limit: 12

      filter expr(contains(name, ^arg(:query)))
    end
  end

  validations do
  end

  attributes do
    uuid_primary_key :id do
      public? true
    end

    attribute :name, :string do
      allow_nil? false
      public? true
    end
  end

  relationships do
    belongs_to :class, SmsSchool.Accounts.Class do
      public? true
      allow_nil? false
    end
  end

  calculations do
    calculate :formating_name, :string, SmsSchool.Accounts.Calculat.Tess do
      public? true
    end
  end

  identities do
    identity :unique_class_type_name_per_class, [:name, :class_id],
      message: "This name aredy exit"
  end
end
