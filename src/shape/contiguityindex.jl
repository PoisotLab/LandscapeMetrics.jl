function contig_index(l::Landscape, patch, template)
    # Get the patch mask
    patch_mask = patches(l) .== patch
    # Compute contiguity values for the whole landscape
    contig_vals = contiguityvalue(Int.(patch_mask), template)
    # Get values only for the patch cells
    patch_cells = findall(patch_mask)
    sum_vals = sum(contig_vals[patch_cells])
    n_cells = length(patch_cells)
    avg_val = sum_vals / n_cells
    return (avg_val - 1) / (sum(template) - 1)
end

