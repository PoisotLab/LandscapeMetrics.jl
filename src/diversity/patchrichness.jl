"""

    patchrichness(l::Landscape)

Calculate the patch richness of a landscape `l`, defined as the number of unique patch types present in the landscape.

"""


function patchrichness(l::Landscape)
    unique_patch_types = Set{Int}()
    for patch in l.patches
        push!(unique_patch_types, patch.type)
    end
    return length(unique_patch_types)
end