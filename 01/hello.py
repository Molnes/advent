from lib.func import Rotates_through_zero
from lib.func import Do_rotation
from lib.custom_type import Direction


def main():
    current_position = 50
    times_zero = 0

    input = open("input.txt", "r").read().split("\n")

    for line in input:
        current_position = Do_rotation(Direction(line), current_position)
        if current_position == 0:
            times_zero += 1

    current_position = 50
    solution_2 = 0
    for line in input:
        current_position, crosses_zero = Rotates_through_zero(
            Direction(line), current_position
        )
        solution_2 += crosses_zero

    print(times_zero)
    print(solution_2)


if __name__ == "__main__":
    main()
