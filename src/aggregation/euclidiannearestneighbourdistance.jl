function euclidian_nearest_neighbour(l::Landscape, patch::Int)

    p = patches(l)

    patch_coordinates = findall(isequal(patch), p)
    if isempty(patch_coordinates)
        error("patch id $patch not found in landscape")
    end

    centers = cellcenters(l)
    patch_centers = [centers[idx] for idx in patch_coordinates]

    centroid = reduce(.+, patch_centers) ./ length(patch_centers)

    # Determine the class value for this patch using a representative cell
    rep = patch_coordinates[1]
    cls = l[rep]

    # Collect other patches of the same class (helper `patches_of_class` may not exist)
    pmat = p
    patch_to_class = Dict{Any, Any}()
    for pid in unique(pmat)
        if pid == 0
            patch_to_class[pid] = 0
            continue
        end
        loc = findfirst(isequal(pid), pmat)
        patch_to_class[pid] = l[loc]
    end

    other_patches = [pid for pid in keys(patch_to_class) if pid != 0 && pid != patch && patch_to_class[pid] == cls]
    if isempty(other_patches)
        return 0
    end

    other_patch_centroids = Vector{Tuple{Float64,Float64}}()
    for other_patch in other_patches
        other_patch_coordinates = findall(isequal(other_patch), p)
        other_patch_centers = [centers[idx] for idx in other_patch_coordinates]
        other_patch_centroid = reduce(.+, other_patch_centers) ./ length(other_patch_centers)
        push!(other_patch_centroids, other_patch_centroid)
    end

    distances = [hypot(centroid[1] - c[1], centroid[2] - c[2]) for c in other_patch_centroids]

    return minimum(distances)
end

"""
euclidian_nearest_neighbour_by_class(l, class_val; strategy=:min)

Compute nearest-neighbour distances for patches of a given class.
If strategy==:min returns the minimum centroid-to-centroid distance among distinct
patches of that class (0 when fewer than 2 patches exist).
If strategy==:per_patch returns a Dict mapping patch_id -> distance to its nearest
same-class neighbour.
"""
function euclidian_nearest_neighbour_by_class(l::Landscape, class_val; strategy=:min)
    p = patches(l)

    # collect patch ids that have class == class_val
    patch_ids = Int[]
    for pid in unique(p)
        pid == 0 && continue
        loc = findfirst(isequal(pid), p)
        if l[loc] == class_val
            push!(patch_ids, pid)
        end
    end

    if length(patch_ids) < 2
        return strategy == :per_patch ? Dict{Int,Float64}() : 0
    end

    centers = cellcenters(l)
    centroids = Dict{Int, Tuple{Float64,Float64}}()
    for pid in patch_ids
        coords = findall(isequal(pid), p)
        pts = [centers[idx] for idx in coords]
        cent = reduce(.+, pts) ./ length(pts)
        centroids[pid] = (float(cent[1]), float(cent[2]))
    end

    if strategy == :per_patch
        out = Dict{Int,Float64}()
        for (i, pid) in enumerate(patch_ids)
            c1 = centroids[pid]
            best = Inf
            for pid2 in patch_ids
                pid2 == pid && continue
                c2 = centroids[pid2]
                d = hypot(c1[1]-c2[1], c1[2]-c2[2])
                if d < best
                    best = d
                end
            end
            out[pid] = best
        end
        return out
    else
        # strategy == :min
        best = Inf
        n = length(patch_ids)
        for i in 1:n-1
            pid1 = patch_ids[i]
            c1 = centroids[pid1]
            for j in i+1:n
                pid2 = patch_ids[j]
                c2 = centroids[pid2]
                d = hypot(c1[1]-c2[1], c1[2]-c2[2])
                if d < best
                    best = d
                end
            end
        end
        return best
    end
end

@testitem "Euclidian nearest neighbour distance returns 0 when there is only one patch of the class" begin
    A = [
        1 1 0;
        1 1 0;
        0 0 0
    ]
    L = Landscape(A)
    @test euclidian_nearest_neighbour(L, 1) == 0
end

@testitem "Euclidian nearest neighbour distance works for multiple patches" begin
    A = [
        1 1 1 2 2 1 1 1;
        1 1 1 2 2 1 1 1;
        1 1 1 0 0 1 1 1;
        3 3 0 4 4 0 0 0;
        3 3 0 4 4 0 0 0
    ]
    L = Landscape(A)
    @test euclidian_nearest_neighbour(L, 2) == 5
   
end

@testitem "Euclidian nearest neighbour by class with :min strategy works" begin
    A = [
        1 1 1 2 2 1 1 1;
        1 1 1 2 2 1 1 1;
        1 1 1 0 0 1 1 1;
        3 3 3 4 3 3 3 0;
        3 3 3 4 3 3 3 0;
        3 3 3 4 3 3 3 0
    ]
    L = Landscape(A)
    @test euclidian_nearest_neighbour_by_class(L, 1; strategy=:min) == 5
    @test euclidian_nearest_neighbour_by_class(L, 3 ; strategy=:min) == 4
end