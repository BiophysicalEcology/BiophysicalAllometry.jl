using BiologicalScaling, Unitful, Test

@testset "PowerLaw callable" begin
    pl = PowerLaw(3.34, 0.75; input_unit=u"kg", output_unit=u"W", reference="test ref")
    @test pl(1.0u"kg") isa Unitful.Power
    @test pl(1.0u"kg") ≈ 3.34u"W"
    @test pl(1000.0u"g") ≈ pl(1.0u"kg")        # unit conversion
    @test pl(2.0u"kg") > pl(1.0u"kg")           # monotone for positive exponent
    @test reference(pl) == "test ref"
end

@testset "PowerLaw negative exponent" begin
    pl = PowerLaw(241.0, -0.25; input_unit=u"kg", output_unit=u"minute^-1", reference="")
    @test pl(10.0u"kg") < pl(1.0u"kg")          # heart rate decreases with mass
end

@testset "PowerLaw g input unit" begin
    pl = PowerLaw(10.0, 0.667; input_unit=u"g", output_unit=u"cm^2", reference="")
    @test pl(100.0u"g") isa Unitful.Area
    @test pl(100.0u"g") ≈ pl(0.1u"kg")          # unit conversion g ↔ kg
end
