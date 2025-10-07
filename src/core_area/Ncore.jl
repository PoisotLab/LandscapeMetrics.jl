"""

    Ncore ()

"""

function ncore(core_area)

    return length(core_area)

end

@testitem "Ncore returns the number of core areas" begin
    core_areas = [1.0, 2.0, 3.0]
    @test ncore(core_areas) == 3
end