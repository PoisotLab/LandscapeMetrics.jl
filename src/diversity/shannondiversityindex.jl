"""

    shannondiversityindex(l::Landscape)

"""

function shannondiversityindex(l::Landscape)

# Calculate the proportion of each patch type
    patch_type_counts = Dict{Int, Int}()
    unique_patch_types = Set{eltype(l)}()

    for idx in eachindex(l)
        if foreground(l)[idx]
            patch_type_counts[l[idx]] = get(patch_type_counts, l[idx], 0) + 1
        end
    end

    for idx in eachindex(l)
        if foreground(l)[idx]
            push!(unique_patch_types, l[idx])
        end
    end

    # Calculate the Shannon diversity index
    H = 0.0
    for count in values(patch_type_counts)
        p_i = count / length(unique_patch_types)
        H -= p_i * log(p_i)
    end

    return H

end

@testitem "We can measure the radius of gyration for a multi-cell patch" begin
    A = [
        2 1 2;
        1 1 4;
        2 3 2
    ]
    L = Landscape(A)
    @test shannonevennessindex(L) == 1.0
end


function shannonevennessindex(l::Landscape)
    H = shannondiversityindex(l)
    L = patchrichness(l)
    
    SHEI = H / log(L)
    return SHEI
end