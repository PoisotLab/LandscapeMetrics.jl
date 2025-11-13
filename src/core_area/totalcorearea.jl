"""
    total_core_area(l::Landscape, depth)

Total core area of all patches in the landscape at a specified depth.
"""
function total_core_area(l::Landscape, depth)

    # Getting all unique patch IDs
    patch_ids = unique(patches(l))

    # Initializing total core area
    total_core = 0.0

    # Summing core areas of all patches
    for pid in patch_ids
        if pid != 0
            total_core += core_area(l, pid, depth)
        end
    end
    
    return total_core
end

@testitem "We can measure the total core area" begin
    A = [
        0 0 0 0 0 0;
        0 1 1 1 1 0;
        0 1 1 1 1 0;
        0 1 1 1 1 0;
        0 0 0 0 0 0;
        0 0 0 0 0 0;
        0 1 1 1 1 0;
        0 1 1 1 1 0;
        0 1 1 1 1 0;
        0 1 1 1 1 0
    ]
    L = Landscape(A)
    patches!(L)
    @test total_core_area(L, 1) == 6
end