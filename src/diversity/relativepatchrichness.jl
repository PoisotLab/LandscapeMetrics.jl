"""


    relativepatchrichness(l::Landscape)

"""

function relativepatchrichness(l::Landscape)
    pr = patchrichness(l)
    max_pr = 10 # hypothetical maximum patch richness for normalization
    return (pr / max_pr)*100
end

@testitem "We can measure relative patch richness" begin
    A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2]
    L = Landscape(A)

    rpr = relativepatchrichness(L)
    @test isapprox(rpr, (2 / 10)*100)
end