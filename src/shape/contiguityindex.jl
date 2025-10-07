function contig_index(l::Landscape, patch, template)
    patch_mask = patches(l) .== patch
    # Keep all values in the patch, set others to zero
    patch_grid = zeros(Int, size(l))
    patch_grid[patch_mask] .= l.grid[patch_mask]
    println("patch_grid:\n", patch_grid)
    contig_vals = contiguityvalue(patch_grid, template)
    println("contig_vals:\n", contig_vals)
    patch_cells = findall(patches(l) .== patch)
    println("patch_cells: ", patch_cells)
    sum_vals = sum(contig_vals[patch_cells])
    println("sum_vals: ", sum_vals)
    n_cells = length(patch_cells)
    println("n_cells: ", n_cells)
    avg_val = sum_vals / n_cells
    println("avg_val: ", avg_val)
    template_sum = sum(template)
    println("template_sum: ", template_sum)
    result = (avg_val - 1) / (template_sum)
    println("final result: ", result)
    return result
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

