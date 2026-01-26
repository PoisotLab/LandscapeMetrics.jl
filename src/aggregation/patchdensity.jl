"""

    patchdensity(l::Landscape, class::Int)

    The patch density (PD) of a class in a landscape. It is defined as the number of patches of the class per unit area of the landscape.
"""


function patchdensity(l::Landscape, class::Int)

    # Get the number of patches for the given class
    num_patches = numberofpatches(l, class)

    # Calculate total area of the landscape
    total_area = totalarea(l)

    # Calculate Patch Density
    PD = num_patches / total_area

    return PD
end


function patchdensity(l::Landscape)

    # Get the number of patches in the landscape
    num_patches = numberofpatches(l)

    # Calculate total area of the landscape
    total_area = totalarea(l)

    # Calculate Patch Density
    PD = num_patches / total_area

    return PD
end

@testitem "We can measure the patch density" begin
A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2]
    L = Landscape(A)

    @test patchdensity(L) == 5/18
end