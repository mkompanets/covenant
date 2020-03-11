defmodule Covenant.Utils.CSVParserTest do
  use ExUnit.Case
  alias Covenant.Utils.CSVParser

  describe "parse/1" do
    test "returns a nested list of rows" do
      path = "#{File.cwd!()}/reference_data/small/banks.csv"
      assert [[_, _] | _] = CSVParser.parse(path)
    end
  end
end
