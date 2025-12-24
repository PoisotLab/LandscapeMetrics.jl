"""
    interspersion_juxtaposition_index(l::Landscape, patch)

The interspersion and juxtaposition index (IJI) of a given patch in a landscape. It is a measure of how interspersed a patch is with
other patch types in the landscape. The index ranges from 0 (no interspersion) to 100 (maximum interspersion).

It is calculated as: 

Minus the sum of the length of each unique edge type involving the patch type divided by the total length of edge
involving the same type, multiplied by the logarithm of the same fraction, divided by the logarithm of the number of patch types in the landscape - 1, all multiplied by 100. 
"""

function interspersion_juxtaposition_index(l::Landscape, patch::Int)

    # We get the patches
    p = patches(l)

    # We find the coordinates of the given patch
    patch_coordinates = findall(isequal(patch), p)

    # Get total edge length for the patch
    total_edge_length = 0.0

    # Dictionary to hold edge lengths to each other patch type
    edge_lengths = Dict{Int, Float64}()

    for coordinate in patch_coordinates
        neighbors = neighboring_indices(l, coordinate)
        for neighbor in neighbors
            neighbor_patch = p[neighbor]
            if neighbor_patch != patch && neighbor_patch != 0
                total_edge_length += 1.0  # Assuming each edge has length 1
                if haskey(edge_lengths, neighbor_patch)
                    edge_lengths[neighbor_patch] += 1.0
                else
                    edge_lengths[neighbor_patch] = 1.0
                end
            end
        end
    end

    # If there are no edges, return 0
    if total_edge_length == 0.0
        return 0.0
    end

    # Calculate IJI
    sum_term = 0.0

    # For each unique edge type, calculate the proportion and its contribution to the sum
    for (other_patch, length) in edge_lengths
        proportion = length / total_edge_length
        sum_term += proportion * log(proportion)
    end

    # Calculate number of patch types excluding background
    num_patch_types = length(unique(p)) - 1  # Exclude background (0)
    if num_patch_types <= 1
        return 0.0
    end

    iji = (-sum_term / log(num_patch_types)) * 100.0

    return iji
end

