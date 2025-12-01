from lib.custom_type import Direction


def Do_rotation(input_line: Direction, current_pos):
    direction = input_line.get_direction()
    dist = input_line.get_distance()

    if direction == "R":
        current_pos = (current_pos + dist) % 100
    else:
        current_pos = (current_pos - dist) % 100

    return current_pos


def Rotates_through_zero(input_line: Direction, current_pos: int) -> tuple[int, int]:
    direction = input_line.get_direction()
    dist = input_line.get_distance()

    if direction == "R":
        new_pos = (current_pos + dist) % 100
        if current_pos == 0:
            crosses = dist // 100
        else:
            first_zero_dist = 100 - current_pos
            if dist >= first_zero_dist:
                crosses = 1 + (dist - first_zero_dist) // 100
            else:
                crosses = 0
    else:
        new_pos = (current_pos - dist) % 100
        if current_pos == 0:
            crosses = dist // 100
        else:
            if dist >= current_pos:
                crosses = 1 + (dist - current_pos) // 100
            else:
                crosses = 0

    return new_pos, crosses
