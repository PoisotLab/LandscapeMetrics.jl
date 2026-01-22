"""

    landscapedivisionindex(l::Landscape, class::Int)

Calculates the Landscape Division Index (LDI) for a given class in the landscape.
It's defined as 1 - the sum area squared of all patches of the class divided by the square of the total area of the landscape.

"""

function landscapedivisionindex(l::Landscape, class::Int)

    # We get the patches
    p = patches(l)

    # We find the coordinates of the given class
    class_coordinates = findall(x -> l[x] == class, CartesianIndices(l))
    # Check that the class exists
    if isempty(class_coordinates)
        error("class value $class not found in landscape")
    end

    # Calculate total area of the landscape
    total_area = total_area(l)
    # Calculate sum of squared areas of all patches of the class
    sum_area_squared = 0
    patch_ids = unique(p[class_coordinates])
    for patch_id in patch_ids
        patch_coordinates = findall(isequal(patch_id), p)
        patch_area = length(patch_coordinates)
        sum_area_squared += patch_area^2
    end

    # Calculate LDI
    ldi = 1 - (sum_area_squared / (total_area^2))
    return ldi
end


function landscapedivisionindex(l::Landscape)
    # We get the patches
    p = patches(l)

    # Get unique class ids
    class_ids = unique(l)

    # Sum of the sum of squared areas of all patches in the landscape
    total_sum_area_squared = 0
    total_area = total_area(l)
    for class_id in class_ids
        class_coordinates = findall(x -> l[x] == class_id, CartesianIndices(l))
        sum_area_squared = 0

        patch_ids = unique(p[class_coordinates])
        for patch_id in patch_ids
            patch_coordinates = findall(isequal(patch_id), p)
            patch_area = length(patch_coordinates)
            sum_area_squared += patch_area^2
        end
        total_sum_area_squared += sum_area_squared
    end
    # Calculate LDI
    ldi = 1 - (total_sum_area_squared / (total_area^2))
    return ldi
end