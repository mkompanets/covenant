defmodule Covenant.Loan do
  defstruct [:interest_rate, :amount, :id, :default_likelihood, :state]
  alias Covenant.Loan

  def parse_data(rows_of_data) do
    rows_of_data
    |> Enum.map(fn([interest_rate, amount, id, default_likelihood, state]) ->
      %Loan{
        interest_rate: interest_rate,
        amount: amount,
        id: id,
        default_likelihood: default_likelihood,
        state: state
      }
    end)
  end
end
