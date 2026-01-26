"""
    disjunct_core_area_density(l::Landscape, class_id, depth)

Disjunct core area density for a given class in the landscape.
"""
function disjunct_core_area_density(l::Landscape, class_id, depth::Int=0)
    
    return number_of_disjunct_core_areas(l, class_id, depth) / totalarea(l)
end

@testitem "We can compute the disjunct core area density for a class" begin
    A = [
        0 1 1 1 1 1 0;
        0 1 1 1 1 1 0;
        0 1 1 1 1 1 0;
        0 0 0 0 0 0 0;
        0 0 0 0 1 1 1;
        0 0 0 0 1 1 1;
        1 1 1 0 0 0 0;
        1 1 1 0 0 0 0;
        1 1 1 0 0 0 0
    ]
    L = Landscape(A)
    patches!(L)
    nodca = disjunct_core_area_density(L, 1, 1)
    @test nodca == 2 / 63.0
end


"""
    number_of_disjunct_core_areas(l::landscape, depth)

    Number of disjunct core areas in each patch of the landscape at a specified depth.

"""

function disjunct_core_area_density(l::Landscape, depth::Int=0)
    total_disjunct_core_areas = 0
    unique_patches = unique(patches(l))
    for patch in unique_patches
        if patch != 0  # Assuming 0 is the background/no-data value
            total_disjunct_core_areas += count_core_areas(l, patch, depth)
        end
    end
    return total_disjunct_core_areas / totalarea(l)
    
end

@testitem "We can compute the disjunct core area density for a class" begin
    A = [
        0 1 1 1 1 1 0;
        0 1 1 1 1 1 0;
        0 1 1 1 1 1 0;
        0 0 0 0 0 0 0;
        0 0 0 0 1 1 1;
        0 0 0 0 1 1 1;
        1 1 1 0 2 2 2;
        1 1 1 0 2 2 2;
        1 1 1 0 2 2 2
    ]
    L = Landscape(A)
    patches!(L)
    nodca = disjunct_core_area_density(L, 1)
    @test nodca == 4 / 63.0
end

