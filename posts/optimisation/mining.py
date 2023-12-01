import keyring as k
import entsoe as elec
import pandas as pd

entsoe = k.get_password("entsoe", username = None)

start = pd.Timestamp("2023-11-01", tz='Europe/Brussels')
end = pd.Timestamp("2023-12-01", tz='Europe/Brussels')

client = elec.EntsoePandasClient(api_key=entsoe)

prices = client.query_day_ahead_prices(
    country_code=elec.Area.AT.value, start=start, end = end,
    resolution="15T"
)

prices.to_csv("austria_15_min_day_ahead_prices.csv")