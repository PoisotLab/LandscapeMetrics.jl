"""

    patchrichnessdensity(l::Landscape)

"""

function patchrichnessdensity(l::Landscape)
    pr = patchrichness(l)
    area = totalarea(l)
    return pr / area
end

@testitem "We can measure patch richness density" begin
    A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2]
    L = Landscape(A)

    prd = patchrichnessdensity(L)
    @test isapprox(prd, 2 / 18)
end