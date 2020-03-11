defmodule Covenant.BankTest do
  use ExUnit.Case
  alias Covenant.Bank
  alias Covenant.Utils.CSVParser

  describe "parse_data/1" do
    setup do
      path = "#{File.cwd!()}/reference_data/small/banks.csv"
      [data: CSVParser.parse(path)]
    end

    test "returns a list of banks", %{data: banks_data} do
      banks = Bank.parse_data(banks_data)
      assert [%Bank{} | _] = banks
    end
  end
end
