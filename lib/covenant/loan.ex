defmodule Covenant.Loan do
  defstruct [:interest_rate, :amount, :id, :default_likelihood, :state]
  alias Covenant.Loan

  def init([interest_rate, amount, id, default_likelihood, state]) do
    %Loan{
      interest_rate: interest_rate,
      amount: amount,
      id: id,
      default_likelihood: default_likelihood,
      state: state
    }
  end

  def parse_data(rows_of_data) do
    rows_of_data
    |> Enum.map(&init/1)
  end
end
