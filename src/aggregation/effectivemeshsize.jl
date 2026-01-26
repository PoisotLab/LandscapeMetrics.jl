"""

    effectivemeshsize(l::Landscape, class::Int)

Calculates the Effective Mesh Size (MESH) for a given class in the landscape.
The MESH is defined as the sum of the squared areas of all patches of the class divided by the total area of the landscape.

"""

function effectivemeshsize(l::Landscape, class::Int)

    # We get the patches
    p = patches(l)

    # We find the coordinates of the given class
    class_coordinates = findall(x -> l[x] == class, CartesianIndices(l))
    # Check that the class exists
    if isempty(class_coordinates)
        error("class value $class not found in landscape")
    end
    # Calculate total area of the landscape
    total_area = totalarea(l)
    # Calculate sum of squared areas of all patches of the class
    sum_area_squared = 0
    patch_ids = unique(p[class_coordinates])
    for patch_id in patch_ids
        patch_coordinates = findall(isequal(patch_id), p)
        patch_area = length(patch_coordinates)
        sum_area_squared += patch_area^2
    end
    # Calculate MESH
    mesh = sum_area_squared / total_area
    return mesh
end

function effectivemeshsize(l::Landscape)
    # We get the patches
    p = patches(l)

    # Get unique class ids
    class_ids = unique(l)

    # Sum of the sum of squared areas of all patches in the landscape
    total_sum_area_squared = 0
    total_area = totalarea(l)
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
    # Calculate MESH
    mesh = total_sum_area_squared / total_area
    return mesh
end

@testitem "We can measure the effective mesh size of a landscape" begin
       A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2]
    L = Landscape(A)

    @test round(effectivemeshsize(L), digits=3) == 5.111
end