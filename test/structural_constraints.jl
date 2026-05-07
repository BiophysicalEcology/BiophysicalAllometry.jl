using BiologicalScaling, Unitful, Test

@testset "limb_diameter from length" begin
    de = limb_diameter(ElasticSimilarity(),   0.3u"m")
    dg = limb_diameter(GeometricSimilarity(), 0.3u"m")
    @test de isa Unitful.Length
    @test dg isa Unitful.Length
    # elastic predicts thicker limbs than geometric at large sizes
    @test limb_diameter(ElasticSimilarity(),   1.5u"m") >
          limb_diameter(GeometricSimilarity(), 1.5u"m")
end

@testset "limb_diameter from mass" begin
    de = limb_diameter(ElasticSimilarity(),   100.0u"kg")
    dg = limb_diameter(GeometricSimilarity(), 100.0u"kg")
    @test de isa Unitful.Length
    @test de > dg    # elastic predicts thicker limbs
end

@testset "limb_diameter increases with mass" begin
    @test limb_diameter(ElasticSimilarity(), 100.0u"kg") >
          limb_diameter(ElasticSimilarity(),   1.0u"kg")
end

@testset "limb_length increases with mass" begin
    @test limb_length(ElasticSimilarity(), 100.0u"kg") >
          limb_length(ElasticSimilarity(),   1.0u"kg")
    @test limb_length(GeometricSimilarity(), 100.0u"kg") >
          limb_length(GeometricSimilarity(),   1.0u"kg")
end

@testset "limb_aspect_ratio anatomically plausible" begin
    r = limb_aspect_ratio(GeometricSimilarity(), 1.0u"kg")
    @test 2.0 < r < 30.0    # typical mammal limbs are 2–30× longer than wide
    r_e = limb_aspect_ratio(ElasticSimilarity(), 1.0u"kg")
    @test 2.0 < r_e < 30.0
end

@testset "limb_aspect_ratio elastic < geometric (shorter relative limbs)" begin
    # Under elastic similarity limbs are relatively thicker → lower L/d ratio
    @test limb_aspect_ratio(ElasticSimilarity(),   20.0u"kg") <
          limb_aspect_ratio(GeometricSimilarity(), 20.0u"kg")
end

@testset "reference mass normalisation" begin
    # At exactly 1 kg the predicted values equal the reference values
    @test limb_diameter(ElasticSimilarity(),   1.0u"kg") ≈ 0.013u"m"
    @test limb_diameter(GeometricSimilarity(), 1.0u"kg") ≈ 0.013u"m"
    @test limb_length(ElasticSimilarity(),     1.0u"kg") ≈ 0.17u"m"
    @test limb_length(GeometricSimilarity(),   1.0u"kg") ≈ 0.17u"m"
end
