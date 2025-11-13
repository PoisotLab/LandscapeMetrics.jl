"""
    total_core_area(l::Landscape, depth)

Total core area of all patches in the landscape at a specified depth.
"""
function total_core_area(l::Landscape, depth)

    """
        total_core_area(l::Landscape, class_val::Integer, depth::Int=0)

    Total core area of all patches belonging to `class_val` in the landscape at a
    specified depth (default depth = 0).
    """
    function total_core_area(l::Landscape, class_val::Integer, depth::Int=0)

        # All patch ids in the landscape
        patch_ids = unique(patches(l))

        # Initialize total core area
        total_core = 0.0

        # Sum core areas only for patches that belong to the requested class
        for pid in patch_ids
            if pid == 0
                continue
            end

            # find a representative cell for this patch
            pos = findfirst(==(pid), patches(l))
            if pos === nothing
                continue
            end

            # check class value of that representative cell
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
        @test total_core_area(L, 1) == 7
    end