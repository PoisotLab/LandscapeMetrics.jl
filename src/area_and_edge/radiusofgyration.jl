
"""
    radiusofgyration(l::Landscape)

Returns the mean distance between each cell in the patch and the patch centroid.

"""

function radiusofgyration(l::Landscape, patch)

    # We get the patches
    p = patches(l)

    # We get the coordinates of the patch
    patch_coordinates = findall(isequal(patch), p)

    # We get the center position of each cells
    centers = cellcenters(l)
    patch_centers = [centers[idx] for idx in patch_coordinates]

    # Find the centroid of the patch
    centroid = reduce(.+, patch_centers)./ length(patch_centers)

    # Compute distances from each cell to centroid
    distances = [hypot(c[1] - centroid[1], c[2] - centroid[2]) for c in patch_centers]

    # Return mean distance
    return mean(distances)

end



@testitem "The smallest radiusofgyration is 0 when the patch consists in a single cell" begin
    A = [0 1 0]  # Single cell patch
    L = Landscape(A)
    @test radiusofgyration(L, 1) == 0
end


@testitem "We can measure the radius of gyration for a multi-cell patch" begin
    A = [
         2 1 2 2 2 2;
         1 1 1 3 3 3;
         2 1 2 2 2 2
    ]
    L = Landscape(A)
    @test radiusofgyration(L, 1) == 0.8
end


@testitem "We can measure the radius of gyration for a multi-cell patch" begin
    A = [
         1 1 1
    ]
    L = Landscape(A)
    @test radiusofgyration(L, 1) == 2/3
end 


@testitem "We can measure the radius of gyration for a multi-cell patch" begin
L = Landscape([
        1 1 1 1 1 2 2 2 2 4 4 4 4 4;
        1 1 1 3 3 2 2 2 2 4 4 1 1 1;
        1 1 1 3 3 3 3 4 4 4 4 4 4 4;
        1 1 1 3 3 3 3 4 9 9 9 9 4 4;
        9 9 9 3 3 3 3 4 9 9 9 9 4 4;
        9 9 9 3 3 3 3 4 4 4 4 4 4 4;
        9 9 9 3 3 9 9 9 4 4 4 4 4 4;
        4 4 4 4 4 9 9 9 2 2 2 2 2 2;
        4 4 4 4 4 4 4 4 2 2 2 2 2 2
    ], nodata=9
)

P = patches(L)

for patch_num in unique(P)
    rog = radiusofgyration(L, patch_num)
    @info rog
end

end





L = Landscape([
        1 1 1 1 1 2 2 2 2 4 4 4 4 4;
        1 1 1 3 3 2 2 2 2 4 4 1 1 1;
        1 1 1 3 3 3 3 4 4 4 4 4 4 4;
        1 1 1 3 3 3 3 4 9 9 9 9 4 4;
        9 9 9 3 3 3 3 4 9 9 9 9 4 4;
        9 9 9 3 3 3 3 4 4 4 4 4 4 4;
        9 9 9 3 3 9 9 9 4 4 4 4 4 4;
        4 4 4 4 4 9 9 9 2 2 2 2 2 2;
        4 4 4 4 4 4 4 4 2 2 2 2 2 2
    ], nodata=9
)

P = patches(L)

for patch_num in unique(P)
    rog = radiusofgyration(L, patch_num)
    @info rog
end



