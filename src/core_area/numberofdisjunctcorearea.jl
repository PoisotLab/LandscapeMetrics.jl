"""

    number_of_disjunct_core_areas(l::Landscape, class_id, depth)

Count the number of disjunct core areas for all patches of a given class in the landscape,

"""
function number_of_disjunct_core_areas(l::Landscape, class_id, depth::Int=0)
    p = patches(l)

    patch_ids = unique(patches(l))
    nb_core = 0

    for pid in patch_ids
        if pid == 0
            continue
        end
        loc = findfirst(isequal(pid), p)

        if l[loc] != class_id
            continue
        end

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


"""

    number_of_disjunct_core_areas(l::Landscape, depth)

    Compute the number of disjunct core areas for all classes in the landscape.
"""

function number_of_disjunct_core_areas(l::Landscape, depth::Int=0)
    p = patches(l)

    patch_ids = unique(patches(l))
    nb_core = 0

    for pid in patch_ids
        if pid == 0
            continue
        end

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
        1 1 1 0 2 2 2;
        1 1 1 0 2 2 2;
        1 1 1 0 2 2 2
    ]
    L = Landscape(A)
    patches!(L)
    nodca = number_of_disjunct_core_areas(L, 1)
    @test nodca == 4
end
