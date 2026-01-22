"""
    perimeter(l::Landscape)

Other keyword arguments are passed to `patches`.
"""

function perimeter(l::Landscape, patch)

    # We get the patches
    p = patches(l)

    # The perimeter calculation assumes that the interactions with the barrier are part of
    # the perimeter, so we can set all the background cells to 0
    p[background(l)] .= 0

    # Get the coordinates of the patch
    patch_coordinates = findall(isequal(patch), p)

    # The list of patches we need to check is the list of neighbors to the patch
    to_check = vcat([coordinates .+ VonNeumann for coordinates in patch_coordinates]...)

    # Note that we do not check the UNIQUE neighbors here, to acount for the situation where
    # a neighbor is adjacent to two cells in the patch:
    #
    # XP
    # PP
    #
    # The neighbour X would be counted twice because it has two edges with cells from the
    # patch

    # We remove the cells that are not in the landscape itself
    filter!(i -> i in CartesianIndices(p), to_check)


    # What is very nice here is that we can just count the number of neighbors that have
    # a different patch value.
    number_of_edges = count(p[to_check] .!= patch)

    # We also need to count how many edges are on the landscape border, which is easy to do
    # as we need to count the number of locations for which either CartesianIndex have
    # a dimension that is either 1 or the size of the landcape alongside the relevant
    # dimension
    edges_alongside_border = 0
    for coordinate in patch_coordinates
        for dim in Base.OneTo(ndims(l))
            if coordinate[dim] in [1, size(l, dim)]
                edges_alongside_border += 1
            end
        end
    end

    # The perimeter is therefore the number of edges times the square root of the patch area
    return (number_of_edges + edges_alongside_border) * sqrt(l.area)
end

@testitem "We can measure the perimeter of a patch" begin
    A = [
        1 1 1 2 2 2;
        1 1 1 2 2 2;
        2 2 2 2 2 2;
    ]
    L = Landscape(A)
    @test perimeter(L, 2) == 10
end

@testitem "We can measure the perimeter of a patch with internal background" begin
    A = [
        1 1 1;
        1 2 1;
        1 1 1
    ]
    L = Landscape(A; nodata=2)
    patches!(L)
    @test perimeter(L, 1) == 16
end

@testitem "We can measure the perimeter of a patch with exterior background" begin
    A = [
        -2 -2 -2 -2 -2;
        -2 1 1 1 -2;
        -2 1 2 1 -2;
        -2 1 1 1 -2;
        -2 -2 -2 -2 -2
    ]
    L = Landscape(A; nodata=2)
    patches!(L)
    @test perimeter(L, 1) == 16
end

@testitem "We can measure the perimeter of a patch" begin
    A = [
        1 1 1 3 3 3;
        1 1 1 3 3 3;
        3 3 3 3 3 3
    ]
    L = Landscape(A)
    @test perimeter(L, 3) == 10
end
