defmodule SmsSchool.LabTessStudent do
  import Ash.Expr
  require Ash.Query
  alias SmsSchool.Accounts.Students
  alias SmsSchool.Accounts.Employee

  def seed_students(count \\ 100) do
    1..count
    |> Stream.map(fn i ->
      %{
        id_card_number: "ID#{i}",
        first_name: Faker.Person.first_name(),
        last_name: Faker.Person.last_name(),
        gender: Enum.random(["Male", "Female"]),
        dob: ~D[2005-01-01],
        phone: "012#{Enum.random(100_000..999_999)}"
      }
    end)
    |> Stream.chunk_every(500)
    |> Enum.each(fn chunk ->
      Ash.Seed.seed!(Students, chunk)
      IO.puts(" បានបញ្ចូលសិស្ស #{Enum.count(chunk)} នាក់រួចរាល់!")
    end)
  end

  @spec search_employees() :: {:ok, any()}
  def search_employees(search_term \\ "son", limit \\ 10) do
    {micro, results} =
      :timer.tc(fn ->
        Employee
        |> Ash.Query.filter(
          expr(
            contains(first_name, ^search_term) or
              contains(last_name, ^search_term)
          )
        )
        |> Ash.Query.limit(limit)
        |> Ash.read!()
      end)

    IO.puts("Count: #{micro / 1000} ms")
    {:ok, results}
  end

  def seed_employees(count \\ 1000) do
    1..count
    |> Stream.map(fn i ->
      %{
        first_name: Faker.Person.first_name(),
        last_name: Faker.Person.last_name(),
        gender: Enum.random(["
                Male", "Female
          "]),
        dob: ~D[1990-01-01],
        phone: "012#{Enum.random(100_000..999_999)}"
      }
    end)
    |> Stream.chunk_every(500)
    |> Enum.each(fn chunk ->
      Ash.Seed.seed!(SmsSchool.Accounts.Employee, chunk)
      IO.puts(" បានបញ្ចូលបុគ្គលិក #{Enum.count(chunk)} នាក់រួចរាល់!")
    end)
  end

  def seed_employees_with_jobs(count \\ 1000) do
    1..count
    |> Stream.map(fn i ->
      %{
        first_name: Faker.Person.first_name(),
        last_name: Faker.Person.last_name(),
        gender: Enum.random(["Male", "Female"]),
        dob: ~D[1990-01-01],
        phone: "012#{Enum.random(100_000..999_999)}",
        jobs: [
          %{
            title: "Job #{Enum.random(1..5)}",
            description: "Description for Job #{Enum.random(1..5)}"
          }
        ]
      }
    end)
    |> Stream.chunk_every(500)
    |> Enum.each(fn chunk ->
      Ash.Seed.seed!(SmsSchool.Accounts.Employee, chunk)
      IO.puts(" បានបញ្ចូលបុគ្គលិក #{Enum.count(chunk)} នាក់រួចរាល់!")
    end)
  end

  def search_employees_with_jobs(search_term \\ "son", limit \\ 10) do
    {micro, results} =
      :timer.tc(fn ->
        Employee
        |> Ash.Query.filter(
          expr(
            contains(first_name, ^search_term) or
              contains(last_name, ^search_term)
          )
        )
        |> Ash.Query.limit(limit)
        |> Ash.read!()
        |> Ash.load!(:jobs)
      end)

    IO.puts("Count: #{micro / 1000} ms")
    {:ok, results}
  end

  def update_employee_with_jobs(employee_id, new_first_name) do
    {micro, result} =
      :timer.tc(fn ->
        employee = Ash.get!(Employee, employee_id)

        jobs_to_add = [
          %{
            title: "New Job #{Enum.random(1..5)}",
            description: "Description for New Job #{Enum.random(1..5)}"
          }
        ]

        employee
        |> Ash.Changeset.for_update(:update, %{first_name: new_first_name})
        |> Ash.Changeset.manage_relationship(:jobs, jobs_to_add, type: :direct_control)
        |> Ash.update!()
      end)

    IO.puts("Update Time: #{micro / 1000} ms")
    {:ok, result}
  end

  def seed_provinces_and_districts_with_communes_villages(count \\ 10) do
    1..count
    |> Stream.map(fn i ->
      %{
        name: "Province #{i}",
        districts: [
          %{
            name: "District #{i}-1",
            communes: [
              %{
                name: "Commune #{i}-1-1",
                villages: [
                  %{name: "Village #{i}-1-1-1"},
                  %{name: "Village #{i}-1-1-2"}
                ]
              },
              %{
                name: "Commune #{i}-1-2",
                villages: [
                  %{name: "Village #{i}-1-2-1"},
                  %{name: "Village #{i}-1-2-2"}
                ]
              }
            ]
          },
          %{
            name: "District #{i}-2",
            communes: [
              %{
                name: "Commune #{i}-2-1",
                villages: [
                  %{name: "Village #{i}-2-1-1"},
                  %{name: "Village #{i}-2-1-2"}
                ]
              },
              %{
                name: "Commune #{i}-2-2",
                villages: [
                  %{name: "Village #{i}-2-2-1"},
                  %{name: "Village #{i}-2-2-2"}
                ]
              }
            ]
          }
        ]
      }
    end)
    |> Stream.chunk_every(5)
    |> Enum.each(fn chunk ->
      Ash.Seed.seed!(SmsSchool.Accounts.Adress.Provie, chunk)
      IO.puts(" បានបញ្ចូលខេត្ត ស្រុក ឃុំ និងភូមិ #{Enum.count(chunk)} នាក់រួចរាល់!")
    end)
  end

  def search_provine_districts_and_communes_villages(search_term \\ "Phnom", limit \\ 1) do
    {micro, results} =
      :timer.tc(fn ->
        SmsSchool.Accounts.Adress.Provie
        |> Ash.Query.filter(contains(name, ^search_term))
        |> Ash.Query.limit(limit)
        |> Ash.read!()
        |> Ash.load!(
          districts: [
            communes: :villages
          ]
        )
      end)

    IO.puts("Count: #{micro / 1000} ms")
    {:ok, results}
  end

  def search_provinces_and_districts(search_term \\ "Province 1", limit \\ 10) do
    {micro, results} =
      :timer.tc(fn ->
        SmsSchool.Accounts.Adress.Provie
        |> Ash.Query.filter(contains(name, ^search_term))
        |> Ash.Query.limit(limit)
        |> Ash.read!()
        |> Ash.load!(:districts)
      end)

    IO.puts("Count: #{micro / 1000} ms")
    {:ok, results}
  end
end
