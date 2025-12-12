defmodule Factory do
  import Bitwise
  
  def solve(filename) do
    filename
    |> File.read!()
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_machine/1)
    |> Enum.map(&min_presses/1)
    |> Enum.sum()
  end

  def parse_machine(line) do
    [diagram_part, rest] = String.split(line, "] ", parts: 2)
    diagram = String.slice(diagram_part, 1..-1//1)
    
    buttons_part = String.slice(rest, 0..(String.length(rest) - String.length("}") - 2)//1)
    
    buttons =
      Regex.scan(~r/\(([^)]*)\)/, buttons_part)
      |> Enum.map(fn [_, content] ->
        content
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.map(&String.to_integer/1)
      end)
    
    target_state =
      diagram
      |> String.split("")
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&(&1 == "#"))
    
    {target_state, buttons}
  end

  def min_presses({target_state, buttons}) do
    num_lights = length(target_state)
    num_buttons = length(buttons)
    
    # Build matrix: each row is a light, each column is a button + augmented column for target
    matrix =
      for light_idx <- 0..(num_lights - 1) do
        row =
          for button_idx <- 0..(num_buttons - 1) do
            if Enum.at(buttons, button_idx) |> Enum.member?(light_idx), do: 1, else: 0
          end
        
        target = if Enum.at(target_state, light_idx), do: 1, else: 0
        row ++ [target]
      end
    
    # Solve the system of linear equations over GF(2)
    case solve_gf2(matrix, num_buttons) do
      {:ok, solution} -> Enum.sum(solution)
      :impossible -> 0
    end
  end

  def solve_gf2(matrix, num_buttons) do
    # Gaussian elimination with partial pivoting
    {rref, pivots} = gaussian_elimination(matrix, num_buttons)
    
    # Check for inconsistency
    if has_inconsistency(rref, num_buttons) do
      :impossible
    else
      # Extract minimal solution
      solution = extract_solution(rref, num_buttons, pivots)
      {:ok, solution}
    end
  end

  def gaussian_elimination(matrix, num_buttons) do
    {mat, pivots} =
      Enum.reduce(0..(num_buttons - 1), {matrix, []}, fn col, {current_mat, current_pivots} ->
        current_pivot_row = length(current_pivots)
        
        # Find a row with 1 in this column (starting from current pivot row)
        pivot_row_idx =
          current_mat
          |> Enum.with_index()
          |> Enum.find(fn {row, idx} ->
            idx >= current_pivot_row and Enum.at(row, col) == 1
          end)
          |> then(fn result ->
            case result do
              {_row, idx} -> idx
              nil -> nil
            end
          end)
        
        if pivot_row_idx == nil do
          {current_mat, current_pivots}
        else
          # Swap to pivot position
          current_mat = swap_rows(current_mat, current_pivot_row, pivot_row_idx)
          
          # Eliminate all other rows
          current_mat =
            Enum.with_index(current_mat)
            |> Enum.map(fn {row, i} ->
              if i != current_pivot_row and Enum.at(row, col) == 1 do
                pivot_row = Enum.at(current_mat, current_pivot_row)
                xor_rows(pivot_row, row)
              else
                row
              end
            end)
          
          {current_mat, current_pivots ++ [col]}
        end
      end)
    
    {mat, pivots}
  end

  def has_inconsistency(rref, num_buttons) do
    Enum.any?(rref, fn row ->
      # All variable columns are 0 but augmented column is 1
      variables = Enum.take(row, num_buttons)
      augmented = Enum.at(row, num_buttons)
      
      Enum.all?(variables, &(&1 == 0)) and augmented == 1
    end)
  end

  def extract_solution(rref, num_buttons, pivots) do
    # Find free variables (those not in pivots)
    free_vars = Enum.filter(0..(num_buttons - 1), fn i -> not Enum.member?(pivots, i) end)
    
    # Try all combinations of free variables and find minimum
    num_free = length(free_vars)
    best = Enum.reduce(0..(2 ** num_free - 1), {999_999_999, []}, fn combo, {min_so_far, best_sol} ->
      solution = List.duplicate(0, num_buttons)
      
      # Set free variables according to combo bits
      solution =
        Enum.reduce(Enum.with_index(free_vars), solution, fn {free_var, free_idx}, sol ->
          bit = (combo >>> free_idx) &&& 1
          List.replace_at(sol, free_var, bit)
        end)
      
      # Back-substitute for pivot variables
      solution =
        Enum.reduce(Enum.with_index(pivots) |> Enum.reverse(), solution, fn {pivot_col, pivot_row_idx}, sol ->
          row = Enum.at(rref, pivot_row_idx)
          
          dependent_sum =
            Enum.with_index(row)
            |> Enum.filter(fn {_, i} ->
              i > pivot_col and i < num_buttons
            end)
            |> Enum.map(fn {bit, i} ->
              if bit == 1, do: Enum.at(sol, i, 0), else: 0
            end)
            |> Enum.sum()
            |> rem(2)
          
          target = Enum.at(row, num_buttons)
          value = (target - dependent_sum) |> rem(2) |> abs()
          
          List.replace_at(sol, pivot_col, value)
        end)
      
      presses = Enum.sum(solution)
      if presses < min_so_far do
        {presses, solution}
      else
        {min_so_far, best_sol}
      end
    end)
    
    elem(best, 1)
  end

  def swap_rows(matrix, i, j) when i == j, do: matrix

  def swap_rows(matrix, i, j) do
    row_i = Enum.at(matrix, i)
    row_j = Enum.at(matrix, j)
    matrix |> List.replace_at(i, row_j) |> List.replace_at(j, row_i)
  end

  def xor_rows(row1, row2) when is_list(row1) and is_list(row2) do
    Enum.zip(row1, row2) |> Enum.map(fn {a, b} -> (a + b) |> rem(2) end)
  end
end

# Run the solution
IO.puts(Factory.solve("input.txt"))
