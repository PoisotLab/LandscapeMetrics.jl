"""
    patch_cell_corners(l::Landscape, patch)

Returns the coordinates of the corners of all cells in the specified patch.

"""
function patch_cell_corners(l::Landscape, patch)

    # We get the length of the side of one cell
    s = side(l)

    # We get the cell centers
    centers = cellcenters(l)

    # We find all cells in the patch
    patch_cells = findall(patches(l) .== patch)

    # We compute the corners of each cell in the patch
    corners = Tuple{Float64,Float64}[]

    # Loop through each cell in the patch
    for idx in patch_cells
        c = centers[idx]
        push!(corners, (c[1] - s/2, c[2] - s/2))
        push!(corners, (c[1] - s/2, c[2] + s/2))
        push!(corners, (c[1] + s/2, c[2] - s/2))
        push!(corners, (c[1] + s/2, c[2] + s/2))
    end

    return unique(corners)
end

"""
    related_circumscribing_circle(l::Landscape, patch)

Returns the related circumscribing circle metric for the specified patch.
"""
function related_circumscribing_circle(l::Landscape, patch)

    # We get the area of the patch
    patch_area = area(l, patch)

    # We get the corners of the cells in the patch
    patch_points = patch_cell_corners(l, patch)

    # We compute the minimum enclosing circle
    circle = minimum_enclosing_circle(copy(patch_points))

    # We compute the area of the circle
    circle_area = π * circle.radius^2

    # We return the related circumscribing circle metric
    return 1 - (patch_area / circle_area)
end





