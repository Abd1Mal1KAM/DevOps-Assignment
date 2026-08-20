# functions.py

"""_summary_
"""

# %% ---------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

def convert_linear(value: float, from_unit: str, to_unit: str, units: dict) -> float:
    """Convert a value between two units that share a common linear base unit.

    Args:
        value (float): _description_
        from_unit (str): _description_
        to_unit (str): _description_
        units (dict): _description_

    Returns:
        float: _description_
    """

    base_value = value * units[from_unit]
    return base_value / units[to_unit]


def convert_temperature(value: float, from_unit: str, to_unit: str) -> float:
    """_summary_

    Args:
        value (float): _description_
        from_unit (str): _description_
        to_unit (str): _description_

    Returns:
        float: _description_
    """

    # Normalise to Celsius first
    if from_unit == "Celsius (°C)":
        celsius = value
    elif from_unit == "Fahrenheit (°F)":
        celsius = (value - 32) * 5 / 9
    else:  # Kelvin
        celsius = value - 273.15

    if to_unit == "Celsius (°C)":
        return celsius

    if to_unit == "Fahrenheit (°F)":
        return celsius * 9 / 5 + 32

    return celsius + 273.15 # Kelvin
