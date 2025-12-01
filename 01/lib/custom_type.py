class Direction(str):
    def __new__(cls, value):
        if not isinstance(value, str):
            raise TypeError("Needs to be a string")
        if not (value.startswith("R") or value.startswith("L")):
            raise ValueError("Needs to start with R or L")

        numeric = value[1:]
        if not numeric.isdigit():
            raise ValueError("Must be followed by number, got: ", value)

        return super().__new__(cls, value)

    def get_direction(self):
        return self[0]

    def get_distance(self):
        return int(self[1:])
