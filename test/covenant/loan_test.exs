defmodule Covenant.LoanTest do
  use ExUnit.Case
  alias Covenant.Loan
  alias Covenant.Utils.CSVParser

  describe "parse_data/1" do
    setup do
      path = "#{File.cwd!()}/reference_data/small/loans.csv"
      [data: CSVParser.parse(path)]
    end

    test "returns a list of loans", %{data: loans_data} do
      loans = Loan.parse_data(loans_data)
      assert [%Loan{} | _] = loans
    end
  end
end
