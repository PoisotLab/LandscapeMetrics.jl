"""
    aggregationindex(landscape::Landscape)

The aggregation index (AI) of a landscape. It is a measure of the degree of aggregation of patches in the landscape.
It is calculated as:

    gii / max_gii * 100

where gii is the observed number of like adjacencies in the landscape, and max_gii is the maximum possible number of like adjacencies in the landscape.
"""

function aggregationindex(l::Landscape)
    g = l.grid
    fg = foreground(l)
    rows, cols = size(g)

    # Observed number of like adjacencies (single-count: right and down)
    gii = 0
    for r in 1:rows
        for c in 1:cols
            if fg[r, c]
                if c < cols && fg[r, c + 1] && g[r, c] == g[r, c + 1]
                    gii += 1
                end
                if r < rows && fg[r + 1, c] && g[r, c] == g[r + 1, c]
                    gii += 1
                end
            end
        end
    end

    
    # Calculate max_gii for each class and sum them
    classes = unique(g[fg])
    max_gii = 0
    for class_id in classes
        Ai = count(fg .& (g .== class_id))
        n = floor(Int, sqrt(Ai))
        m = Ai - n^2

        if m == 0
            max_gii += 2 * n * (n - 1)
        elseif m <= n
            max_gii += 2 * n * (n - 1) + 2 * m - 1
        else
            max_gii += 2 * n * (n - 1) + 2 * m - 2
        end
    end

    if max_gii == 0
        return 0.0
    end

    return (gii / max_gii) * 100.0

end


@testitem "We can measure the aggregation index of a landscape" begin
    A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2
    ]
    L = Landscape(A)
    @test round(aggregationindex(L); digits=1) == 60.9
end