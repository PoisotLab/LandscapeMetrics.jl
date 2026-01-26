"""
    total_core_area(l::Landscape, depth::Int=0)

Total core area for all patches in the landscape.

"""
function total_core_area(l::Landscape, depth::Int=0)
    patch_ids = unique(patches(l))
    total_core = 0.0
    for pid in patch_ids
        if pid == 0
            continue
        end
        total_core += core_area(l, pid, depth)
    end
    return total_core
end 

@testitem "We can measure the total core area for the landscape" begin
    A = [
        1 1 1 2 1 2;
        1 1 1 2 1 2;
        1 1 1 2 1 2
    ]
    L = Landscape(A)
    patches!(L)
    @test total_core_area(L, 1) == 1
end

"""
    total_core_area(l::Landscape, class_val::Integer, depth::Int=0)

Total core area for a specific class in the landscape.
"""
    function total_core_area(l::Landscape, class_val::Integer, depth::Int=0)
        patch_ids = unique(patches(l))
        total_core = 0.0
        for pid in patch_ids
            if pid == 0
                 continue
            end
            # find a representative cell for this patch
            pos = findfirst(==(pid), patches(l))
            if pos === nothing
                 continue
            end
            if l[pos] == class_val
                total_core += core_area(l, pid, depth)
            end
        end
        return total_core
    end


 @testitem "We can measure the total core area for a class" begin
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
        0 1 1 1 1 0;
        0 2 2 2 0 0;
        0 2 2 2 0 0;
        0 2 2 2 0 0
    ]
    L = Landscape(A)
    patches!(L)
    @test total_core_area(L, 1, 1) == 6
        end