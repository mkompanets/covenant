defmodule Covenant.LoanProcessor do
  alias Covenant.Utils.CSVParser
  alias Covenant.{Bank, Loan}

  @file_path_base "#{File.cwd!()}/reference_data/large"

  @banks_file_path "#{@file_path_base}/banks.csv"
  @covenants_file_path "#{@file_path_base}/covenants.csv"
  @facilities_file_path "#{@file_path_base}/facilities.csv"
  @loans_file_path "#{@file_path_base}/loans.csv"

  def process_loans do
    # 1. Create loan structs
    loans = CSVParser.parse(@loans_file_path) |> Loan.parse_data()

    # 2. Load bank data to include facilities and covenants
    banks = load_bank_data()

    # 3. Create assignments data
    loans
    |> Enum.map(fn(loan) ->
      rejected_facility_ids = reject_facility_ids(banks, loan)
    end)

  end

  defp load_bank_data do
    facilities_data = CSVParser.parse(@facilities_file_path)
    covenants_data = CSVParser.parse(@covenants_file_path)
    banks = CSVParser.parse(@banks_file_path) |> Bank.parse_data()
    banks = Bank.load_facilities(banks, facilities_data)
    Bank.load_covenants(banks, covenants_data)
  end

  def reject_facility_ids(banks, loan) do
    banks
    |> Enum.map(fn(bank) ->
      facility_ids = reject_facility_ids_by_state(bank, loan.state, [])
    end)
  end

  def reject_facility_ids_by_state(bank, state, rejected_facility_ids) do
    facility_ids = bank.covenants
    |> Enum.filter(fn(covenant) ->
      covenant.banned_state == state
    end)
    |> Enum.map(&(&1.facility_id))

    rejected_facility_ids ++ facility_ids
  end
end
