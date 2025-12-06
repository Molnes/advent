mod parts;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let result1 = parts::part1::part1()?;
    println!("Part 1: {}", result1);
    let result2 = parts::part2::part2()?;
    println!("Part 2: {}", result2);
    Ok(())
}