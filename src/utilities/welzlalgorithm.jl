using Random

struct Circle
    center::Tuple{Float64, Float64}
    radius::Float64
end

distance(p1::Tuple{Float64, Float64}, p2::Tuple{Float64, Float64}) =
    sqrt((p1[1] - p2[1])^2 + (p1[2] - p2[2])^2)

is_point_in_circle(p::Tuple{Float64, Float64}, c::Circle) =
    distance(p, c.center) <= c.radius + 1e-9

function circumcircle(p1, p2, p3)
    A = 2 * (p2[1] - p1[1])
    B = 2 * (p2[2] - p1[2])
    C = 2 * (p3[1] - p1[1])
    D = 2 * (p3[2] - p1[2])
    E = p2[1]^2 + p2[2]^2 - p1[1]^2 - p1[2]^2
    F = p3[1]^2 + p3[2]^2 - p1[1]^2 - p1[2]^2
    denom = A * D - B * C
    if abs(denom) < 1e-12
        # Points are colinear; circle encloses all three points
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

# Recursive helper with index to avoid slicing and repeated random
function welzl_helper(P::Vector{Tuple{Float64, Float64}}, R::Vector{Tuple{Float64, Float64}}, n::Int)
    if n == 0 || length(R) == 3
        return trivial_circle(R)
    end

    p = P[n]
    D = welzl_helper(P, R, n - 1)

    if is_point_in_circle(p, D)
        return D
    else
        return welzl_helper(P, vcat(R, [p]), n - 1)
    end
end

# Public API: shuffle points once and call helper
function minimum_enclosing_circle(points::Vector{Tuple{Float64, Float64}})
    Pshuffled = shuffle(copy(points))
    return welzl_helper(Pshuffled, Tuple{Float64, Float64}[], length(Pshuffled))
end




@testitem "MEC of one point is a circle of radius 0 at that point" begin
    p = (1.0, 2.0)
    mec = minimum_enclosing_circle([p])
    @test mec.radius == 0.0
    @test mec.center == p
end

@testitem "MEC of two points is a circle with diameter the segment between them" begin
    p1 = (0.0, 0.0)
    p2 = (2.0, 0.0)
    mec = minimum_enclosing_circle([p1, p2])
    @test mec.radius == 1.0
    @test mec.center == (1.0, 0.0)
end