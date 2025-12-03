"""
landscapeshapeindex(landscape::Landscape, patch::Int)

Calculates the Landscape Shape Index (LSI) for a given patch in the landscape.

The LSI is defined as the the total edge length of the patch divided by the square root of the total landscape area, * 0,25


"""

function landscapeshapeindex(l::Landscape, patch::Int)
    # We get the patches
    p = patches(l)

    # We find the coordinates of the given patch
    patch_coordinates = findall(isequal(patch), p)

    # Check that the patch exists
    if isempty(patch_coordinates)
        error("patch id $patch not found in landscape")
    end

    # Calculate total edge length of the patch
    edge_length = 0
    vonneumann = [CartesianIndex(-1,0), CartesianIndex(0,1), CartesianIndex(0,-1), CartesianIndex(1,0)]
    for coordinate in patch_coordinates
        neighbors = [coordinate + offset for offset in vonneumann if coordinate + offset in CartesianIndices(p)]
        for neighbor in neighbors
            if p[neighbor] != patch
                edge_length += 1
            end
        end
    end

    # Total landscape area
    total_area = total_area(l)

    # Calculate LSI
    lsi = (edge_length) * 0.25 / (sqrt(total_area))

    return lsi
end