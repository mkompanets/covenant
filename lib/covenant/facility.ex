defmodule Covenant.Facility do
  defstruct [:amount, :interest_rate, :id, :bank_id]
  alias Covenant.Facility

  def init([amount, interest_rate, id, bank_id]) do
    %Facility{
      amount: amount,
      interest_rate: interest_rate,
      id: id,
      bank_id: bank_id
    }
  end

  def parse_data(rows_of_data) do
    rows_of_data |> Enum.map(&init/1)
  end
end
