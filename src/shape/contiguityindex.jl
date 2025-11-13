function contig_index(l::Landscape, patch, template)

    # Create a mask for the given patch
    patch_mask = patches(l) .== patch

    # Keep all values in the patch, set others to zero
    patch_grid = zeros(Int, size(l))

    # Fill in the values for the patch
    patch_grid[patch_mask] .= l.grid[patch_mask]

    # Get the contiguity values for the given template
    contig_vals = contiguityvalue(patch_grid, template)

    # Get the cells that belong to the patch
    patch_cells = findall(patches(l) .== patch)

    # Calculate the contiguity index
    sum_vals = sum(contig_vals[patch_cells])
    n_cells = length(patch_cells)
    avg_val = sum_vals / n_cells
    template_sum = sum(template)
   
    return (avg_val - 1) / (template_sum)
end

@testitem "We can compute the contiguity index of a patch" begin
    A = [
        1 1;
        1 1;
        1 3
    ]

    B = [1 2 1;
         2 1 2;
         1 2 1]
    L = Landscape(A)
    @test contig_index(L, 1, B) == 0.40
end

