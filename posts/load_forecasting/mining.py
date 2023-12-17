import keyring as k
import entsoe as elec
import pandas as pd

entsoe = k.get_password("entsoe", username = None)

start = pd.Timestamp("2022-01-01", tz='Europe/Brussels')
end = pd.Timestamp("2023-12-31", tz='Europe/Brussels')

client = elec.EntsoePandasClient(api_key=entsoe)

load_at = client.query_load(
    country_code=elec.Area.AT.value, start=start, end = end
)

load_at.to_csv("at_load.csv")



load_it = client.query_load(
    country_code=elec.Area.IT_NORD, start=start, end = end
)

load_it.to_csv("it_load.csv")
