defmodule SmsSchool.Accounts.Employee do
  use Ash.Resource,
    otp_app: :sms_school,
    domain: SmsSchool.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource]

  graphql do
    type :employee
  end

  postgres do
    table "employees"
    repo SmsSchool.Repo

    custom_indexes do
      index "first_name gin_trgm_ops", name: "employee_first_name_gin_index", using: "GIN"
      index "last_name gin_trgm_ops", name: "employee_last_name_gin_index", using: "GIN"
    end
  end

  actions do
    read :read do
      primary? true

      pagination do
        offset? true
        default_limit 500
        max_page_size 500
        countable true
      end
    end

    read :search do
      argument :query, :ci_string do
        constraints allow_empty?: true
        default ""
      end

      pagination offset?: true, default_limit: 12, max_page_size: 2000, countable: true

      filter expr(
               contains(first_name, ^arg(:query)) or
                 contains(last_name, ^arg(:query))
             )
    end

    create :create do
      accept [:first_name, :last_name, :gender, :dob, :phone, :image]

      argument :jobs, {:array, :map}

      change manage_relationship(
               :jobs,
               type: :direct_control
             )
    end

    update :update do
      accept [:first_name, :last_name, :gender, :dob, :phone, :image]
      require_atomic? false

      argument :jobs, {:array, :map}

      change manage_relationship(:jobs, type: :direct_control)
    end

    destroy :destroy do
      primary? true
    end
  end

  policies do
    bypass actor_attribute_equals(:role, :admin) do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type([:create, :update]) do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id do
      public? true
    end

    attribute :first_name, :string do
      allow_nil? false
      public? true
    end

    attribute :last_name, :string do
      allow_nil? false
      public? true
    end

    attribute :gender, :string do
      allow_nil? false
      public? true
    end

    attribute :dob, :date do
      allow_nil? false
      public? true
    end

    attribute :phone, :string do
      allow_nil? false
      public? true
    end

    attribute :image, :string do
      allow_nil? true
      public? true
    end
  end

  relationships do
    has_many :jobs, SmsSchool.Accounts.Job do
    end
  end
end
