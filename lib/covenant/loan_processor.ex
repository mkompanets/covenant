defmodule Covenant.LoanProcessor do
  alias Covenant.Utils.CSVParser
  alias Covenant.{Bank, Loan, Facility}

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

    # 3. Create assignment and yield data by reducing loans. Each loop will update banks
    {_banks, assignments} =
      loans
      |> Enum.reduce({banks, []}, fn loan, dataset ->
        {banks, assignments} = dataset
        rejected_facility_ids = reject_facility_ids(banks, loan)

        {banks, assigned_facility_id, yield} =
          assign_facility_and_calculate_yield(banks, loan, rejected_facility_ids)

        assignments = assignments ++ [{loan.id, assigned_facility_id, yield}]
        {banks, assignments}
      end)

    assignments_data =
      assignments
      |> Enum.map(fn {loan_id, facility_id, _yield} -> [loan_id, facility_id] end)
      |> Enum.uniq()

    # Generate assignments csv
    assignments_data =
      [["loan_id", "facility_id"] | assignments_data] |> CSVParser.dump_to_iodata()

    File.write("#{@file_path_base}/assignments.csv", assignments_data)

    # Generate yields
    yields_data =
      assignments
      |> Enum.map(fn {_loan_id, facility_id, yield} -> [facility_id, yield] end)
      |> Enum.reject(fn([facility_id, _yield]) -> is_nil(facility_id) end)
      |> Enum.reduce(%{}, fn([facility_id, yield], accumulator) ->
        updated_yield = Map.get(accumulator, facility_id, 0.0) + yield
        Map.put(accumulator, facility_id, updated_yield)
      end)
      |> Enum.map(fn({facility_id, yield}) ->
        [facility_id, Kernel.round(yield)]
      end)

    yields_data = [["facility_id", "yield"] | yields_data] |> CSVParser.dump_to_iodata()
    File.write("#{@file_path_base}/yields.csv", yields_data)
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
    |> Enum.flat_map(fn bank ->
      facility_ids = reject_facility_ids_by_state(bank, loan.state, [])

      facility_ids =
        reject_facility_ids_by_default_concerns(bank, loan.default_likelihood, facility_ids)

      reject_facility_ids_by_ammount(bank, loan.amount, facility_ids)
    end)
  end

  def reject_facility_ids_by_state(bank, state, rejected_facility_ids) do
    facility_ids =
      bank.covenants
      |> Enum.filter(fn covenant ->
        covenant.banned_state == state && !is_nil(covenant.facility_id)
      end)
      |> Enum.map(& &1.facility_id)

    # collect states that match loan state and do not have a facility id
    rejection_states =
      bank.covenants
      |> Enum.filter(fn covenant ->
        is_nil(covenant.facility_id) || covenant.facility_id == ""
      end)
      |> Enum.map(& &1.banned_state)

    # ban all facilities from state if facility_id in covenant is empty
    facility_ids =
      if Enum.member?(rejection_states, state) do
        bank.facilities |> Enum.map(& &1.id)
      else
        facility_ids
      end

    rejected_facility_ids ++ facility_ids
  end

  def reject_facility_ids_by_default_concerns(bank, default_likelihood, rejected_facility_ids) do
    facility_ids =
      bank.covenants
      |> Enum.filter(fn covenant ->
        !is_nil(covenant.max_default_likelihood) &&
          default_likelihood > covenant.max_default_likelihood && !is_nil(covenant.facility_id)
      end)
      |> Enum.map(& &1.facility_id)

    # reject all facilities if conditions match and no facility id is provided in covenant
    covenant =
      bank.covenants
      |> Enum.find(fn covenant ->
        is_nil(covenant.facility_id) || covenant.facility_id == ""
      end)

    # check for max default in covenant but only if no facilities matched so far
    facility_ids =
      if !is_nil(covenant) && facility_ids == [] && !is_nil(covenant.max_default_likelihood) &&
           default_likelihood > covenant.max_default_likelihood do
        bank.facilities |> Enum.map(& &1.id)
      else
        facility_ids
      end

    rejected_facility_ids ++ facility_ids
  end

  def reject_facility_ids_by_ammount(bank, amount, rejected_facility_ids) do
    facility_ids =
      bank.facilities
      |> Enum.filter(fn facility ->
        amount > facility.amount
      end)
      |> Enum.map(& &1.id)

    rejected_facility_ids ++ facility_ids
  end

  def assign_facility_and_calculate_yield(banks, loan, rejected_facility_ids) do
    sorted_facilities =
      banks
      |> Enum.flat_map(fn bank -> bank.facilities end)
      |> Enum.sort(&(&1.interest_rate <= &2.interest_rate))

    facility =
      sorted_facilities
      |> Enum.reject(fn facility -> Enum.member?(rejected_facility_ids, facility.id) end)
      |> List.first()

    case facility do
      nil ->
        {banks, nil, 0.0}

      facility ->
        remaining_amount = facility.amount - loan.amount
        facility = %Facility{facility | amount: remaining_amount}
        bank_index = banks |> Enum.find_index(fn bank -> bank.id == facility.bank_id end)
        bank = Enum.at(banks, bank_index)

        facility_index = bank.facilities |> Enum.find_index(fn f -> facility.id == f.id end)
        facilities = List.replace_at(bank.facilities, facility_index, facility)

        bank = %Bank{bank | facilities: facilities}

        banks = List.replace_at(banks, bank_index, bank)

        yield = calculate_yield(facility, loan)

        {banks, facility.id, yield}
    end
  end

  defp calculate_yield(facility, loan) do
    (1 - loan.default_likelihood) * (loan.interest_rate * loan.amount) -
      loan.default_likelihood * loan.amount - facility.interest_rate * loan.amount
  end
end
