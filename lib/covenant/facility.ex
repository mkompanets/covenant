defmodule Covenant.Facility do
  defstruct [:amount, :interest_rate, :id, :bank_id]
  alias Covenant.Facility

  def parse_data(rows_of_data) do
    rows_of_data
    |> Enum.map(fn([amount, interest_rate, id, bank_id]) ->
      %Facility{
        amount: amount,
        interest_rate: interest_rate,
        id: id,
        bank_id: bank_id
      }
    end)
  end
end
