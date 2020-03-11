defmodule Covenant.CovenantsTest do
  use ExUnit.Case
  alias Covenant.Utils.CSVParser
  alias Covenant.Covenants

  describe "parse_data/1" do
    setup do
      path = "#{File.cwd!()}/reference_data/small/covenants.csv"
      [data: CSVParser.parse(path)]
    end

    test "returns a list of covenants", %{data: covenants_data} do
      covenants = Covenants.parse_data(covenants_data)
      assert [%Covenants{} | _] = covenants
    end
  end
end
