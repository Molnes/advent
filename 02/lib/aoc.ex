defmodule Aoc do
  use Application

  @moduledoc """
  Documentation for `Aoc`.
  """

  def start(_type, _args) do
    file = "input.txt"
    {:ok, input} = File.read(file)
    IO.puts("Part 1: #{part1(input)}")
    IO.puts("Part 2: #{part2(input)}")

    Task.start(fn ->
      :timer.sleep(1000)
      IO.puts("done sleeping")
    end)
  end

  def part1(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.flat_map(fn range_str ->
      [start_str, end_str] = String.split(range_str, "-")
      |> Enum.map(&String.to_integer/1)
      find_invalid_ids(start_str, end_str)
    end)
    |> Enum.sum()
  end

  defp find_invalid_ids(start_num, end_num) do
    Enum.map(start_num..end_num, fn num ->
      with s <- to_string(num),
           len <- String.length(s),
           true <- rem(len, 2) == 0,
           {left, right} <- String.split_at(s, div(len, 2)) do
        if left == right, do: num, else: 0
      else
        _ -> 0
      end
    end)
  end

  def part2(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.flat_map(fn range_str ->
      [start_str, end_str] = String.split(range_str, "-")
      start_num = String.to_integer(start_str)
      end_num = String.to_integer(end_str)

      invalids(start_num, end_num)
    end)
    |> Enum.sum()
  end

  defp invalids(start_num, end_num) do
    Enum.map(start_num..end_num, fn num ->
      if repeated?(num), do: num, else: 0
    end)
  end

  defp repeated?(num) do
    s = to_string(num)
    Regex.match?(~r/^(.+)\1+$/, s)
  end
end
