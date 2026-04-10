defmodule SmsSchool.Accounts.Adress.Village do
  use Ash.Resource,
    otp_app: :sms_school,
    domain: SmsSchool.Accounts.Adress,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource]

  graphql do
    type :village
  end

  postgres do
    table "villages"
    repo SmsSchool.Repo

    references do
      reference :commune, index?: true, on_delete: :delete
    end

    custom_indexes do
      index "name gin_trgm_ops",
        name: "villages_name_gin_index",
        using: "GIN"
    end
  end

  actions do
    create :create do
      accept [:name, :commune_id]
      primary? true
      argument :villages, type: {:array, :map}, public?: true
    end

    update :update do
      accept [:name, :commune_id]
      primary? true
    end

    read :read do
      primary? true
    end

    destroy :destroy do
    end
  end

  policies do
    bypass actor_attribute_equals(:role, :admin) do
      authorize_if always()
    end

    policy action_type([:read, :create, :update, :destroy]) do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    timestamps()
  end

  relationships do
    belongs_to :commune, SmsSchool.Accounts.Adress.Commune do
      allow_nil? false
    end

    has_many :student_addresses, SmsSchool.Accounts.Adress.StudentAddress do
      destination_attribute :village_id
    end
  end
end
