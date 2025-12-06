let parse_range line =
  match String.split_on_char '-' line with
  | [a; b] -> (int_of_string a, int_of_string b)
  | _ -> failwith ("broke range: " ^ line)

let is_fresh ranges value =
  List.exists (fun (lo, hi) -> value >= lo && value <= hi) ranges

let merge_ranges ranges =
  let sorted = List.sort (fun (a, _) (b, _) -> compare a b) ranges in
  match sorted with
  | [] -> []
  | first :: rest ->
    let rec merge acc current = function
      | [] -> List.rev (current :: acc)
      | (lo, hi) :: rest ->
        let (cur_lo, cur_hi) = current in
        if lo <= cur_hi + 1 then
          merge acc (cur_lo, max cur_hi hi) rest
        else
          merge (current :: acc) (lo, hi) rest
    in
    merge [] first rest

let count_fresh_ids ranges =
  let merged = merge_ranges ranges in
  List.fold_left (fun acc (lo, hi) -> acc + (hi - lo + 1)) 0 merged

let () =
  let ic = open_in "input.txt" in
  let rec read_lines acc =
    try
      let line = input_line ic in
      read_lines (line :: acc)
    with End_of_file ->
      close_in ic;
      List.rev acc
  in
  let lines = read_lines [] in
  
  let rec split_at_blank before = function
    | [] -> (List.rev before, [])
    | "" :: rest -> (List.rev before, rest)
    | line :: rest -> split_at_blank (line :: before) rest
  in
  let (range_lines, ingredient_lines) = split_at_blank [] lines in
  
  let ranges = List.map parse_range range_lines in
  
  let ingredients = List.filter_map (fun s ->
    let s = String.trim s in
    if s = "" then None else Some (int_of_string s)
  ) ingredient_lines in
  let fresh_count = List.length (List.filter (is_fresh ranges) ingredients) in
  Printf.printf "Part 1: %d\n" fresh_count;
  
  let total_fresh = count_fresh_ids ranges in
  Printf.printf "Part 2: %d\n" total_fresh