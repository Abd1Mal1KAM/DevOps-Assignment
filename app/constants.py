# constants.py

"""__summary__
"""

# %% ---------------------------------------------------------------------------
# Conversion logic
# ------------------------------------------------------------------------------

## Each category (other than temperature) is defined as:
    # A set of units
    # A factor that converts 1 unit of that type into a common base unit.

LENGTH_UNITS = {
    "Metres (m)": 1.0,
    "Kilometres (km)": 1000.0,
    "Miles (mi)": 1609.344,
    "Feet (ft)": 0.3048,
    "Inches (in)": 0.0254,
}

WEIGHT_UNITS = {
    "Kilograms (kg)": 1.0,
    "Grams (g)": 0.001,
    "Pounds (lb)": 0.453592,
    "Ounces (oz)": 0.0283495,
}
