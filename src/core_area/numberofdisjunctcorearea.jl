function number_of_disjunct_core_areas(l::Landscape, class_id, depth)
    patch_ids = unique(patches(l))
    count = 0
    for pid in patch_ids
        if pid != 0 && class_id == pid
            core_mask = compute_core_mask(l, depth)
            labeled_cores = flood_fill(core_mask)
            unique_cores = unique(labeled_cores)
            unique_cores = filter(x -> x != 0, unique_cores)
            count += length(unique_cores)
        end
    end
    return count
end


@testitem "We can compute the number of disjunct core areas for a patch" begin
    A = [
        0 1 1 1 1 1 0;
        0 1 1 1 1 1 0;
        0 1 1 1 1 1 1;
        0 0 0 0 1 1 1;
        0 0 0 0 1 1 1;
        1 1 1 0 0 0 0;
        1 1 1 0 0 0 0;
        1 1 1 0 0 0 0
    ]
    L = Landscape(A)
    patches!(L)
    nodca = number_of_disjunct_core_areas(L, 1, 1)
    @test nodca == 4
end

@testitem "Core area is positive for multi-cell patch with depth 1" begin
    A = [
        1 1 1 0 1 1 1;
        1 1 1 0 1 1 1;
        1 1 1 1 1 1 1;
        0 0 0 0 0 0 0 
    ]
    core_mask = compute_core_mask(A, 1)
    ncore = count_core_areas(core_mask)
    @test ncore == 2
end