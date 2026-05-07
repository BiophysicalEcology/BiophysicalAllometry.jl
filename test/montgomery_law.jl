using BiologicalScaling, Unitful, Test

@testset "MontgomeryLaw callable" begin
    ml = MontgomeryLaw(0.65; reference="test")
    area = ml(0.08u"m", 0.04u"m")
    @test area isa Unitful.Area
    @test area ≈ 0.65 * 0.08 * 0.04 * u"m^2"
    @test reference(ml) == "test"
end

@testset "MontgomeryLaw unit flexibility" begin
    ml = MontgomeryLaw(0.65)
    area_m  = ml(0.08u"m",  0.04u"m")
    area_cm = ml(8.0u"cm",  4.0u"cm")
    @test Unitful.uconvert(u"m^2", area_cm) ≈ area_m
end

@testset "MontgomeryLaw parameter bounds" begin
    # Physical limits: 0.5 (triangle) to π/4 (ellipse)
    ml_lo = MontgomeryLaw(0.5)
    ml_hi = MontgomeryLaw(π/4)
    l, w = 0.1u"m", 0.05u"m"
    @test ml_lo(l, w) < ml_hi(l, w)
    @test ml_lo(l, w) ≈ 0.5 * l * w
    @test ml_hi(l, w) ≈ (π/4) * l * w
end
