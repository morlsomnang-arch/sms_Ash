defmodule SmsSchool.Tessing.Production do
  def seed_cambodia_addresses() do
    data = [
      %{
        name: "Phnom Penh",
        districts: [
          %{
            name: "Chamkar Mon",
            communes: [
              %{
                name: "Tonle Bassac",
                villages: [
                  %{name: "Village 1"},
                  %{name: "Village 2"}
                ]
              },
              %{
                name: "Boeng Keng Kang 1",
                villages: [
                  %{name: "Village A"},
                  %{name: "Village B"}
                ]
              }
            ]
          },
          %{
            name: "Daun Penh",
            communes: [
              %{
                name: "Phsar Thmei",
                villages: [
                  %{name: "Village 1"},
                  %{name: "Village 2"}
                ]
              }
            ]
          }
        ]
      },
      %{
        name: "Siem Reap",
        districts: [
          %{
            name: "Siem Reap",
            communes: [
              %{
                name: "Sala Kamreuk",
                villages: [
                  %{name: "Village 1"},
                  %{name: "Village 2"}
                ]
              }
            ]
          }
        ]
      },
      %{
        name: "Battambang",
        districts: [
          %{
            name: "Battambang",
            communes: [
              %{
                name: "Svay Por",
                villages: [
                  %{name: "Village 1"},
                  %{name: "Village 2"}
                ]
              }
            ]
          }
        ]
      }
    ]

    Ash.Seed.seed!(SmsSchool.Accounts.Adress.Provie, data)

    IO.puts(" បានបញ្ចូលទិន្នន័យកម្ពុជា (ខេត្ត ស្រុក ឃុំ ភូមិ) រួចរាល់!")
  end

  def seed do
    data = [
      %{
        name: "Phnom Penh",
        districts: [
          %{
            name: "Chamkarmon",
            communes: [
              %{
                name: "Toul Svay Prey 1",
                villages: [
                  %{name: "Village 1"},
                  %{name: "Village 2"}
                ]
              }
            ]
          }
        ]
      }
    ]

    Ash.Seed.seed!(
      StudentAddress,
      [
        %{
          student_id: "some-student-uuid",
          village_id: "some-village-uuid"
        }
      ],
      data
    )

    IO.puts(" បានបញ្ចូលទិន្នន័យកម្ពុជា (ខេត្ត ស្រុក ឃុំ ភូមិ) រួចរាល់!")
  end

  def get_provies do
    SmsSchool.Accounts.Adress.Provie
    |> Ash.Query.new()
    |> Ash.read()
  end

  def getStudent do
    SmsSchool.Accounts.Students
    |> Ash.Query.new()
    |> Ash.read()
  end
end
