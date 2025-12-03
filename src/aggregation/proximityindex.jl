"""
    proximity_index(l::Landscape, patch)

Compute the proximity index of a given patch in a landscape.

The proximity index is defined as the sum of the patch area divided by the nearest euclidian neighbour distance
squared, for all patches of the same class of the focal patch within a specified search radius.
"""

function proximity_index(l::Landscape, patch::Int; search_radius::Float64=Inf)

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

    # Find all other patches of the same class
    patch_to_class = Dict{Any, Any}()
for pid in unique(p)
    if pid == 0
        continue
    end
    loc = findfirst(isequal(pid), p)
    class_val = l[loc]
    if class_val == cls
        patch_to_class[pid] = class_val
    end
end

    # Collect other patches of the same class
    other_patches = [pid for pid in keys(patch_to_class) if pid != 0 && pid != patch && patch_to_class[pid] == cls]
    if isempty(other_patches)
        return 0.0
    end

    # We set the proximity sum to zero
    proximity_sum = 0.0

    # For each other patch, we compute the euclidian nearest neighbour distance within the search radius
    for other_patch in other_patches
        distance = euclidian_nearest_neighbour(l, other_patch)
        if distance <= search_radius && distance > 0.0
            area = count(==(other_patch), p)  # Assuming each cell has area 1
            proximity_sum += area / (distance^2)
        end
    end

    return proximity_sum
end




