defmodule Covenant.LoanProcessorTest do
  use ExUnit.Case
  alias Covenant.{Bank, Facility, Covenants, LoanProcessor}

  describe "reject_facility_ids_by_state/3" do
    setup do
      bank = Bank.init(["1", "Michaelsons"])

      covenant_1 = %Covenants{
        facility_id: "33",
        max_default_likelihood: "",
        bank_id: "1",
        banned_state: "MN"
      }

      covenant_2 = %Covenants{
        facility_id: "22",
        max_default_likelihood: "",
        bank_id: "1",
        banned_state: "TX"
      }

      # no facility == all facilities
      covenant_3 = %Covenants{
        max_default_likelihood: "",
        bank_id: "1",
        banned_state: "AL"
      }

      facility_1 = %Facility{
        amount: 5000,
        interest_rate: 0.4,
        id: "33",
        bank_id: "1"
      }

      bank = Bank.add_covenant(bank, covenant_1)
      bank = Bank.add_covenant(bank, covenant_2)
      bank = Bank.add_covenant(bank, covenant_3)
      bank = Bank.add_facility(bank, facility_1)
      [bank: bank]
    end

    test "rejects MN", %{bank: bank} do
      assert ["33"] = LoanProcessor.reject_facility_ids_by_state(bank, "MN", [])
    end

    test "rejects nothing on non-existant state", %{bank: bank} do
      assert [] = LoanProcessor.reject_facility_ids_by_state(bank, "AA", [])
    end

    test "keeps existing rejections", %{bank: bank} do
      assert ["123", "999"] =
               LoanProcessor.reject_facility_ids_by_state(bank, "AA", ["123", "999"])
    end

    test "rejects facility from state if no facility id in covenant", %{bank: bank} do
      assert ["33"] = LoanProcessor.reject_facility_ids_by_state(bank, "AL", [])
    end
  end

  describe "reject_facility_ids_by_default_concerns/3" do
    setup do
      bank = Bank.init(["1", "Michaelsons"])

      covenant_1 = %Covenants{
        facility_id: "33",
        max_default_likelihood: 0.1,
        bank_id: "1",
        banned_state: "MN"
      }

      covenant_2 = %Covenants{
        facility_id: "22",
        max_default_likelihood: 0.3,
        bank_id: "1",
        banned_state: "TX"
      }

      # no facility == all facilities
      covenant_3 = %Covenants{
        max_default_likelihood: 0.05,
        bank_id: "1"
      }

      facility_1 = %Facility{
        amount: 5000,
        interest_rate: 0.4,
        id: "335",
        bank_id: "1"
      }

      bank = Bank.add_covenant(bank, covenant_1)
      bank = Bank.add_covenant(bank, covenant_2)
      bank = Bank.add_covenant(bank, covenant_3)
      bank = Bank.add_facility(bank, facility_1)
      [bank: bank]
    end

    test "rejects 33 since interest is 0.15", %{bank: bank} do
      assert ["33"] = LoanProcessor.reject_facility_ids_by_default_concerns(bank, 0.15, [])
    end

    test "rejects nothing low default possibility", %{bank: bank} do
      assert [] = LoanProcessor.reject_facility_ids_by_default_concerns(bank, 0.01, [])
    end

    test "keeps existing rejections", %{bank: bank} do
      assert ["123", "999"] =
               LoanProcessor.reject_facility_ids_by_default_concerns(bank, 0.01, ["123", "999"])
    end

    test "rejects all facilities by rate", %{bank: bank} do
      assert ["335"] = LoanProcessor.reject_facility_ids_by_default_concerns(bank, 0.06, [])
    end
  end

  describe "reject_facility_ids_by_ammount/3" do
    setup do
      bank = Bank.init(["1", "Michaelsons"])

      facility_1 = %Facility{
        amount: 5000,
        interest_rate: 0.4,
        id: "335",
        bank_id: "1"
      }

      bank = Bank.add_facility(bank, facility_1)
      [bank: bank]
    end

    test "facility gets rejected for greater amount", %{bank: bank} do
      assert ["335"] = LoanProcessor.reject_facility_ids_by_ammount(bank, 8000, [])
    end

    test "facility does not get rejected for lesser amount", %{bank: bank} do
      assert [] = LoanProcessor.reject_facility_ids_by_ammount(bank, 4999, [])
    end
  end
end
