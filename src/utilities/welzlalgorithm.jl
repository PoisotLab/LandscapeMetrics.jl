using Test

struct Circle
    center::Tuple{Float64, Float64}
    radius::Float64
end

distance(p1::Tuple{Float64, Float64}, p2::Tuple{Float64, Float64}) = sqrt((p1[1] - p2[1])^2 + (p1[2] - p2[2])^2)

is_point_in_circle(p::Tuple{Float64, Float64}, c::Circle) = distance(p, c.center) <= c.radius + 1e-9

function circumcircle(p1, p2, p3)
    A = 2 * (p2[1] - p1[1])
    B = 2 * (p2[2] - p1[2])
    C = 2 * (p3[1] - p1[1])
    D = 2 * (p3[2] - p1[2])
    E = p2[1]^2 + p2[2]^2 - p1[1]^2 - p1[2]^2
    F = p3[1]^2 + p3[2]^2 - p1[1]^2 - p1[2]^2
    denom = A * D - B * C
    if abs(denom) < 1e-12
        # Points are colinear; return a large circle or handle as needed
        center = ((p1[1] + p3[1]) / 2, (p1[2] + p3[2]) / 2)
        radius = maximum([distance(center, p) for p in (p1, p2, p3)])
        return Circle(center, radius)
    end
    cx = (E * D - B * F) / denom
    cy = (A * F - E * C) / denom
    center = (cx, cy)
    radius = distance(center, p1)
    return Circle(center, radius)
end

function trivial_circle(P)
    if length(P) == 0
        return Circle((0.0, 0.0), 0.0)
    
    elseif length(P) == 1
        return Circle(P[1], 0.0)
    
    elseif length(P) == 2
        center = ((P[1][1] + P[2][1]) / 2, (P[1][2] + P[2][2]) / 2)
        radius = distance(P[1], P[2]) / 2
        return Circle(center, radius)

    elseif length(P) == 3
    return circumcircle(P[1], P[2], P[3])
    end
end

function welzl_algorithm(P::Vector{Tuple{Float64, Float64}}, R::Vector{Tuple{Float64, Float64}})

    if isempty(P) || length(R) == 3
        return trivial_circle(R)
    end

    # Randomly select a point from P
    idx = rand(1:length(P))
    p = P[idx]
    P_new = [P[1:idx-1]; P[idx+1:end]] 
    
    # Remove p from P
    D = welzl_algorithm(P_new, R)
    if is_point_in_circle(p, D)
        return D
    else
        return welzl_algorithm(P_new, vcat(R, [p]))
    end
end

@testset "A circle through 3 points contains all 3 points" begin
    points = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0)]
    circle = welzl_algorithm(copy(points), Tuple{Float64,Float64}[])
    @test all(is_point_in_circle(p, circle) for p in points)
    # Optionally, check the center and radius for known cases
    @test isapprox(circle.center[1], 0.5; atol=1e-6)
    @test isapprox(circle.center[2], 0.5; atol=1e-6)
    @test isapprox(circle.radius, sqrt(0.5); atol=1e-6)
end