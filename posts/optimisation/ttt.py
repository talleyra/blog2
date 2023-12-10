
import julia
from julia import Main
import os
import pandas as pd

os.getcwd()
Main.include("./posts/optimisation/termalplant.jl")

prices = pd.read_csv("./posts/optimisation/data/aus15minprices.csv")
prices.columns = ['date', 'price']


capacity = 10
variable_cost = 90
startup_cost = 4000
shutdown_cost = 3000
min_tech      = 3
ramping_up = 0.3
ramping_down = 0.4
startup_ramping = 3.3
shutdown_ramping = 3.4

price_list = prices['price'].tolist()

simul1 = Main.thermalplant(
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

prices["simul1"] = simul1

# lets keep all as it was and just alter the min tech downwards to 2 MW

simul2 = Main.thermalplant(
    price_list,
    10, #capacity
    90, #variable_cost
    4000, #startup_cost
    3000, #shutdown_cost
    2, #min_tech
    0.3, #ramping_up
    0.4, #ramping_down
    3.3, #startup_ramping 
    3.4, #shutdown_ramping
    )

prices["simul2"] = simul2

# lets have much higher ramping

simul3 = Main.thermalplant(
    price_list,
    10, #capacity
    90, #variable_cost
    4000, #startup_cost
    3000, #shutdown_cost
    3, #min_tech
    2, #ramping_up
    2, #ramping_down
    3.3, #startup_ramping 
    3.4, #shutdown_ramping
    )

prices["simul3"] = simul3

prices.to_csv("./posts/optimisation/data/simuls.csv")