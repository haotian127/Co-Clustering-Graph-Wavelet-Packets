## Load packages and functions
include(joinpath("..", "src", "func_includer.jl"))

## Build Graph
N = 512; G = path_graph(N)
X = zeros(N,2); X[:,1] = 1:N
L = Matrix(laplacian_matrix(G))
lamb, V = eigen(L)
V = (V' .* sign.(V[1,:]))'
Q = incidence_matrix(G; oriented = true)
W = 1.0 * adjacency_matrix(G)

## Build Dual Graph
W_dual = 1.0 * adjacency_matrix(path_graph(N)) #ground truth

## Assemble NGWPs
ht_elist_PC, ht_vlist_PC = HTree_EVlist(V,W_dual)
wavelet_packet_PC = HTree_wavelet_packet(V,ht_vlist_PC,ht_elist_PC)

ht_elist_VM = ht_elist_PC
wavelet_packet_VM = HTree_wavelet_packet_varimax(V,ht_elist_VM)

## Wiggle plots
j = 5; gr(dpi=200);
for k in [1, 2, 5]
   WW = wavelet_packet_VM[j][k]
   plt = wiggle(sort_wavelets(WW); sc = 0.75)
   # savefig(plt, "figs/path512_VM_NGWP_j$(j)k$(k).png")
end
current()
