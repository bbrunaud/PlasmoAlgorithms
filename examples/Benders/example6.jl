using JuMP
using Gurobi
using Plasmo
using PlasmoAlgorithms

##Place MP and SP into ModelGraph
mp = Model(solver = GurobiSolver())
sp = Model(solver = GurobiSolver())

@variable(mp,y>=1)
@objective(mp,Min,2y)

@variable(sp,x[1:2]>=0)
@variable(sp,y>=0)
@constraint(sp,x[1:2].<=1)
@constraint(sp,x[1]+2x[2]+y>=5)
@objective(sp,Min,2x[1]+3x[2])

## Plasmo Graph
g = ModelGraph()
setsolver(g, GurobiSolver())
n1 = add_node(g)
setmodel(n1,mp)
n2 = add_node(g)
setmodel(n2,sp)

##Set n2 as a child node of n1
edge = Plasmo.add_edge(g,n1,n2)

## Linking constraints between MP and SP
@linkconstraint(g, n1[:y] == n2[:y])

bendersolve(g, max_iterations=20)
