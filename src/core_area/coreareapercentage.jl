"""
    core_area_percentage(l::Landscape, depth)

Percentage of the landscape that is core area, given a specified edge depth.
"""

function core_area_percentage(l::Landscape, depth)

    # Get all patch ids
    patch_ids = unique(patches(l))

    # Compute total core area
    total_core = 0.0
    
    # Sum core area for each patch
    for pid in patch_ids
        if pid != 0
            total_core += core_area(l, pid, depth)
        end
    end
    return (total_core / totalarea(l)) * 100.0
end

@testitem "We can compute the core area percentage for the landscape" begin
    A = [
        0 0 0 0 0 0;
        0 1 1 1 1 0;
        0 1 1 1 1 0;
        0 1 1 1 1 0;
        0 0 0 0 0 0;
        0 0 0 0 0 0
    ]
    L = Landscape(A)
    patches!(L)
    cap = core_area_percentage(L, 1)
    @test cap == (2/36)*100.0
end
