defmodule SmsSchool.Accounts.Adress.Provie do
  use Ash.Resource,
    otp_app: :sms_school,
    domain: SmsSchool.Accounts.Adress,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource]

  graphql do
    type :provie
  end

  postgres do
    table "provies"
    repo SmsSchool.Repo

    custom_indexes do
      index "name gin_trgm_ops",
        name: "provies_name_gin_index",
        using: "GIN"
    end
  end

  actions do
    create :create do
      accept [:name]
      primary? true
      argument :districts, type: {:array, :map}, public?: true
      change manage_relationship(:districts, arg(:districts), type: :direct_control)
    end

    update :update do
      accept [:name]
      primary? true
      change manage_relationship(:districts, arg(:districts), type: :direct_control)
    end

    read :full do
      primary? true

      pagination do
        offset? true
        default_limit 500
        max_page_size 500
        countable true
      end

      prepare build(
                load: [
                  districts: [
                    communes: [
                      villages: []
                    ]
                  ]
                ]
              )
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
    has_many :districts, SmsSchool.Accounts.Adress.District do
    end
  end

  calculations do
    calculate :count_of_provies, :integer, expr(count())
  end
end
