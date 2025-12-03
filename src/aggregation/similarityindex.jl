
"""
    similarity_index(l::Landscape, patch, W::AbstractMatrix, class_order::AbstractVector; search_radius::Float64=Inf)

The similarity index of a given patch in a landscape. It is the sum of the area of all patches of every class in the given radius, multiplied
by a similarity weight between the focal patch and the other patches, based on their class values (from a weight matrix W and class_order),
divided by the euclidian nearest neighbour distance squared of all of those patches.
"""

function similarity_index(l::Landscape, patch::Int, W::AbstractMatrix, class_order::AbstractVector; search_radius::Float64=Inf)

    # We get the patches
    p = patches(l)

    #We find the coordinates of the given patch
    patch_coordinates = findall(isequal(patch), p)

    # Check that the patch exists
    if isempty(patch_coordinates)
        error("patch id $patch not found in landscape")
    end

    # We take the first coordinate as representative
    rep = patch_coordinates[1]

    # Determine the class value for this patch using a representative cell
    cls = l[rep]


    # Find all other patches and their classes
    patch_to_class = Dict{Any, Any}()
    for pid in unique(p)
        if pid == 0
            continue
        end
        loc = findfirst(isequal(pid), p)
        patch_to_class[pid] = l[loc]
    end

    # Collect other patches
    other_patches = [pid for pid in keys(patch_to_class) if pid != patch]
    if isempty(other_patches)
        return 0.0
    end

    # Build class index map for matrix lookup
    idxmap = Dict(class => i for (i, class) in enumerate(class_order))

    # We set the similarity sum to zero
    similarity_sum = 0.0


    # For each other patch, compute the euclidian nearest neighbour distance within the search radius
    for other_patch in other_patches
        distance = euclidian_nearest_neighbour(l, other_patch)
        if distance <= search_radius && distance > 0.0
            area = count(==(other_patch), p)  # Assuming each cell has area 1
            c1 = idxmap[cls]
            c2 = idxmap[patch_to_class[other_patch]]
            weight = W[c1, c2]
            similarity_sum += (area * weight) / (distance^2)
        end
    end

    return similarity_sum
end