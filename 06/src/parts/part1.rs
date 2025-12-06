use std::fs;

pub fn part1() -> Result<String, Box<dyn std::error::Error>> {
    let input = fs::read_to_string("input.txt")?;

    if input.trim().is_empty() {
        return Ok("0".to_string());
    }

    let mut lines: Vec<Vec<char>> = input.lines().map(|line| line.chars().collect()).collect();

    let maxlen = lines.iter().map(|r| r.len()).max().unwrap_or(0);
    for row in &mut lines {
        if row.len() < maxlen {
            row.extend(std::iter::repeat(' ').take(maxlen-row.len()));
        }
    }

    if lines.is_empty() {
        return Ok("0".to_string());
    }
    let bottom_idx = lines.len() -1;

    let mut is_sep = vec![false; maxlen];
    for c in 0..maxlen {
        is_sep[c] = lines.iter().all(|row| row[c] == ' ');
    }

    let mut problems_results: Vec<i128> = Vec::new();
    let mut c = 0;
    while c < maxlen {
        if is_sep[c] {
            c += 1;
            continue;
        }
        let start = c;
        while c < maxlen && !is_sep[c] {
            c += 1;
        }
        let end = c;


        let mut numbers: Vec<i128> = Vec::new();
        for r in 0..bottom_idx {
            let s: String = lines[r][start..end].iter().collect();
            let s_trim = s.trim();
            if !s_trim.is_empty() {
                let n: i128 = s_trim.parse()?;
                numbers.push(n);
            }
        }


        let op_slice: String = lines[bottom_idx][start..end].iter().collect();
        let operator = op_slice.chars().find(|&ch| ch == '+' || ch == '*')
            .ok_or("No ops")?;

        let result = match operator {
            '+' => numbers.into_iter().sum(),
            '*' => numbers.into_iter().product(),
            _ => unreachable!(),
        };
        problems_results.push(result);
    }

let grand_total: i128 = problems_results.into_iter().sum();
    return Ok(grand_total.to_string());

}
