"""
    clumpinessindex(landscape::Landscape)

The clumpiness index (CLUMPY) of a class in a landscape. It measures the proportional deviation 
of the proportion of like adjacencies involving the corresponding class from that expected under 
a spatially random distribution.

The formula varies based on the relationship between Gi (proportion of like adjacencies) and 
Pi (proportion of landscape comprised of the focal class):

- If Gi >= Pi: CLUMPY = (Gi - Pi) / (1 - Pi)
- If Gi < Pi and Pi >= 0.5: CLUMPY = (Gi - Pi) / (1 - Pi)
- If Gi < Pi and Pi < 0.5: CLUMPY = (Pi - Gi) / Pi

CLUMPY ranges from -1 to 1:
- CLUMPY = 1 when the class is maximally aggregated
- CLUMPY = 0 when the class is randomly distributed
- CLUMPY approaches -1 when the class is maximally disaggregated
"""

function clumpinessindex(l::Landscape, patch::Int)

    # We get the patches
    p = patches(l)

    # We find the coordinates of the given patch
    patch_coordinates = findall(isequal(patch), p)

    # Check that the patch exists
    if isempty(patch_coordinates)
        error("patch id $patch not found in landscape")
    end

    # We take the first coordinate as representative
    rep = patch_coordinates[1]

    # Determine the class value for this patch using a representative cell
    cls = l[rep]

    # Calculate Gi: proportion of like adjacencies for the class
    gi = percentageoflikeadjacencies(l, patch) / 100.0

    # Calculate Pi: proportion of landscape comprised of the focal class
    total_cells = length(p)
    class_cells = count(==(patch), p)
    pi = class_cells / total_cells

    # Calculate CLUMPY based on the conditions
    if gi >= pi
        clumpy = (gi - pi) / (1 - pi)
    elseif gi < pi && pi >= 0.5
        clumpy = (gi - pi) / (1 - pi)
    else  # gi < pi && pi < 0.5
        clumpy = (pi - gi) / pi
    end

    return clumpy


end