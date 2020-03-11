defmodule Covenant.Utils do
  def to_float(nil), do: nil
  def to_float(""), do: nil

  def to_float(str) do
    case Float.parse(str) do
      :error -> raise "error parsing #{str} to float"
      {number, _other} -> number
    end
  end

  def to_integer(str) do
    {number, _other} = Integer.parse(str)
    number
  end
end
