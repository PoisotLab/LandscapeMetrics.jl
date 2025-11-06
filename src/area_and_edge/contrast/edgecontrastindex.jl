function perimeter_split_by_class(l::Landscape, patch; outside_key = :boundary)

    p = patches(l)
   
    pcopy = copy(p)
    pcopy[background(l)] .= 0

    patch_coordinates = findall(isequal(patch), pcopy)

    to_check = vcat([coordinates .+ VonNeumann for coordinates in patch_coordinates]...)

    filter!(i -> i in CartesianIndices(pcopy), to_check)

    # count neighbor occurrences (excluding the patch itself)
    counts_by_patch = Dict{Any, Int}()
    for val in pcopy[to_check]
        if val != patch
            counts_by_patch[val] = get(counts_by_patch, val, 0) + 1
        end
    end

    # edges alongside the landscape border (same as in perimeter)
    edges_alongside_border = 0
    for coordinate in patch_coordinates
        for dim in Base.OneTo(ndims(l))
            if coordinate[dim] == 1 || coordinate[dim] == size(l, dim)
                edges_alongside_border += 1
            end
        end
    end
    if edges_alongside_border > 0
        counts_by_patch[outside_key] = get(counts_by_patch, outside_key, 0) + edges_alongside_border
    end

    # convert counts to lengths
    side_length = sqrt(l.area)
    by_patch = Dict{Any, Float64}((k, v * side_length) for (k, v) in counts_by_patch)
    total_length = sum(values(by_patch))

    return total_length, by_patch
end

@testitem "We can split the perimeter of a patch by class" begin
    A = [
        1 1 1 2 2 2;
        1 1 1 2 2 2;
        2 2 2 2 2 2;
    ]
    L = Landscape(A)
    patches!(L)
    total_perim, by_class = perimeter_split_by_class(L, 1)
    @test total_perim == 18
    @test by_class[2] == 5.0
end
