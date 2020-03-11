defmodule Covenant.Loan do
  defstruct [:interest_rate, :amount, :id, :default_likelihood, :state]
  alias Covenant.Loan
  alias Covenant.Utils

  def init([interest_rate, amount, id, default_likelihood, state]) do
    %Loan{
      interest_rate: Utils.to_float(interest_rate),
      amount: Utils.to_integer(amount),
      id: id,
      default_likelihood: Utils.to_float(default_likelihood),
      state: state
    }
  end

  def parse_data(rows_of_data) do
    rows_of_data
    |> Enum.map(&init/1)
  end
end
