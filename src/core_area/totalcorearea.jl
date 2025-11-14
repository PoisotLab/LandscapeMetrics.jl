 """
        total_core_area(l::Landscape, depth::Int=0)

    Compute the total core area of all patches in the landscape at a specified
    depth (default depth = 0). This sums core area over every patch, regardless
    of class.
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
    @test total_core_area(L, 1) == 7
end



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