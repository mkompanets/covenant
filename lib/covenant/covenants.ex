defmodule Covenant.Covenants do
  defstruct [:facility_id, :max_default_likelihood, :bank_id, :banned_state]
  alias Covenant.Covenants

  def init([facility_id, max_default_likelihood, bank_id, banned_state]) do
    %Covenants{
      facility_id: facility_id,
      max_default_likelihood: max_default_likelihood,
      bank_id: bank_id,
      banned_state: banned_state
    }
  end

  def parse_data(rows_of_data) do
    rows_of_data |> Enum.map(&init/1)
  end
end
