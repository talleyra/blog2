using JuMP, GLPK

prices = [1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 0, -5, 0, 0, 5, 5] .* 100

#cd("./posts/optimisation")

prices_df = CSV.read("./data/austria_15_min_day_ahead_prices.csv", DataFrame)
prices_df = rename!(prices_df, [:date, :price])

prices = prices_df.price
variable_cost = 100
capacity = 10
startup_cost = 5000
shutdown_cost = 5000
min_tech = 5

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

ramping_up = 0.2
ramping_down = 0.2
start_up_ramping = 7
shutdown_ramping = 7

for i in 2:n
    # 0 if running; -1 if shutdown, 1 if swich on
    @constraint(model, running[i] - running[i - 1] == startup[i] - shutdown[i])
    @constraint(model, startup[i] + shutdown[i] <= 1)

    @constraint(model, p[i] - p[i - 1] <= (ramping_up * running[i - 1]) + (start_up_ramping * startup[i]))
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
println(value.(p))
println(value.(running))
println(value.(shutdown))
println(value.(startup))
objective_value(model)

plot(value.(p))

revenue = sum(value.(p).*(prices))
var_cost = sum(value.(p).*(variable_cost))
start_up_cost = sum(value.(startup)) * startup_cost
shut_down_cost = sum(value.(shutdown)) * shutdown_cost

revenue - var_cost - start_up_cost - shut_down_cost

objective_value(model)


sum(value.(shutdown))
sum(value.(startup))
sum(value.(running))

plot(value.(p))