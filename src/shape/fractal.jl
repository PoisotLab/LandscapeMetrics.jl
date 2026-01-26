"""
    fractaldimensionindex(l::Landscape, p::Integer)

Return the ratio of the log of the perimeter and the log of the patch area, after the perimeter is normalized assuming a square. Note that this version has been normalized to return results in between 0 (square) and maximally complex form (1).
"""
function fractaldimensionindex(l::Landscape, p::Integer)
    @assert p in patches(l)
    pij = perimeter(l, p)
    aij = area(l, p)
    return 2log(0.25 * pij) / log(aij) - 1
end

@testitem "The fractal dimension index for a square is ≈ 0" begin
    A = [
        3 3 3 3 3 3;
        3 1 1 3 3 3;
        3 1 1 3 3 3;
        3 3 3 3 3 3
    ]
    L = Landscape(A; nodata=3)
    @test fractaldimensionindex(L, 1) ≈ 0
end

@testitem "The fractal dimension index for a patch more complex than a square is between 0 and 1" begin
    A = [
        3 3 3 3 3 3;
        3 1 1 1 1 3;
        3 1 1 3 1 3;
        3 3 3 3 1 3
        3 1 1 1 1 3
        3 1 3 3 3 3
        3 1 3 3 1 3
        3 1 1 1 1 3
        3 3 3 3 1 3
        3 3 1 1 1 3
        3 3 3 3 3 3
    ]
    L = Landscape(A; nodata=3)
    @test fractaldimensionindex(L, 1) < 1
end

function _fractal_dimension(aij, pij)
    @assert length(aij) == length(pij)
    n = length(aij)
    denom = (n * sum(log.(pij .* pij))) - sum(log.(pij))^2.0
    num_partial = n * sum(log.(pij) .* log.(aij)) - sum(log.(pij)) * sum(log.(aij))
    return (2.0 / num_partial) / denom
end

"""

    fractaldimension(l::Landscape, c::Integer)

Returns the fractal dimension for a given class in the landscape. This is measured as the `fractaldimensionindex` across all patches from a single class.
"""
function fractaldimension(l::Landscape{T}, c::T) where {T<:Integer}

    @assert c in unique(values(l))

    # We identify the patches that correspond to class c
    patches_id = unique(patches(l)[findall(isequal(c), values(l))])

    # We now get their areas and perimeters
    aij = [area(l, p) for p in patches_id]
    pij = [perimeter(l, p) for p in patches_id]

    # We can now calculate the index
    return _fractal_dimension(aij, pij)
end

"""
    fractaldimension(l::Landscape)

Return the fractal dimension for the landscape. This is measured as the `fractaldimensionindex` across all patches (except the background).
"""
function fractaldimension(l::Landscape)

    # We take all patches in the landscape, with the exception of the patches that are made
    # of background values
    patches_id = filter(!iszero, unique(patches(l)))

    # We now get their areas and perimeters
    aij = [area(l, p) for p in patches_id]
    pij = [perimeter(l, p) for p in patches_id]

    # We can now calculate the index
    return _fractal_dimension(aij, pij)
end
