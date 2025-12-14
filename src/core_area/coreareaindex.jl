"""
    core_area_index(l::Landscape, patch, depth)

Core area index (%) of a given patch in the landscape at a specified depth.

"""

function core_area_index(l::Landscape, patch, depth)
 
    return core_area(l, patch, depth) / area(l, patch) * 100.0

end

@testitem "We can compute the core area index for a patch" begin
    A = [
        0 1 1 1 1;
        0 1 1 1 1;
        0 1 1 1 1
    ]
    L = Landscape(A)
    patches!(L)
    cai = core_area_index(L, 1, 1)
    @test cai == (2/12)*100.0
end

@testitem "Core area is zero for multi-cell patch with depth 2" begin
    A = [
        0 1 1 1 1;
        0 1 1 1 1;
        0 1 1 1 1
    ]
    L = Landscape(A)
    @test core_area(L, 1, 1) == 2 
end