"""
    total_edge_contrast_index(l::Landscape, class_id, W::AbstractMatrix, class_order::AbstractVector; outside_key = :boundary)

Compute the Total Edge Contrast Index (TECI) for a specified class in the landscape.
"""


function total_edge_contrast_index(l::Landscape, class_id, W::AbstractMatrix, class_order::AbstractVector; outside_key = :boundary)
    # Get total edge length and lengths by neighboring patch/class
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

    # Map class values to indices in weight matrix
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

    # Weighted sum of edge lengths
    for (neighbor_pid, len) in neighbor_lengths_by_patch
        neighbor_class = neighbor_pid === outside_key ? outside_key : (neighbor_pid == 0 ? 0 : patch_to_class[neighbor_pid])
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

    # TECI = (Σ(length × weight) / Σ(length)) × 100
    TECI = (weighted_sum / total_length) * 100
    return TECI
end

@testitem "We can compute the total edge contrast index for a class" begin
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
         1.0 0.8 0.0]
    class_order = [1, 2, 3]
    teci_class2 = total_edge_contrast_index(L, 1, W, class_order)
    @test teci_class2 == (2.5 + 6 + 7)/22 * 100.0
end

"""
    total_edge_contrast_index(l::Landscape, W::AbstractMatrix, class_order::AbstractVector; outside_key = :boundary)

Compute the Total Edge Contrast Index (TECI) for all classes in the landscape.
"""

function total_edge_contrast_index(l::Landscape, W::AbstractMatrix, class_order::AbstractVector; outside_key = :boundary)
    teci_by_class = Dict{Any, Float64}()
    unique_classes = unique(l[.!background(l)])
    for class_id in unique_classes
        teci_by_class[class_id] = total_edge_contrast_index(l, class_id, W, class_order; outside_key=outside_key)
    end
    teci_all_classes = sum(values(teci_by_class))
    return teci_all_classes / length(teci_by_class) * 100
end

