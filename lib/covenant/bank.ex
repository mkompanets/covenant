defmodule Covenant.Bank do
  defstruct [:id, :name]
  alias Covenant.Bank

  def parse_data(rows_of_data) do
    rows_of_data
    |> Enum.map(fn([id, name]) ->
      %Bank{
        id: id,
        name: name
      }
    end)
  end
end
