defmodule SmsSchool.Accounts.Adress.Commune do
  use Ash.Resource,
    otp_app: :sms_school,
    domain: SmsSchool.Accounts.Adress,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource]

  graphql do
    type :commune
  end

  postgres do
    table "communes"
    repo SmsSchool.Repo

    references do
      reference :district, index?: true, on_delete: :delete
    end

    custom_indexes do
      index "name gin_trgm_ops",
        name: "communes_name_gin_index",
        using: "GIN"
    end
  end

  actions do
    create :create do
      accept [:name, :district_id]
      primary? true
      argument :villages, type: {:array, :map}, public?: true
      change manage_relationship(:villages, arg(:villages), type: :direct_control)
    end

    update :update do
      accept [:name, :district_id]
      primary? true
      change manage_relationship(:villages, arg(:villages), type: :direct_control)
    end

    read :read do
      primary? true
    end

    destroy :destroy do
      primary? true
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
    belongs_to :district, SmsSchool.Accounts.Adress.District do
      allow_nil? false
    end

    has_many :villages, SmsSchool.Accounts.Adress.Village do
      destination_attribute :commune_id
    end
  end
end
