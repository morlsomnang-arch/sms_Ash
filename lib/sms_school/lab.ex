defmodule SmsSchool.Lab do
  alias SmsSchool.Accounts.User
  alias SmsSchool.Accounts.Class
  alias SmsSchool.Accounts.ClassType
  require Ash.Query
  @email "users123@gmail.com"
  @password "users123@gmail.com"

  def create_athenticatio() do
    SmsSchool.Accounts.User
    |> Ash.Changeset.for_create(:register_with_password, %{
      email: @email,
      password: @password,
      password_confirmation: @password
    })
    |> Ash.create!(authorize?: false)
    |> then(fn user ->
      token = user.__metadata__[:token]
      IO.puts("--- User Created Successfully ---")
      IO.puts("Email: #{user.email}")
      IO.puts("Token: #{token}")
      user
    end)
  end

  def test_request_magic_link(email \\ @email) do
    SmsSchool.Accounts.User
    |> Ash.ActionInput.for_action(:request_magic_link, %{email: email})
    |> Ash.run_action(authorize?: false)
  end

  def get_user(email \\ @email) do
    SmsSchool.Accounts.User
    |> Ash.Query.for_read(:get_by_email, %{email: email})
    |> Ash.read_one(authorize?: false)
  end

  def get_all_user do
    SmsSchool.Accounts.User
    |> Ash.read(authorize?: false)
  end

  def tess_class do
    Class
    |> Ash.read(authorize?: false)
  end

  def create(params \\ %{}) do
    SmsSchool.Accounts.create_class(params, authorize?: false)
  end

  def red_class_stream do
    ClassType
    |> Ash.stream!(actor: :admin, batch_size: 10)
    |> Stream.take(20)
    |> Enum.each(fn ct ->
      IO.inspect(ct.name, label: "==|==")
    end)
  end

  def millon_records do
    total = 22_000

    chunk_size = 500

    1..total
    |> Stream.map(fn _ -> %{name: Faker.Company.name()} end)
    |> Stream.chunk_every(chunk_size)
    |> Enum.each(fn chunk ->
      Ash.Seed.seed!(SmsSchool.Accounts.Class, chunk)
      IO.puts("Inserted #{chunk_size} records...")
    end)
  end

  def test_search_speed(search_term \\ "Son") do
    {micro, results} =
      :timer.tc(fn ->
        SmsSchool.Accounts.Class
        |> Ash.Query.filter(contains(name, ^search_term))
        |> Ash.read!()
        |> Ash.load!([:count_of_types])
      end)

    IO.puts("------------------------------------")
    IO.puts("Finde: \"#{search_term}\"")
    IO.puts(" TimeSeach: #{micro / 1000} ms")
    IO.puts(" Toatal: #{Enum.count(results)} records")
    IO.puts("------------------------------------")

    {:ok, results}
  end

  def seed_class_types_bulk(count \\ 10000) do
    require Ash.Query
    alias SmsSchool.Accounts.{Class, ClassType}

    class = Class |> Ash.Query.limit(1) |> Ash.read_one!()

    if is_nil(class) do
      IO.puts(" រកមិនឃើញ Class ទេ")
    else
      1..count
      |> Stream.map(fn i ->
        %{
          name: "Type-#{i}-#{Faker.Commerce.department()}",
          class_id: class.id
        }
      end)
      |> Stream.chunk_every(1000)
      |> Enum.each(fn chunk ->
        Ash.Seed.seed!(ClassType, chunk)
        IO.puts(" បានបញ្ចូល ១,០០០ records")
      end)
    end
  end

  def seed_nested_data(num_classes \\ 10) do
    classes_data =
      Enum.map(1..num_classes, fn i ->
        %{name: "Class #{i} - #{Faker.Address.city()}"}
      end)

    inserted_classes = Ash.Seed.seed!(Class, classes_data)

    class_types_data =
      inserted_classes
      |> Enum.flat_map(fn class ->
        Enum.map(1..5, fn j ->
          %{
            name: "Type #{j} for #{class.name}",
            class_id: class.id
          }
        end)
      end)

    Ash.Seed.seed!(ClassType, class_types_data)

    IO.puts("input___#{num_classes} Classes & #{Enum.count(class_types_data)} ClassTypes រួចរាល់!")
  end

  def test_e(search_term \\ "Son", limit \\ 10) do
    {micro, results} =
      :timer.tc(fn ->
        SmsSchool.Accounts.Class
        |> Ash.Query.filter(contains(name, ^search_term))
        |> Ash.Query.limit(limit)
        |> Ash.read!()
        |> Ash.load!([:count_of_types])
      end)

    IO.puts(" Count: #{micro / 1000} ms")
    {:ok, results}
  end

  def search_student(search_term \\ "the", limit \\ 1000) do
    {micro, results} =
      :timer.tc(fn ->
        SmsSchool.Accounts.Students
        |> Ash.Query.filter(
          contains(first_name, ^search_term) or contains(last_name, ^search_term)
        )
        |> Ash.Query.limit(limit)
        |> Ash.read!()
      end)

    IO.puts(" Count: #{micro / 1000} ms")
    {:ok, results}
  end
end
