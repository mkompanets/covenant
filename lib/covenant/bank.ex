defmodule Covenant.Bank do
  defstruct [:id, :name, facilities: [], covenants: []]
  alias Covenant.{Bank, Covenants, Facility}

  def init([id, name]) do
    %Bank{
      id: id,
      name: name
    }
  end

  def parse_data(rows_of_data) do
    rows_of_data |> Enum.map(&init/1)
  end

  def load_facilities(banks, facilities_data) do
    facilities_data_by_bank = facilities_data |> Enum.group_by(&Enum.at(&1, 3))

    banks
    |> Enum.map(fn bank ->
      Map.get(facilities_data_by_bank, bank.id)
      |> Enum.map(&Facility.init/1)
      |> Enum.reduce(bank, fn facility, bank ->
        add_facility(bank, facility)
      end)
    end)
  end

  def add_facility(bank, facility) do
    %Bank{bank | facilities: [facility | bank.facilities]}
  end

  def load_covenants(banks, covenants_data) do
    covenants_data_by_bank = covenants_data |> Enum.group_by(&Enum.at(&1, 2))

    banks
    |> Enum.map(fn bank ->
      Map.get(covenants_data_by_bank, bank.id)
      |> Enum.map(&Covenants.init/1)
      |> Enum.reduce(bank, fn covenant, bank ->
        add_covenant(bank, covenant)
      end)
    end)
  end

  def add_covenant(bank, covenant) do
    %Bank{bank | covenants: [covenant | bank.covenants]}
  end
end
