defmodule SmsSchool.Accounts.Adress.StudentAddress do
  use Ash.Resource,
    otp_app: :sms_school,
    domain: SmsSchool.Accounts.Adress,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource]

    graphql do
      type :student_address
    end

  postgres do
    table "student_addresses"
    repo SmsSchool.Repo

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
    end

    destroy :destroy do
      primary? true
    end
  end

  attributes do
    attribute :id, :uuid, public?: true
    attribute :student_id, :uuid, public?: true
    attribute :village_id, :uuid, public?: true
    timestamps(public?: true)
  end

  policies do
    bypass actor_attribute_equals(:role, :admin) do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if always()
    end

    policy action(:update) do
      authorize_if actor_attribute_equals(:role, :editor)
    end

    policy action(:destroy) do
      authorize_if actor_attribute_equals(:role, :admin)
    end
  end


  relationships do
    belongs_to :student, SmsSchool.Accounts.Students do
      allow_nil? false
      public? true
    end

    belongs_to :village, SmsSchool.Accounts.Adress.Village do
      allow_nil? false
      public? true
    end
  end

end
