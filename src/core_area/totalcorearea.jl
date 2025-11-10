
function total_core_area(l::Landscape, depth)
    patch_ids = unique(patches(l))
    total_core = 0.0
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