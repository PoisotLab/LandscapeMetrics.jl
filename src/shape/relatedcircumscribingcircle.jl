function related_circumscribing_circle(l::Landscape, patch)
    patch_area = area(l, patch)
    centers = cellcenters(l)
    patch_cells = findall(patches(l) .== patch)
    patch_points = [centers[I] for I in patch_cells]
    circle = minimum_enclosing_circle(copy(patch_points))
    circle_area = π * circle.radius^2
    println("Patch area: ", patch_area)
    println("Circle area: ", circle_area)
    return 1 - (patch_area / circle_area)
end

@testitem "We can measure the related circumscribing circle for a patch" begin
    A = [
         1 1 1
    ]
    L = Landscape(A)
    P = patches(L)
    @test related_circumscribing_circle(L, 1) ≈ 0.04507034144
end
