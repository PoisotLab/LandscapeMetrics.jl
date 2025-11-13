function number_of_disjunct_core_areas(l::Landscape, class_id, depth)
    p = patches(l)

    patch_ids = unique(patches(l))
    nb_core = 0

    for pid in patch_ids
        if pid == 0
            continue
        end
        loc = findfirst(isequal(pid), p)
        # only consider patches that belong to the requested class
        if l[loc] != class_id
            continue
        end

        # Use the public helper that accepts (Landscape, patchid, depth)
        # which returns the number of core areas for that patch.
        ncore = count_core_areas(l, pid, depth)
        nb_core += ncore
    end

    return nb_core
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
