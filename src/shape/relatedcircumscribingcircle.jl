function related_circumscribing_circle(patch_points::Vector{Tuple{Float64, Float64}}, patch_area::Float64)
    circle = welzl_algorithm(copy(patch_points), [])
    circle_area = π * circle.radius^2
    return 1 - (patch_area / circle_area)
end


@testitem "related_circumscribing_circle works on a triangle" begin
    points = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0)]
    area = 0.5
    rcc = related_circumscribing_circle(points, area)
    @test isapprox(rcc, 1 - (area / (π * (sqrt(2)/2)^2)), atol=1e-6)
end