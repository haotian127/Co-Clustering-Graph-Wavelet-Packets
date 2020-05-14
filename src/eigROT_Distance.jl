# require: JuMP.jl and Clp.jl
using JuMP, Clp
"""
        eigROT_Distance(P,Q; le = 1, α = 1.0)

EIGROT\\_DISTANCE computes the ROT distance matrix of P's column vectors on a graph.

# Input Argument
- `P::Matrix{Float64}`: a matrix whose columns are probability measures.
- `Q::Matrix{Float64}`: the oriented incidence matrix of the graph.
- `le::Array{Float64}`: default is 1, which is for unweighted input graph. For weighted graph, le is the length vector, which stores the length of each edge.
- `α::Float64`: default is 1.0. ROT parameter.

# Output Argument
- `dis::Matrix{Float64}`: distance matrix, dis[i,j] = d\\_ROT(pᵢ, pⱼ; α).

"""
function eigROT_Distance(P,Q; le = 1, α = 1.0)
n = size(P,2)
dis = zeros(n,n)
if le == 1
        Q2 = [Q -Q]
        m2 = size(Q2)[2]
        for i = 1:n-1, j = i+1:n
                f = P[:,i] - P[:,j]
                md = Model(with_optimizer(Clp.Optimizer, LogLevel = 0));
                @variable(md, w[1:m2] >= 0.0);
                @objective(md, Min, sum(w));
                @constraint(md, Q2 * w .== f);
                status = optimize!(md);
                wt = abs.(JuMP.value.(w));
                dis[i,j] = norm(wt .^ α,1)
        end
else
        le2 = [le;le]
        Q2 = [Q -Q]
        m2 = size(Q2)[2]
        for i = 1:n-1, j = i+1:n
                f = P[:,i] - P[:,j]
                md = Model(with_optimizer(Clp.Optimizer, LogLevel = 0));
                @variable(md);@variable(md, w[1:m2] >= 0.0);
                @objective(md, Min, sum(w.*le2));
                @constraint(md, Q2 * w .== f);
                status = optimize!(md);
                wt = abs.(JuMP.value.(w));
                dis[i,j] = norm((wt .^ α) .* le2,1)
        end
end
        return dis + dis'
end


"""
        ROT_Distance(A,B,Q; le = 1, α = 1.0)

ROT\\_DISTANCE computes the ROT distance matrix from A's column vectors to B's column vectors.

# Input Argument
- `A::Matrix{Float64}`: a matrix whose columns are initial probability measures.
- `B::Matrix{Float64}`: a matrix whose columns are terminal probability measures.
- `Q::Matrix{Float64}`: the oriented incidence matrix of the graph.
- `le::Array{Float64}`: default is 1, which is for unweighted input graph. For weighted graph, le is the length vector, which stores the length of each edge.
- `α::Float64`: default is 1.0. ROT parameter.

# Output Argument
- `dis::Matrix{Float64}`: distance matrix, dis[i,j] = d\\_ROT(aᵢ, bⱼ; α).

"""

function ROT_Distance(A,B,Q; le = 1, α = 1.0)
m = size(A,2)
n = size(B,2)
dis = zeros(m,n)
if le == 1
        Q2 = [Q -Q]
        m2 = size(Q2)[2]
        for i = 1:m, j = 1:n
                f = A[:,i] - B[:,j]
                md = Model(with_optimizer(Clp.Optimizer, LogLevel = 0));
                @variable(md, w[1:m2] >= 0.0);
                @objective(md, Min, sum(w));
                @constraint(md, Q2 * w .== f);
                status = optimize!(md);
                wt = abs.(JuMP.value.(w));
                dis[i,j] = norm(wt .^ α,1)
        end
else
        le2 = [le;le]
        Q2 = [Q -Q]
        m2 = size(Q2)[2]
        wt = zeros(m2)
        for i = 1:m, j = 1:n
                f = A[:,i] - B[:,j]
                md = Model(with_optimizer(Clp.Optimizer, LogLevel = 0));
                @variable(md);@variable(md, w[1:m2] >= 0.0);
                @objective(md, Min, sum(w.*le2));
                @constraint(md, Q2 * w .== f);
                status = optimize!(md);
                wt = abs.(JuMP.value.(w));
                dis[i,j] = norm((wt .^ α) .* le2, 1)
        end
end
        return dis
end
