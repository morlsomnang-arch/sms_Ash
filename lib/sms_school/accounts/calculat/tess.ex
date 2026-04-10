defmodule SmsSchool.Accounts.Calculat.Tess do
 use Ash.Resource.Calculation

  def calculate(records, _opts, _context) do
    Enum.map(records, fn record ->
      "Class Type: #{record.name}"
    end)
  end
end
