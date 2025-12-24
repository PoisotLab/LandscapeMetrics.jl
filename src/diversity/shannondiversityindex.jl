"""

    shannondiversityindex(l::Landscape)

"""

function shannondiversityindex(l::Landscape)

# Calculate the proportion of each patch type
    patch_type_counts = Dict{Int, Int}()
    total_patches = length(l.patches)

    for patch in l.patches
        patch_type_counts[patch.type] = get(patch_type_counts, patch.type, 0) + 1
    end

    # Calculate the Shannon diversity index
    H = 0.0
    for count in values(patch_type_counts)
        p_i = count / total_patches
        H -= p_i * log(p_i)
    end

    return H

end


function shannonevennessindex(l::Landscape)
    H = shannondiversityindex(l)
    L = patchrichness(l)
    
    SHEI = H / log(L)
    return SHEI
end