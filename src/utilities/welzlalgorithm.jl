
function welzl_algorithm(P::Vector{Tuple{Float64, Float64}}, R::Vector{Tuple{Float64, Float64}})

    if isempty(P) || length(R) == 3
        return trivial_circle(R)
    end

    # Randomly select a point from P
    idx = rand(1:length(P))
    p = P[idx]
    P_new = vcat(P[1:idx-1], P[idx+1:end])  # Remove p from P
    D = welzl_algorithm(P_new, R)
    if is_point_in_circle(p, D)
        return D
    else
        return welzl_algorithm(P_new, vcat(R, [p]))
    end
end