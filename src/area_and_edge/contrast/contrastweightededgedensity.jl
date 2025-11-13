"""
    perimeter_split_by_class_allpatches(l::Landscape, class_id; outside_key = :boundary)

Compute the total perimeter length of all patches of a given class,

"""


function perimeter_split_by_class_allpatches(l::Landscape, class_id; outside_key = :boundary)

    p = patches(l)
    pcopy = copy(p)
    pcopy[background(l)] .= 0

    # Map patch id -> class value
    patch_to_class = Dict{Any, Any}()
    for idx in CartesianIndices(p)
        pid = p[idx]
        if !haskey(patch_to_class, pid)
            patch_to_class[pid] = pid == 0 ? 0 : l[idx]
        end
    end

    # Find all patch ids belonging to requested class
    focal_pids = [pid for (pid, cls) in patch_to_class if cls == class_id && pid != 0]
    if isempty(focal_pids)
        return 0.0, Dict{Any, Float64}()
    end

    counts_by_patch = Dict{Any, Int}()
    edges_alongside_border = 0

    # Aggregate neighbor incidences for every focal patch
    for pid in focal_pids
        patch_coordinates = findall(isequal(pid), pcopy)
        if isempty(patch_coordinates)
            continue
        end

        to_check = vcat([coordinates .+ VonNeumann for coordinates in patch_coordinates]...)
        filter!(i -> i in CartesianIndices(pcopy), to_check)

        for val in pcopy[to_check]
            # skip internal adjacency between focal patches
            if val in focal_pids
                continue
            end
            counts_by_patch[val] = get(counts_by_patch, val, 0) + 1
        end

        # count edges along global border
        for coordinate in patch_coordinates
            for dim in Base.OneTo(ndims(l))
                if coordinate[dim] == 1 || coordinate[dim] == size(l, dim)
                    edges_alongside_border += 1
                end
            end
        end
    end

    if edges_alongside_border > 0
        counts_by_patch[outside_key] = get(counts_by_patch, outside_key, 0) + edges_alongside_border
    end

    # convert counts to lengths
    side_length = sqrt(l.area)
    neighbor_lengths_by_patch = Dict{Any, Float64}((k, v * side_length) for (k, v) in counts_by_patch)
    total_length = sum(values(neighbor_lengths_by_patch))

    return total_length, neighbor_lengths_by_patch
end

@testitem "We can split the perimeter of a class (all patches) by neighbor class" begin
    A = [
        1 1 1 2 2 2;
        1 1 1 2 2 2;
        3 3 3 2 2 2;
    ]
    L = Landscape(A)
    patches!(L)
    total_perim, by_class = perimeter_split_by_class_allpatches(L, 2)
    @test total_perim == 10.0
    @test by_class[1] == 2.0
    @test by_class[3] == 3.0
end

"""
    class_edge_contrast_index(l::Landscape, class_id, W::AbstractMatrix, class_order::AbstractVector; outside_key = :boundary)

Compute the edge contrast index for all patches of a given class in the landscape.

"""
function class_edge_contrast_index(l::Landscape, class_id, W::AbstractMatrix, class_order::AbstractVector; outside_key = :boundary)

    total_length, neighbor_lengths_by_patch = perimeter_split_by_class_allpatches(l, class_id; outside_key=outside_key)
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

    focal_idx = get(idxmap, class_id, 0)

    weighted_sum = 0.0
    for (neighbor_pid, len) in neighbor_lengths_by_patch
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

    # divide by total landscape area (number of cells * cell area)
    total_area = prod(size(p)) * l.area
    return total_area == 0.0 ? 0.0 : (weighted_sum / total_area)
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
    eci = class_edge_contrast_index(L, 1, W, class_order)
    @test eci == ((2.5 + 6 + 7) / 30)
end

"""
    class_edge_contrast_index(l::Landscape, class_id, W::AbstractMatrix, class_order::AbstractVector; outside_key = :boundary)

Compute the edge contrast index for all patches of the landscape.

"""

function class_edge_contrast_index(l::Landscape, W::AbstractMatrix, class_order::AbstractVector; outside_key = :boundary)

    eci_by_class = Dict{Any, Float64}()
    unique_classes = unique(l[.!background(l)])
    for class_id in unique_classes
        eci_by_class[class_id] = class_edge_contrast_index(l, class_id, W, class_order; outside_key=outside_key)
    end

    return eci_by_class

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
    eci = class_edge_contrast_index(L, W, class_order)
    @test eci == ((2.5 + 6 + 7) / 30)
end


