input = File.read!("input.txt")
|> String.split("\n", trim: true)

# Parse grid into list of lists
grid = Enum.map(input, &String.graphemes/1)

# Find start position (S)
{start_row, start_col} =
  grid
  |> Enum.with_index()
  |> Enum.find_value(fn {row, r} ->
    case Enum.find_index(row, &(&1 == "S")) do
      nil -> nil
      c -> {r, c}
    end
  end)

# Dimensions
rows = length(grid)
cols = length(List.first(grid))

# Track visited positions to avoid double-counting splits
visited = :maps.new()



# Beam simulation using a queue, tracking visited positions
defmodule BeamSim do
  def run(grid, rows, cols, start_row, start_col) do
    queue = [{start_row, start_col, :down}]
    split_count = 0
    visited = MapSet.new()
    process(queue, grid, rows, cols, split_count, visited)
  end

  defp process([], _grid, _rows, _cols, split_count, _visited), do: split_count
  defp process([{r, c, dir} | rest], grid, rows, cols, split_count, visited) do
    key = {r, c, dir}
    if r < 0 or r >= rows or c < 0 or c >= cols or MapSet.member?(visited, key) do
      process(rest, grid, rows, cols, split_count, visited)
    else
      visited = MapSet.put(visited, key)
      case grid |> Enum.at(r) |> Enum.at(c) do
        "^" ->
          # Count split event
          process([
            {r, c - 1, :down},
            {r, c + 1, :down} | rest
          ], grid, rows, cols, split_count + 1, visited)
        "S" ->
          process([{r + 1, c, :down} | rest], grid, rows, cols, split_count, visited)
        "." ->
          process([{r + 1, c, :down} | rest], grid, rows, cols, split_count, visited)
        _ ->
          process(rest, grid, rows, cols, split_count, visited)
      end
    end
  end
end

split_count = BeamSim.run(grid, rows, cols, start_row, start_col)
IO.puts(split_count)




defmodule QuantumManifold do
  def run(grid, rows, cols, start_row, start_col) do
    # Use memoization: for each position, calculate how many unique timelines pass through
    cache = %{}
    {count, _cache} = count_from_position(start_row, start_col, grid, rows, cols, cache, MapSet.new())
    count
  end

  defp count_from_position(r, c, grid, rows, cols, cache, visiting) do
    cond do
      r < 0 or r >= rows or c < 0 or c >= cols ->
        # Out of bounds - one unique endpoint
        {1, cache}

      MapSet.member?(visiting, {r, c}) ->
        # Cycle detected - don't count this path
        {0, cache}

      Map.has_key?(cache, {r, c}) ->
        # Already computed for this position
        {Map.get(cache, {r, c}), cache}

      true ->
        visiting = MapSet.put(visiting, {r, c})
        {result, new_cache} = case grid |> Enum.at(r) |> Enum.at(c) do
          "^" ->
            # Split: count timelines from both paths
            {left_count, cache1} = count_from_position(r + 1, c - 1, grid, rows, cols, cache, visiting)
            {right_count, cache2} = count_from_position(r + 1, c + 1, grid, rows, cols, cache1, visiting)
            {left_count + right_count, cache2}

          "S" ->
            count_from_position(r + 1, c, grid, rows, cols, cache, visiting)

          "." ->
            count_from_position(r + 1, c, grid, rows, cols, cache, visiting)

          _ ->
            # Unknown character - one endpoint
            {1, cache}
        end

        # Cache the result
        new_cache = Map.put(new_cache, {r, c}, result)
        {result, new_cache}
    end
  end
end

timelines = QuantumManifold.run(grid, rows, cols, start_row, start_col)
IO.puts(timelines)
