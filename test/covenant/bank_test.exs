defmodule Covenant.BankTest do
  use ExUnit.Case
  alias Covenant.{Bank, Facility, Covenants}
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

  describe "add_facility/2" do
    test "adds facility to a bank" do
      bank = Bank.init(["1", "Michaelsons"])
      facility = Facility.init(["5000", "0.1", "2", "1"])
      bank = Bank.add_facility(bank, facility)

      assert [^facility] = bank.facilities
    end
  end

  describe "load_facilities/2" do
    setup do
      path = "#{File.cwd!()}/reference_data/small/facilities.csv"
      [data: CSVParser.parse(path)]
    end

    test "adds facilities to banks from data", %{data: facilities_data} do
      bank = Bank.init(["1", "Michaelsons"])
      banks = Bank.load_facilities([bank], facilities_data)

      [bank] = banks
      assert [%Facility{}] = bank.facilities
    end
  end

  describe "add_covenant/2" do
    test "adds covenant to a bank" do
      bank = Bank.init(["1", "Michaelsons"])
      covenant = Covenants.init(["1", "0.1", "1", "MN"])
      bank = Bank.add_covenant(bank, covenant)

      assert [^covenant] = bank.covenants
    end
  end

  describe "load_covenants/2" do
    setup do
      path = "#{File.cwd!()}/reference_data/small/covenants.csv"
      [data: CSVParser.parse(path)]
    end

    test "adds covenants to banks from data", %{data: covenants_data} do
      bank = Bank.init(["1", "Michaelsons"])
      banks = Bank.load_covenants([bank], covenants_data)

      [bank] = banks
      assert [%Covenants{}] = bank.covenants
    end
  end
end
