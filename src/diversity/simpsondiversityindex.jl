"""

    simpsondiversityindex(l::Landscape)

"""

function simpsondiversityindex(l::Landscape)

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

    H = 0.0
    for count in values(patch_counts)
        p_i = count / total_patches
        H += p_i^2
    end

    SIDI = 1 - H
    return SIDI

end


@testitem "We can measure Simpson diversity index" begin
    A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2]
    L = Landscape(A)

    @test round(simpsondiversityindex(L), digits=3) == 0.475
end


function modifiedsimpsondiversityindex(l::Landscape)

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

    H = 0.0
    for count in values(patch_counts)
        p_i = count / total_patches
        H += p_i^2
    end

    MSIDI = -log(H)
    return MSIDI
end

@testitem "We can measure Simpson diversity index" begin
    A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2]
    L = Landscape(A)

    @test round(modifiedsimpsondiversityindex(L), digits=3) == 0.645
end

function modifiedsimpsonevennessindex(l::Landscape)
    MSIDI = modifiedsimpsondiversityindex(l)
    L = patchrichness(l)
    
    MSEI = MSIDI / log(L)
    return MSEI
end

@testitem "We can measure Simpson evenness index" begin
    A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2]
    L = Landscape(A)

    @test round(modifiedsimpsonevennessindex(L), digits=3) == 0.93
end