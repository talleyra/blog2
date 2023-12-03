import julia
from julia import Main
import os
import pandas as pd

os.getcwd()
Main.include("./posts/optimisation/termalplant.jl")

prices = pd.read_csv("./posts/optimisation/data/aus15minprices.csv")
prices.columns = ['date', 'price']

capacity = 10
variable_cost = 130
startup_cost = 4000
shutdown_cost = 3000
min_tech      = 3
ramping_up = 0.3
ramping_down = 0.4
startup_ramping = 3.3
shutdown_ramping = 3.4

price_list = prices['price'].tolist()
opti = Main.thermalplant(
    price_list,
    capacity,
    variable_cost,
    startup_cost,
    shutdown_cost,
    min_tech,
    ramping_up,
    ramping_down,
    startup_ramping,
    shutdown_ramping
    )


prices['optimal'] = opti

from plotnine import ggplot, aes, geom_line
import pandas as pd

# Assuming you have a DataFrame named 'prices' with columns 'date', 'price', and 'program'

# Sample DataFrame creation (replace this with your DataFrame)
# Plotting with plotnine
(
    ggplot(prices)
    + aes(x='date', y='price')
    + geom_line(color='blue')  # Line for 'price'
    + aes(x = 'date', y='opti')
    + geom_line(color='red')  # Line for 'program'
)


