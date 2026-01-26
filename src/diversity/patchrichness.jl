"""

    patchrichness(l::Landscape)

Calculate the patch richness of a landscape `l`, defined as the number of unique patch types present in the landscape.

"""


function patchrichness(l::Landscape)
    unique_patch_types = Set{eltype(l)}()
    for idx in eachindex(l)
        if foreground(l)[idx]
            push!(unique_patch_types, l[idx])
        end
    end
    return length(unique_patch_types)
end


@testitem "We can measure the radius of gyration for a multi-cell patch" begin
    A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2]
    L = Landscape(A)

    L = Landscape(A)
    @test patchrichness(L) == 2
end