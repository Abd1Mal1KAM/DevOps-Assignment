# streamlit_app.py

"""_summary_"""

# %% ---------------------------------------------------------------------------
# Imports
# ------------------------------------------------------------------------------

from datetime import datetime

import streamlit as st

from constants import LENGTH_UNITS, WEIGHT_UNITS
from functions import convert_linear, convert_temperature

# %% ---------------------------------------------------------------------------
# CONFIG
# ------------------------------------------------------------------------------

st.set_page_config(page_title="Quick Convert", page_icon="🔁", layout="centered")

if "history" not in st.session_state:  # Session state for conversion history
    st.session_state.history = []

# %% ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------

st.title("🔁 Quick Convert")
st.caption("A small unit conversion tool — built with Streamlit.")

category = st.selectbox("Category", ["Length", "Weight", "Temperature"])

col1, col2 = st.columns(2)

if category == "Length":
    unit_options = list(LENGTH_UNITS.keys())
elif category == "Weight":
    unit_options = list(WEIGHT_UNITS.keys())
else:
    unit_options = ["Celsius (°C)", "Fahrenheit (°F)", "Kelvin (K)"]

with col1:
    from_unit = st.selectbox("From", unit_options, index=0)
with col2:
    default_to_index = 1 if len(unit_options) > 1 else 0
    to_unit = st.selectbox("To", unit_options, index=default_to_index)

value = st.number_input("Value", value=1.0, step=1.0, format="%.4f")

if st.button("Convert", type="primary", use_container_width=True):
    if category == "Length":
        result = convert_linear(value, from_unit, to_unit, LENGTH_UNITS)
    elif category == "Weight":
        result = convert_linear(value, from_unit, to_unit, WEIGHT_UNITS)
    else:
        result = convert_temperature(value, from_unit, to_unit)

    st.success(f"**{value:g} {from_unit}** = **{result:,.2f} {to_unit}**")

    st.session_state.history.insert(
        0,
        {
            "time": datetime.now().strftime("%H:%M:%S"),
            "category": category,
            "input": f"{value:g} {from_unit}",
            "output": f"{result:,.4f} {to_unit}",
        },
    )

## History panel

st.divider()
st.subheader("Conversion history")

if st.session_state.history:
    st.table(st.session_state.history[:10])
    if st.button("Clear history"):
        st.session_state.history = []
        st.rerun()
else:
    st.info("No conversions yet — try one above.")

st.divider()
st.caption("Deployed as part of a CI/CD pipeline demonstration.")
