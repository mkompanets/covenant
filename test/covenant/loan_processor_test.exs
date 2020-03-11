defmodule Covenant.LoanProcessorTest do
  use ExUnit.Case
  alias Covenant.{Bank, Covenants, LoanProcessor}

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
      bank = Bank.add_covenant(bank, covenant_1)
      bank = Bank.add_covenant(bank, covenant_2)
      [bank: bank]
    end

    test "rejects MN", %{bank: bank} do
      assert ["33"] = LoanProcessor.reject_facility_ids_by_state(bank, "MN", [])
    end

    test "rejects nothing on non-existant state", %{bank: bank} do
      assert [] = LoanProcessor.reject_facility_ids_by_state(bank, "AA", [])
    end

    test "keeps existing rejections", %{bank: bank} do
      assert ["123", "999"] = LoanProcessor.reject_facility_ids_by_state(bank, "AA", ["123", "999"])
    end
  end

end
