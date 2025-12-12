defmodule Solution do
  defmodule UnionFind do
    def new(elements) do
      Enum.reduce(elements, %{}, fn element, acc ->
        Map.put(acc, element, element)
      end)
    end

    def find(parent_map, element) do
      if parent_map[element] == element do
        {element, parent_map}
      else
        {root, new_map} = find(parent_map, parent_map[element])
        {root, Map.put(new_map, element, root)}
      end
    end

    def union(parent_map, element1, element2) do
      {root1, map1} = find(parent_map, element1)
      {root2, map2} = find(map1, element2)

      if root1 != root2 do
        Map.put(map2, root1, root2)
      else
        map2
      end
    end
  end

  def dist([ax, ay, az], [bx, by, bz]) do
    (ax - bx) * (ax - bx) + (ay - by) * (ay - by) + (az - bz) * (az - bz)
  end

  def solve(coords) do
    n = length(coords)
    coords_indexed = Enum.with_index(coords)

    # Generate all distances
    dists =
      for {coord_i, i} <- coords_indexed,
          {coord_j, j} <- coords_indexed,
          i < j do
        {dist(coord_i, coord_j), i, j}
      end
      |> Enum.sort()

    # Part 1: After 1000 connections
    uf1 = UnionFind.new(0..(n-1))
    check = 1000

    final_uf1 =
      Enum.take(dists, min(check, length(dists)))
      |> Enum.reduce(uf1, fn {_dist, i, j}, uf ->
        UnionFind.union(uf, i, j)
      end)

    # Count circuit sizes
    {parents, _} =
      Enum.reduce(0..(n-1), {%{}, final_uf1}, fn i, {acc, uf} ->
        {root, new_uf} = UnionFind.find(uf, i)
        {Map.update(acc, root, 1, &(&1 + 1)), new_uf}
      end)

    sizes = Map.values(parents) |> Enum.sort(:desc)
    [s1, s2, s3 | _] = sizes ++ [1, 1, 1]  # Pad with 1s if not enough sizes
    part1 = s1 * s2 * s3

    # Part 2: Find when all connected
    {part2, _} =
      Enum.reduce_while(dists, {nil, UnionFind.new(0..(n-1))}, fn {_dist, i, j}, {_result, uf} ->
        new_uf = UnionFind.union(uf, i, j)

        # Check if all connected to 0
        all_connected =
          Enum.all?(0..(n-1), fn idx ->
            {root_idx, _} = UnionFind.find(new_uf, idx)
            {root_0, _} = UnionFind.find(new_uf, 0)
            root_idx == root_0
          end)

        if all_connected do
          coord_i = Enum.at(coords, i)
          coord_j = Enum.at(coords, j)
          {:halt, {Enum.at(coord_i, 0) * Enum.at(coord_j, 0), new_uf}}
        else
          {:cont, {nil, new_uf}}
        end
      end)

    {part1, part2}
  end
end

# Parse input
coords =
  File.read!("input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    String.split(line, ",") |> Enum.map(&String.to_integer/1)
  end)

{part1, part2} = Solution.solve(coords)
IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
