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

    # Check that the patch exists
    if isempty(patch_coordinates)
        error("patch id $patch not found in landscape")
    end

    # We create a dictionary to store the edge lengths for each unique edge type
    edge_lengths = Dict{Int, Int}()

    # For each cell in the patch, we check its neighbors
    vonneumann = [CartesianIndex(-1,0), CartesianIndex(0,1), CartesianIndex(0,-1), CartesianIndex(1,0)]
    for coordinate in patch_coordinates
        neighbors = [coordinate + offset for offset in vonneumann if coordinate + offset in CartesianIndices(p)]
        for neighbor in neighbors
            neighbor_patch = p[neighbor]
            if neighbor_patch != patch
                if haskey(edge_lengths, neighbor_patch)
                    edge_lengths[neighbor_patch] += 1
                else
                    edge_lengths[neighbor_patch] = 1
                end
            end
        end
    end

    total_edge_length = sum(values(edge_lengths))
    if total_edge_length == 0
        return 0.0
    end
    num_patch_types = length(keys(edge_lengths))
    if num_patch_types <= 1
        return 0.0
    end

    iji_sum = 0.0
    for edge_length in values(edge_lengths)
        proportion = edge_length / total_edge_length
        iji_sum += proportion * log(proportion)
    end

    iji = (-1 * iji_sum) / log(num_patch_types) * 100.0
    return iji
end