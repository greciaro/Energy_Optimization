
####################################
######### Initialize tools #########
####################################


# Initialize JuMP to allow mathematical programming models
using JuMP

# Initialize MILP solver Clp
using Clp


###############################
######### Define Sets #########
###############################

# Set of countries
COUNTRIES = ["Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Ecuador","Peru","Trinidad&Tobago","Uruguay","Venezuela"]
nCOUNTRIES = length(COUNTRIES)


###################################################
############ Define parameters and data ###########
###################################################

# Natural Gas production per country [x10^9 m^3]
PreProduction = [56.97, 20.41, 16.61, 1.87, 8.93, 0.45, 7.74, 25.13, 0.00, 56.49] # this is for year 2025


# Natural Gas consumption per country [x10^9 m^3]]
Consumption = [69.70, 3.90, 25.78, 4.57, 14.04, 0.45, 4.79, 39.58, 0.06, 27.85]  # this is for year 2025

# Distances between South American capitol cities. Indexed n for columns, m for rows.
Distance =  [0 1891.6 2486.1 1111.2 4643.6 4219.2 3116.4 3129.0 230.4 5084.6;
			  1891.6 0 1489.6 1598.4 1197.8 1175.8 775.5  1505.6 1775.7 1466.6;
			  2486.1 1489.6 0 3249.5 3995.9 4180.5 3541.3 2403.3 2378.3 3862.9;
			  1111.2 1598.4 3249.5 0 4243.2 3606.3 2464.6 3103.8 1340.9 4899.6;
			  4643.6 1197.8 3995.9 4243.2 0 991.1 1878.9  955.7 4767.8 1025.9;
			  4219.2 1175.8 4180.5 3606.3  991.1 0 1142.1 1542.2 4382.6 2010.6;
			  3116.4  775.5 3541.3 2464.6 1878.9 1142.1 0 1521.5 3293.9 2744.0;
			  3129.0 1505.6 2403.3 3103.8  955.7 1542.2 1521.5 0 3161.5  590.1;
			  230.4  1775.7 2378.3 1340.9 4767.8 4382.6 3293.9 3161.5 0 5165.3;
			  5084.6 1466.6 3862.9 4899.6 1025.9 2010.6 2744.0  590.1 5165.3 0]

#AmountGasTransported = zeros(nCOUNTRIES,nCOUNTRIES)
CostTransport = zeros(nCOUNTRIES,nCOUNTRIES)

#n = 0
#nn = 0
ProductionTrin = 0

ProductionTrin = sum(PreProduction - Consumption)
println("Production Tirn",ProductionTrin)
Production = PreProduction
println("Production",Production)
Production[8] = PreProduction[8] - ProductionTrin
println("after TT",Production)

println("production",Production)
	for n=1:nCOUNTRIES
			for nn =1:nCOUNTRIES
		    CostTransport[n,nn] = (0.02/1000)*Distance[n,nn]
		end
end

println("cost trans",CostTransport)



			  # Define the model name and solver. In this case, model name is "nn"
			  m = Model(solver=ClpSolver())

			  ######## Decision variable ########
			  @variable(m, AmountGasTransported[1:nCOUNTRIES,1:nCOUNTRIES] >= 0)

			  ############# Constraints ############
			  # Production in each country constraint
#			  @constraint(m,[n=1:nCOUNTRIES], Production[n] == sum(AmountGasTransported[n,nn] for nn=1:nCOUNTRIES))
#			  @constraint(m,[nn=1:nCOUNTRIES], Consumption[nn] == sum(AmountGasTransported[n,nn] for n=1:nCOUNTRIES))

			@constraint(m,[n=1:nCOUNTRIES], Production[n]-Consumption[n] == sum(AmountGasTransported[nn,n] for nn=1:nCOUNTRIES)-sum(AmountGasTransported[n,nn] for nn=1:nCOUNTRIES))
			 # @constraint(m,[nn=1:nCOUNTRIES], Consumption[nn] == sum(AmountGasTransported[n,nn] for n=1:nCOUNTRIES))


			  ######## Objective Functions #########
			  # Single objective for minimizing cost
			  @objective(m, Min, sum(sum(CostTransport[n,nn]*AmountGasTransported[n,nn] for nn=1:nCOUNTRIES) for n=1:nCOUNTRIES) + ProductionTrin*0.015*5)


#end
solve(m)
#print(m)

println("Objective value: ", getobjectivevalue(m))
println("Transport = ",getvalue(AmountGasTransported))
