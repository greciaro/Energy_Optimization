Optimal biomass feedstock purchasing for energy content and pollution minimization

# Declare whihc packages I am using

using JuMP
using Clp

BIOMASS = ["OlivePits", "AlmondShells", "CornStalk", "RiceStraw", "DouglasFirNark", "SlashPineBark", "Manzanita", "PonderosaPine", "Eucalyptus", "Poplar"]
nBIOMASS = length(BIOMASS)
BaseLoad = 65*365*24*3600 #MJ

# Parameters
Carbon = [0.4881, 0.4498, 0.4386, 0.4178, 0.562, 0.564, 0.4818, 0.4925, 0.49, 0.4858]
Hydrogen = [0.0623, 0.0597, 0.0577, 0.0463, 0.059, 0.055, 0.0594, 0.0599, 0.0587, 0.0535]
Sulphur = [0.0001, 0.0002, 0.0005, 0.0008, 0, 0, 0.0002, 0.0003, 0.0001, 0.0001]
Nitrogen = [0.0036, 0.0116, 0.0128, 0.007, 0, 0, 0.0017, 0.0006, 0.003, 0.0121]
Oxygen = [0.4338, 0.4227, 0.4324, 0.3657, 0.367, 0.374, 0.4468, 0.4436, 0.4397, 0.3918]
Ash = [0.0121, 0.056, 0.058, 0.1624, 0.012, 0.007, 0.0101, 0.0031, 0.0085, 0.0569]
moistureXw = [0.35, 0.4, 0.4, 0.45, 0.35, 0.35, 0.3, 0.45, 0.35, 0.45]
CostFeedstocks = [23, 33, 16, 11, 35, 56, 54, 47, 23, 34]
Availability = [2*10^5 , 1.25*10^5, 0.25*10^5, 0.5*10^5, 1.5*10^5, 1*10^5, 2*10^5, 0.1*10^5, 0.4*10^5, 0.1*10^5] #tonnes of wet biomass
PowerOutput = zeros(nBIOMASS)
PurchaseFeedstocks  = zeros(nBIOMASS)
BiomassWet  = zeros(nBIOMASS)
BiomassDry  = zeros(nBIOMASS)
AshMass = zeros(nBIOMASS)
SulphurMass = zeros(nBIOMASS)


for b=1:nBIOMASS
BiomassDry[b] = 34.9 * Carbon[b] + 117.8 * Hydrogen[b] + 10.1 * Sulphur[b] - 1.5 * Nitrogen[b] - 10.3 * Oxygen[b] - 2.1 * Ash[b]
BiomassWet[b] = BiomassDry[b] * (1-moistureXw[b])
end

m = Model(solver=ClpSolver())

@variable(m,PurchaseFeedstocks[1:nBIOMASS] >= 0)

# Minimize:
@objective(m, Min, sum(CostFeedstocks[b] * PurchaseFeedstocks[b] for b = 1:nBIOMASS))

# Subject to:
@constraint(m,sum(0.31 * 1000 * BiomassWet[b] * PurchaseFeedstocks[b] for b = 1:nBIOMASS) == BaseLoad)
@constraint(m,sum(Sulphur[b]*PurchaseFeedstocks[b]*(1-moistureXw[b]) for b = 1:nBIOMASS)<= 0.0003*sum(PurchaseFeedstocks[b]*(1-moistureXw[b]) for b = 1:nBIOMASS))
@constraint(m,sum(Ash[b]* PurchaseFeedstocks[b]*(1-moistureXw[b]) for b = 1:nBIOMASS)<= 0.04*sum(PurchaseFeedstocks[b]*(1-moistureXw[b]) for b = 1:nBIOMASS))
@constraint(m,[b = 1:nBIOMASS], PurchaseFeedstocks[b] <= Availability[b])


solve(m)
print(m)

println("Objective value: ", getobjectivevalue(m)/10^6)
println("Buy = ",getvalue(PurchaseFeedstocks)./10^6)
