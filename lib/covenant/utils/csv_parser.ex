defmodule Covenant.Utils.CSVParser do
  @moduledoc """
  Parses CSV Files
  """
  alias NimbleCSV.RFC4180, as: CSV

  def parse(file_path) do
    file_path
    |> File.stream!()
    |> CSV.parse_stream()
    |> Enum.map(& &1)
  end

  def dump_to_iodata(data) do
    data |> CSV.dump_to_iodata()
  end
end
