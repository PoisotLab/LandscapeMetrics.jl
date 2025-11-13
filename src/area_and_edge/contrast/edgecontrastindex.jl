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
        3 3 3 2 2 2;
    ]
    L = Landscape(A)
    patches!(L)
    total_perim, by_class = perimeter_split_by_class(L, 2)
    @test total_perim == 10.0
    @test by_class[1] == 2.0
    @test by_class[3] == 3.0
end

function edgecontrastindex(l::Landscape, patch, W::AbstractMatrix, class_order::AbstractVector; outside_key = :boundary)

    total_length, by_class = perimeter_split_by_class(l, patch; outside_key=outside_key)
    if total_length == 0
        return 0.0
    end

    p = patches(l)
    patch_to_class = Dict{Any, Int}()
    for idx in CartesianIndices(p)
        pid = p[idx]
        if !haskey(patch_to_class, pid)
            patch_to_class[pid] = pid == 0 ? 0 : l[idx]
        end
    end

    idxmap = Dict{Any, Int}()
    for (i, class) in enumerate(class_order)
        idxmap[class] = i
    end
    n = size(W, 1)
    if size(W,1) != size(W,2) || n != length(class_order)
        error("Weight matrix W must be square and match the length of class_order")
    end

    rep = findfirst(isequal(patch), p)
    @assert rep !== nothing "Patch $patch not found in landscape"
    focal_class = l[rep]
    focal_idx = get(idxmap, focal_class, 0)

    weighted_sum = 0.0
    for (neighbor_pid, len) in by_class
        neighbor_class = neighbor_pid === outside_key ? outside_key : (neighbor_pid == 0 ? 0 : patch_to_class[neighbor_pid])

        # edges alongside the explicit background (pid==0) should be weighted 0
        if neighbor_class == 0
            continue
        end

        j = get(idxmap, neighbor_class, 0)
        w = 1.0
        if focal_idx > 0 && j > 0
            w = float(W[focal_idx, j])
        end
        weighted_sum += len * w
    end

    return weighted_sum / total_length * 100.0
end
    

@testitem "We can compute the edge contrast index for a patch" begin
    A = [
        1 1 1 2 2 2;
        1 1 1 2 2 2;
        3 3 3 2 2 2;
    ]
    L = Landscape(A)
    patches!(L)
    W = [0.0 0.5 1.0;
         0.5 0.0 0.8;
         1.0 0.8 0.0] # classes: 1,2,3
    class_order = [1,2,3]
    eci = edgecontrastindex(L, 2, W, class_order)
    @test eci == (3 + 1 + 5)/10.0 * 100.0
end

@testitem "We can compute the edge contrast index for a patch" begin
    A = [
        0 0 0 2 2 2;
        1 1 1 1 2 2;
        3 3 3 2 2 2;
        1 1 1 1 2 2;
        1 1 1 1 0 0
    ]
    L = Landscape(A)
    patches!(L)
    W = [0.0 0.5 1.0;
         0.5 0.0 0.8;
         1.0 0.8 0.0] # classes: 1,2,3
    class_order = [1,2,3]
    eci = edgecontrastindex(L, 1, W, class_order)
    @test eci == (10.3 / 16 * 100)
end