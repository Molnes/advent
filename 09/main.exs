points =
  "input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    [x, y] = String.split(line, ",") |> Enum.map(&String.to_integer/1)
    {x, y}
  end)

candidates =
  points
  |> Enum.with_index()
  |> Enum.flat_map(fn {p1, idx} ->
    points
    |> Enum.drop(idx + 1)
    |> Enum.map(fn p2 ->
      {{x1, y1}, {x2, y2}} = {p1, p2}
      area = (abs(x1 - x2) + 1) * (abs(y1 - y2) + 1)
      {area, p1, p2}
    end)
  end)

part1 =
  candidates
  |> Enum.map(fn {area, _, _} -> area end)
  |> Enum.max()

IO.puts("Part 1: #{part1}")

edges =
  points
  |> Enum.concat([hd(points)])
  |> Enum.chunk_every(2, 1, :discard)

on_boundary? = fn {px, py} ->
  Enum.any?(edges, fn [{x1, y1}, {x2, y2}] ->
    cond do
      y1 == y2 -> py == y1 and px >= min(x1, x2) and px <= max(x1, x2)
      x1 == x2 -> px == x1 and py >= min(y1, y2) and py <= max(y1, y2)
      true -> raise "Non-orthogonal segment"
    end
  end)
end

point_inside? = fn {px, py} ->
  Enum.reduce(edges, false, fn [{x1, y1}, {x2, y2}], inside ->
    cond do
      y1 == y2 -> inside
      true ->
        {ax, ay, bx, by} = if y1 < y2, do: {x1, y1, x2, y2}, else: {x2, y2, x1, y1}
        crosses = ay <= py and py < by and px < (bx - ax) * (py - ay) / (by - ay) + ax
        if crosses, do: not inside, else: inside
    end
  end)
end

inside_or_boundary? = fn p -> point_inside?.(p) or on_boundary?.(p) end

intersects_boundary? = fn x1, y1, x2, y2 ->
  Enum.any?(edges, fn [{ax, ay}, {bx, by}] ->
    cond do
      ay == by ->
        ay > y1 and ay < y2 and max(min(ax, bx), x1) < min(max(ax, bx), x2)
      ax == bx ->
        ax > x1 and ax < x2 and max(min(ay, by), y1) < min(max(ay, by), y2)
      true -> raise "Non-orthogonal segment"
    end
  end)
end

part2 =
  candidates
  |> Enum.sort_by(fn {area, _, _} -> -area end)
  |> Enum.reduce_while(0, fn {area, {x1, y1}, {x2, y2}}, _ ->
    x_low = min(x1, x2)
    x_high = max(x1, x2)
    y_low = min(y1, y2)
    y_high = max(y1, y2)

    crosses = intersects_boundary?.(x_low, y_low, x_high, y_high)
    center = {(x_low + x_high) / 2, (y_low + y_high) / 2}
    inside = inside_or_boundary?.(center)

    if not crosses and inside, do: {:halt, area}, else: {:cont, 0}
  end)

IO.puts(part2)
