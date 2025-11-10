
function disjunct_core_area_density(l::Landscape, class_id, depth)
    nodca = number_of_disjunct_core_areas(l, class_id, depth)
     
    return nodca / totalarea(l)
    
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