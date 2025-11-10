function core_area(l::Landscape, patch, depth)
    
    # Making a mask with all the cells in the patch
    patch_mask = patches(l) .== patch

    # Making a copy of the patch mask that will be modified to be only the core cells
    core_mask = copy(patch_mask)


    for d in 1:depth
        
        # Identifying the cells on the edge of the patch with the specified depth of edge value
        boundary = falses(size(core_mask))
        for i in 1:size(core_mask, 1)
            for j in 1:size(core_mask, 2)
                if core_mask[i, j]
                    for (di, dj) in ((-1,0), (1,0), (0,-1), (0,1))
                        ni, nj = i+di, j+dj
                        if 1 <= ni <= size(core_mask,1) && 1 <= nj <= size(core_mask,2)
                            if !core_mask[ni, nj]
                                boundary[i, j] = true
                            end
                        else
                            boundary[i, j] = true 
                        end
                    end
                end
            end
        end
        core_mask[boundary] .= false
    end
    # Calculating the core area
    cell_area = side(l)^2
    core_area = sum(core_mask) * cell_area
    return core_area
end

@testitem "Core area is zero for single cell patch with depth 1" begin
    A = [0 1 0; 0 0 0; 0 0 0]
    L = Landscape(A)
    @test core_area(L, 1, 1) == 0
end

@testitem "Core area is positive for multi-cell patch with depth 1" begin
    A = [
        0 1 1 1;
        0 1 1 1;
        0 1 1 1
    ]
    L = Landscape(A)
    @test core_area(L, 1, 1) == 1.0
end

@testitem "Core area is zero for multi-cell patch with depth 2" begin
    A = [
        0 1 1 1 1;
        0 1 1 1 1;
        0 1 1 1 1
    ]
    L = Landscape(A)
    @test core_area(L, 1, 1) == 2 
end

