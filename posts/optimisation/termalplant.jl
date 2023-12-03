using JuMP, GLPK

function thermalplant(prices, capacity, variable_cost, startup_cost, shutdown_cost, min_tech, ramping_up, ramping_down, startup_ramping, shutdown_ramping)
    n = length(prices)

    model = Model(GLPK.Optimizer)

    @variable(model, running[1:n], Bin)
    @variable(model, p[1:n] >= 0)

    # seems to work
    for i in 1:n
        @constraint(model, p[i] <= capacity * running[i]) 
        @constraint(model, p[i] >= min_tech * running[i])
    end

    @variable(model, startup[1:n], Bin)
    @variable(model, shutdown[1:n], Bin)



    for i in 2:n
        # 0 if running; -1 if shutdown, 1 if swich on
        @constraint(model, running[i] - running[i - 1] == startup[i] - shutdown[i])
        @constraint(model, startup[i] + shutdown[i] <= 1)

        @constraint(model, p[i] - p[i - 1] <= (ramping_up * running[i - 1]) + (startup_ramping * startup[i]))
        @constraint(model, p[i - 1] - p[i] <= (ramping_down * running[i - 1]) + (shutdown_ramping * shutdown[i]))

    end

    @objective(
        model, Max,
        sum(
            (prices[i] * p[i]) - (variable_cost * p[i]) - (startup_cost * startup[i]) - (shutdown_cost * shutdown[i])
            for i in 1:n
        )
    )

    optimize!(model)

    return value.(p)

end


#prices_df = CSV.read("./data/austria_15_min_day_ahead_prices.csv", DataFrame)
#prices_df = rename!(prices_df, [:date, :price])
#data = thermalplant(prices_df.price, 100, 10000, 10000, 1, 0.2, 0.5, 6, 4)
#using Plots
#plot(data)