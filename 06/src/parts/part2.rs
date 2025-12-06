use std::fs;

pub fn part2() -> Result<String, Box<dyn std::error::Error>> {
    let input = fs::read_to_string("input.txt")?;

    if input.trim().is_empty() {
        return Ok("0".to_string());
    }

    let lines: Vec<Vec<char>> = input.lines().map(|line| line.chars().collect()).collect();

    let maxlen = lines.iter().map(|r| r.len()).max().unwrap_or(0);
    let maxheight = lines.len();

    if lines.is_empty() || maxlen == 0 {
        return Ok("0".to_string());
    }

    let mut is_sep = vec![false; maxlen];
    for c in 0..maxlen {
        is_sep[c] = lines.iter().all(|row| {
            if c < row.len() {
                row[c] == ' '
            } else {
                true
            }
        });
    }

    let mut problems_results: Vec<i128> = Vec::new();
    
    let mut c = maxlen;
    while c > 0 {
        c -= 1;
        
        if is_sep[c] {
            continue;
        }
        
        let end = c + 1;
        while c > 0 && !is_sep[c - 1] {
            c -= 1;
        }
        let start = c;
        
        let operator = lines[maxheight - 1]
            .get(start..end)
            .and_then(|slice| slice.iter().find(|&&ch| ch == '+' || ch == '*').copied())
            .ok_or("No operator found")?;
        
        let mut numbers: Vec<i128> = Vec::new();
        
        for col_idx in (start..end).rev() {
            let mut number_str = String::new();
            
            for row in 0..maxheight - 1 {
                if col_idx < lines[row].len() {
                    let ch = lines[row][col_idx];
                    if ch.is_ascii_digit() {
                        number_str.push(ch);
                    }
                }
            }
            
            if !number_str.is_empty() {
                let num: i128 = number_str.parse()?;
                numbers.push(num);
            }
        }
        
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
