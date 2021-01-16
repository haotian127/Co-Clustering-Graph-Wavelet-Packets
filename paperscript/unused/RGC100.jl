## Load packages and functions
include(joinpath("..", "src", "func_includer.jl"))

## Build graph
G = loadgraph(joinpath(@__DIR__, "..", "datasets", "RGC100.lgz"))
N = nv(G)
X = load(joinpath(@__DIR__, "..", "datasets", "RGC100_xyz.jld"),"xyz")[:,1:2]
L = Matrix(laplacian_matrix(G))
lamb, 𝛷 = eigen(L); sgn = (maximum(𝛷, dims = 1)[:] .> -minimum(𝛷, dims = 1)[:]) .* 2 .- 1; 𝛷 = Matrix((𝛷' .* sgn)')
Q = incidence_matrix(G; oriented = true)
W = 1.0 * adjacency_matrix(G)

## Build Dual Graph
# distDAG = eigDAG_Distance(𝛷,Q,N)
# W_dual = sparse(dualGraph(distDAG))

distROT = JLD.load(joinpath(@__DIR__, "..", "datasets", "RGC100_distROT_unweighted_alp1.jld"), "distROT")
W_dual = sparse(dualGraph(distROT))

##
dualClusters = spectral_clustering(𝛷, 6)

display(length.(dualClusters))

scatter_gplot(X; marker = 𝛷[:,dualClusters[12][7]])

f = characteristic(dualClusters[6],N); wavelet = 𝛷 * Diagonal(f) * 𝛷' * spike(11,N); scatter_gplot(X; marker = wavelet)


##
Ψ_SGWT = pSGWT.sgwt_transform(11, Matrix(W); nf = 6)

scatter_gplot(X; marker = Ψ_SGWT[:,6])




## Build Hard Clustering NGW frame
# K = 5
# Ψ, dualClusters = HC_NGW_frame(W_dual,𝛷,K)

## Generate figures of the constructed wavelet vectors
# pyplot(dpi = 400)
# for i in 1:K
#     gplot(W, X; width = 1); plt = scatter_gplot!(X; marker = 𝛷[:,dualClusters[i][2]], ms = 3)
#     savefig(plt, "paperfigs/RGC100_HC_ROT_dualCluster$(i)_eigenvector$(dualClusters[i][2]).png")
# end
#
# for i in 1:K
#     gplot(W, X; width = 1); plt = scatter_gplot!(X; marker = Ψ[i,1,:], ms = 3)
#     savefig(plt, "paperfigs/RGC100_HC_ROT_wavelet$(i).png")
# end
