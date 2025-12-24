"""

    patchcohesionindex(l::Landscape, class::Int)

    The cohesion index (COHESION) of a class in a landscape. It measures the physical connectedness of the corresponding class.

"""

function patchcohesionindex(l::Landscape, class::Int)

    # We get the patches
    p = patches(l)

    # We find the coordinates of the given class
    class_coordinates = findall(x -> l[x] == class, CartesianIndices(l))

    # Check that the class exists
    if isempty(class_coordinates)
        error("class value $class not found in landscape")
    end 

    # Calculate ai: the sum of the areas of all patches of the class
    ai = 0
    for coordinate in class_coordinates
        ai += 1  # Each cell has an area of 1
    end

    # Calculate pi: the perimeter of all patches of the class
    pi = 0
    vonneumann = [CartesianIndex(-1,0), CartesianIndex(0,1), CartesianIndex(0,-1), CartesianIndex(1,0)]
    for coordinate in class_coordinates
        neighbors = [coordinate + offset for offset in vonneumann if coordinate + offset in CartesianIndices(p)]
        for neighbor in neighbors
            if p[neighbor] != class
                pi += 1
            end
        end
    end

    # Calculate Z: total number of cells in the landscape
    Z = length(p)

    # Calculate the PCI 
    PCI = (1 - (pi / (pi * sqrt(ai))))/ (1 - (1 / sqrt(Z))) 

    return PCI
end
