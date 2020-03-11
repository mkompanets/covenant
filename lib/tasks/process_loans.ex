defmodule Mix.Tasks.ProcessLoans do
  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Covenant.LoanProcessor.process_loans()
  end
end
