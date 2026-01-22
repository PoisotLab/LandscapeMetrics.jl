"""
    aggregationindex(landscape::Landscape)

The aggregation index (AI) of a landscape. It is a measure of the degree of aggregation of patches in the landscape.
It is calculated as:

    gii / max_gii * 100

where gii is the observed number of like adjacencies in the landscape, and max_gii is the maximum possible number of like adjacencies in the landscape.
"""

function aggregationindex(l::Landscape)

    # We get the patches
    p = patches(l)

    like_adjacencies = 0
    total_adjacencies = 0

    # For each cell in the landscape, we check its neighbors
    # Define VonNeumann neighborhood without self (no (0,0) offset)
    vonneumann = [CartesianIndex(-1,0), CartesianIndex(0,1), CartesianIndex(0,-1), CartesianIndex(1,0)]
    for coordinate in CartesianIndices(p)
        neighbors = [coordinate + offset for offset in vonneumann if coordinate + offset in CartesianIndices(p)]
        for neighbor in neighbors
            total_adjacencies += 1
            if p[neighbor] == p[coordinate]
                like_adjacencies += 1
            end
        end
    end

    if total_adjacencies == 0
        return 0.0
    end

    # Calculate max_gii: the maximum possible number of like adjacencies
    # First, count the area (number of cells) for each class
    class_areas = Dict{Int, Int}()
    for cell in p
        if haskey(class_areas, cell)
            class_areas[cell] += 1
        else
            class_areas[cell] = 1
        end
    end

    # Calculate max_gii for each class and sum them
    max_gii = 0
    for (class_id, Ai) in class_areas
        # n is the side of the largest integer square smaller than or equal to Ai
        n = floor(Int, sqrt(Ai))
        # m is the remainder
        m = Ai - n^2
        
        # Calculate max-gii based on the three cases
        if m == 0
            max_gii += 2 * n * (n - 1)
        elseif m <= n
            max_gii += 2 * n * (n - 1) + 2 * m - 1
        else  # m > n
            max_gii += 2 * n * (n - 1) + 2 * m - 2
        end
    end

    # Calculate the aggregation index
    gii = like_adjacencies
    ai = (gii / max_gii) * 100.0
    
    return ai
end