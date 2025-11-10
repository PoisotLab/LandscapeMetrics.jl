function number_of_disjunct_core_areas(l::Landscape, class_id, depth)
    p = patches(l)

    # build patch id -> class map
    patch_to_class = Dict{Any, Any}()
    for idx in CartesianIndices(p)
        pid = p[idx]
        if !haskey(patch_to_class, pid)
            patch_to_class[pid] = pid == 0 ? 0 : l[idx]
        end
    end

    count = 0
    for (pid, cls) in patch_to_class
        if pid != 0 && cls == class_id
            # build integer mask for this patch (1 for cells in patch, 0 otherwise)
            A = zeros(Int, size(p))
            for idx in findall(isequal(pid), p)
                A[idx] = 1
            end
            core_mask = compute_core_mask(A, depth)
            # count connected core components
            ncores = count_core_areas(core_mask)
            count += ncores
        end
    end
    return count
end


@testitem "We can compute the number of disjunct core areas for a patch" begin
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
    nodca = number_of_disjunct_core_areas(L, 1, 1)
    @test nodca == 2
end
