defmodule SmsSchool.Accounts.Adress.District do
  use Ash.Resource,
    otp_app: :sms_school,
    domain: SmsSchool.Accounts.Adress,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource]

  graphql do
    type :district
  end

  postgres do
    table "districts"
    repo SmsSchool.Repo

    custom_indexes do
      index "name gin_trgm_ops",
        name: "districts_name_gin_index",
        using: "GIN"
    end
  end

  actions do
    create :create do
      accept [:name, :provie_id]
      primary? true
      argument :communes, type: {:array, :map}, public?: true
      change manage_relationship(:communes, arg(:communes), type: :direct_control)
    end

    update :update do
      accept [:name, :provie_id]
      primary? true
      change manage_relationship(:communes, arg(:communes), type: :direct_control)
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

    policy action_type(:read) do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    timestamps()
  end

  relationships do
    belongs_to :provie, SmsSchool.Accounts.Adress.Provie do
      allow_nil? false
    end

    has_many :communes, SmsSchool.Accounts.Adress.Commune do
      destination_attribute :district_id
    end
  end
end
