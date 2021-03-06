# Initialize MILP solver Clp
using Cbc
using CSV
using Plots
using DataFrames

Population = CSV.read("Population.csv")[1:end,1] # []people per block|
FaultDistance = CSV.read("FaultDistance.csv")[1:end, 1] # [km]
GeothermalResource = CSV.read("GeothermalResource.csv")[1:end, 1] # [km]
A = 100 #km^2 per block
#####################################
#Population Matrix
################################
 GeothermalResourceMatrix = zeros(112,44)
k = 1
for j = 1:44
    for i=1:112
        GeothermalResourceMatrix[i,j] = GeothermalResource[k]
    global k = k+1
    end
end

FaultDistanceMatrix = zeros(112,44)
k = 1
for j = 1:44
   for i=1:112
       FaultDistanceMatrix[i,j] = FaultDistance[k]
   global k = k+1
   end
end

FaultDistanceMatrix1 = reshape(FaultDistance,112,44)

k=1
ExtraMatrix = zeros(112+20,44+20)
for j= 11:54
for i = 11:122
ExtraMatrix[i,j] = Population[k]
global k = k+1
end
end

ExtraMatrix1 = zeros(112+20,44+20)
PopulationMatrix1 = reshape(Population,112,44)
ExtraMatrix1[11:122,11:54]=PopulationMatrix1

SumationPopulation = zeros(112,44)
for j = 1:44
for i = 1:112
SumationPopulation[i,j] =sum(sum(ExtraMatrix[a,b] for a =i:i+20) for b =j:j+20)
end
end
###########################################################

########## Declare model  ##########
# Define the model name and solver. In this case, model name is "m"
m = Model(solver=CbcSolver())

######## Decision variables ########
@variable(m, EGS[1:112,1:44], Bin)

######## Objective Function #########

@objective(m, Max, sum(sum(EGS[i,j]*GeothermalResourceMatrix[i,j] for i =1:112) for j=1:44))

############# Constraints ############
@constraint(m, [i=1:112,j=1:44], sum(sum(EGS[i,j] for i =1:112) for j=1:44) <= 100)
for j = 1:44
for i = 1:112
if FaultDistanceMatrix[i,j] <= 100
   @constraint(m, EGS[i,j] == 0)
end
end
end
for j = 1:44
for i = 1:112
if SumationPopulation[i,j] >= 100000
   @constraint(m, EGS[i,j] == 0)
end
end
end
#@constraint(m, [i=1:112,j=1:44], SumationPopulation[i,j]<=100000*EGS)


########### Print and solve ##########
status = solve(m)
# Print more detailed results to screen

#println("Energy storage size: ",StorageLimit[s])
println("Mazimum power output: ", getobjectivevalue(m)*A)
#println(s)
#Optimal_profit[1,s] = getobjectivevalue(m)
getvalue (EGS)
#x = findall(x-> x>=1, EGS)

heatmap(getvalue(EGS))
#println("Yes")

#for j = 1:44
#for i = 1:112
#totalEGS
#end
#end
