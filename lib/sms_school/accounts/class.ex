defmodule SmsSchool.Accounts.Class do
  use Ash.Resource,
    otp_app: :sms_school,
    domain: SmsSchool.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    authorizers: [Ash.Policy.Authorizer]

  graphql do
    type :class
  end

  postgres do
    table "classes"
    repo SmsSchool.Repo

    custom_indexes do
      index "name gin_trgm_ops", name: "class_name_gin_index", using: "GIN"
    end
  end

  actions do
    read :read do
      primary? true

      prepare fn query, _context ->
        IO.inspect(self(), label: " Request By Process========")
        query
      end

      pagination do
        offset? true
        default_limit 12
        max_page_size 1000
        countable true
      end
    end

    create :create do
      accept [:name]
    end

    update :update do
      accept [:name]
    end

    read :search do
      argument :query, :ci_string do
        constraints allow_empty?: true
        default ""
      end

      pagination offset?: true, default_limit: 12, max_page_size: 2000, countable: true

      filter expr(contains(name, ^arg(:query)))
    end

    destroy :destroy do
    end
  end

  policies do
    bypass actor_attribute_equals(:role, "admin") do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if always()
    end

    policy action([:update, :create]) do
      authorize_if actor_attribute_equals(:role, "editor")
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    timestamps()
  end

  relationships do
    has_many :class_types, SmsSchool.Accounts.ClassType do
      sort name: :asc
      public? true
    end
  end

  calculations do
    calculate :count_of_types, :integer, expr(count(class_types)) do
      public? true
    end
  end

  aggregates do
    count :class_type_count, :class_types do
      public? true
    end
  end
end

#  SmsSchool.Accounts.search_class("son", load: [:class_type_count])

# require Ash.Query; SmsSchool.Accounts.Class |> Ash.Query.limit(5) |> Ash.read!() |> Ash.load!([:count_of_types]) |> Enum.each(fn c -> IO.puts(" #{c.name} |  Calc Count: #{c.count_of_types}") end)
