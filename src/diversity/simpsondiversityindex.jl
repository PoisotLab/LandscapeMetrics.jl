"""

    simpsondiversityindex(l::Landscape)

"""

function simpsondiversityindex(l::Landscape)

    # Calculate the proportion of each patch type
    patch_type_counts = Dict{Int, Int}()
    total_patches = length(l.patches)

    
    # Sum of the proportion squared of each class type in the landscape
    for idx in eachindex(l)
        if foreground(l)[idx]
            patch_type_counts[l[idx]] = get(patch_type_counts, l[idx], 0) + 1
        end
    end
    D = 0.0
    for count in values(patch_type_counts)
        p_i = count / length(patch_type_counts)
        D += p_i^2
    end
    
    SIDI =1 - D
    return SIDI

end

@testitem "We can measure the radius of gyration for a multi-cell patch" begin
    A = [
        2 1 2;
        1 1 4;
        2 3 2
    ]
    L = Landscape(A)
    @test simpsondiversityindex(L) == 1.0
end

function modifiedsimpsondiversityindex(l::Landscape)

    # Calculate the proportion of each patch type
    patch_type_counts = Dict{Int, Int}()
    total_patches = length(l.patches)

    
    # Sum of the proportion squared of each class type in the landscape
    for patch in l.patches
        patch_type_counts[patch.type] = get(patch_type_counts, patch.type, 0) + 1
    end
    D = 0.0
    for count in values(patch_type_counts)
        p_i = count / total_patches
        D += p_i^2
    end
    MSIDI = -log(D)
    return MSIDI
end

function modifiedsimpsonevennessindex(l::Landscape)
    MSIDI = modifiedsimpsondiversityindex(l)
    L = patchrichness(l)
    
    MSEI = MSIDI / log(L)
    return MSEI
end