# TODO: Write documentation for `Aoc`
module Aoc
  VERSION = "0.1.0"

  total = 0

  input = File.read("input.txt").split("\n")
  part1(input)
  part2(input)

end


def part1(input)
  total = 0
    input.each do |line|
    digits = line.strip.chars.map(&.to_i)
    max_pair = 0
    (0...digits.size).each do |i|
      (i+1...digits.size).each do |j| 
        value = digits[i] * 10 + digits[j]
        max_pair = value if value > max_pair
      end
    end

    total += max_pair
  end

  puts total
end

def part2(input)
  k = 12
  total = 0_i64
  input.each do |line|
    digits = line.strip.chars.map(&.to_i)
    keep = k
    drop = digits.size-keep
    stack = Array(Int32).new

    digits.each do |d|
      while drop > 0 && stack.size > 0 && stack.last < d
        stack.pop
        drop -= 1
      end
      stack << d
    end

    result = stack[0, keep]
    value = 0_i64
    result.each {|d| value = value * 10 + d }
    total += value
  end
    puts total
end
