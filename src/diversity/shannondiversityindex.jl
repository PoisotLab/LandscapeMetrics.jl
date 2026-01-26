"""

    shannondiversityindex(l::Landscape)

"""

function shannondiversityindex(l::Landscape)

# Calculate the proportion of each patch type
    patch_counts = Dict{eltype(l), Int}()
    total_patches = 0

    for idx in eachindex(l)
        if foreground(l)[idx]
            patch_type = l[idx]
            patch_counts[patch_type] = get(patch_counts, patch_type, 0) + 1
            total_patches += 1
        end
    end

    # Calculate Shannon diversity index
    H = 0.0
    for count in values(patch_counts)
        p_i = count / total_patches
        H -= p_i * log(p_i)
    end

    return H

end

@testitem "We can measure Shannon diversity index" begin
    A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2]
    L = Landscape(A)

    @test round(shannondiversityindex(L), digits=3) == 0.668
end

"""

    shannonevennessindex(l::Landscape)

"""


function shannonevennessindex(l::Landscape)
    H = shannondiversityindex(l)
    L = patchrichness(l)
    
    SHEI = H / log(L)
    return SHEI
end

@testitem "We can measure Shannon evenness index" begin
    A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2]
    L = Landscape(A)

    @test round(shannonevennessindex(L), digits=3) == 0.964
end