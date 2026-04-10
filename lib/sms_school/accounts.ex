defmodule SmsSchool.Accounts do
  use Ash.Domain, otp_app: :sms_school, extensions: [AshGraphql.Domain]

  graphql do
    queries do
      list SmsSchool.Accounts.User, :get_user_all, :read

      list SmsSchool.Accounts.Class, :search_classes, :search
      list SmsSchool.Accounts.Class, :get_class, :read
      list SmsSchool.Accounts.ClassType, :get_class_type, :read
      list SmsSchool.Accounts.Students, :get_students, :read
    end

    mutations do
      create SmsSchool.Accounts.Students, :create_students, :create
      create SmsSchool.Accounts.User, :register_user, :register_with_password
      create SmsSchool.Accounts.User, :register_with_password, action: :register_with_password
      create SmsSchool.Accounts.Class, :create_class, :create
      destroy SmsSchool.Accounts.Class, :delete_class_type, :destroy
    end
  end

  resources do
    resource SmsSchool.Accounts.Token

    resource SmsSchool.Accounts.User do
      define :set_user_role, action: :set_role, args: [:role]
      define :get_user_by_email, action: :get_by_email, args: [:email]
    end

    resource SmsSchool.Accounts.Students do
      define :read_students, action: :read
      define :create_students, action: :create
    end

    resource SmsSchool.Accounts.Class do
      define :reade_class, action: :read
      define :create_class, action: :create

      define :search_class,
        action: :search,
        args: [:query],
        default_options: [
          load: [
            :count_of_types
          ]
        ]
    end

    resource SmsSchool.Accounts.ClassType do
      define :get_class_type_by_id, action: :read, get_by: :id
      define :get_class_type, action: :read
      define :create_class_type, action: :create
      define :delete_class_type, action: :destroy
    end

    resource SmsSchool.Accounts.Employee do
      define :read_employee, action: :read
      define :create_employee, action: :create
    end

    resource SmsSchool.Accounts.Job
  end
end
