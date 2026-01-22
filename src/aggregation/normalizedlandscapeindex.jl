"""
    NormalizedLandscapeIndex(Landscape, class)

Calculates the Normalized Landscape Index (NLI) for a given class in the landscape.

NLI is defined as (ei - emin) / (emax - emin), where ei is the edge length of the class, emin is the minimum edge length possible for that class, and emax is the maximum edge length possible for that class.

"""

function normalizedlandscapeshapeindex(l::Landscape, class::Int)
    # We get the patches
    p = patches(l)

    # Validate class exists
    if !(class in unique(vec(p)))
        error("class value $class not found in landscape")
    end

    # Calculate ei: edge length of the class

    ### NEED TO REWRITE SO DOES IT USES THE TOTAL EDGE FUNCTION
    ei = 0
    vonneumann = [CartesianIndex(-1,0), CartesianIndex(0,1), CartesianIndex(0,-1), CartesianIndex(1,0)]
    for coordinate in CartesianIndices(p)
        if p[coordinate] == class
            neighbors = [coordinate + offset for offset in vonneumann if coordinate + offset in CartesianIndices(p)]
            for neighbor in neighbors
                if p[neighbor] != class
                    ei += 1
                end
            end
        end
    end

    # Calculate emin: minimum edge length possible for the class
    # Assuming minimum edge length occurs when the class forms a compact shape

    # This is the area of the class in term of cell numbers
    class_cells = count(==(class), p)

    # Calculate side length of the smallest square that can contain the class
    side_length = ceil(sqrt(class_cells))  

    # Calculate the M value
    M = class_cells - (side_length*2)

    if M == 0
        emin = 4 * side_length
    elseif (side_length*2) < class_cells <= (n*(side_length + 1))
        emin = 4 * side_length + 2
    else  # class_cells > side_length*2 + side_length
        emin = 4 * side_length + 4
    end
    # Calculate emax: maximum edge length possible for the class
    # Assuming maximum edge length occurs when the class is dispersed

    # Landscape area in terms of cell numbers
    A = length(p)

    # Number of cells on the boundary of the landscape
    B = 2 * (size(p, 1) + size(p, 2))

    # Proportion of cells that are in the class in the landscape
    proportion = class_cells / A

    if proportion <= 0.5
        emax = 4* class_cells
    elseif 0.5 < proportion <= (0.5A + 0.5B)/A & iseven(A)
        emax = 3A - 2 * class_cells
    elseif 0.5 < proportion <= (0.5A + 0.5B)/A & isodd(A)
        emax = 3A - 2 * class_cells + 3
    else 
        emax = ei + 4 * (A - class_cells)
    end

    # Calculate NLI
    nli =  (ei - emin) / (emax - emin)

    return nli
end