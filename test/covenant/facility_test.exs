defmodule Covenant.FacilityTest do
  use ExUnit.Case
  alias Covenant.Facility
  alias Covenant.Utils.CSVParser

  describe "parse_data/1" do
    setup do
      path = "#{File.cwd!()}/reference_data/small/facilities.csv"
      [data: CSVParser.parse(path)]
    end

    test "returns a list of facilities", %{data: facilities_data} do
      facilities = Facility.parse_data(facilities_data)
      assert [%Facility{} | _] = facilities
    end
  end
end
