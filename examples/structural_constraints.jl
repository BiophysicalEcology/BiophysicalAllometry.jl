# structural_constraints.jl
#
# Demonstrates elastic vs geometric similarity for limb proportions,
# and how these feed into body-part geometry for biophysical modelling.
#
# Run from the BiophysicalAllometry.jl root:
#   julia --project examples/structural_constraints.jl

using BiophysicalAllometry
using Unitful

println("Limb proportions under elastic vs geometric similarity (McMahon 1973)")
println()

# ── Limb dimensions across a size range ───────────────────────────────────────

animals = [
    ("Shrew",    2.0u"g"),
    ("Mouse",   20.0u"g"),
    ("Rat",    250.0u"g"),
    ("Cat",      4.0u"kg"),
    ("Dog",     20.0u"kg"),
    ("Human",   70.0u"kg"),
    ("Horse",  500.0u"kg"),
    ("Elephant", 4000.0u"kg"),
]

for sim in (ElasticSimilarity(), GeometricSimilarity())
    println("$(typeof(sim)):")
    println("  $(rpad("Animal", 12))  $(rpad("Mass", 10))  $(rpad("d (cm)", 9))  $(rpad("L (cm)", 9))  L/d (b)")
    println("  " * "─"^58)
    for (name, mass) in animals
        d = limb_diameter(sim, mass)
        l = limb_length(sim, mass)
        b = limb_aspect_ratio(sim, mass)
        println("  $(rpad(name, 12))  $(rpad(string(mass), 10))  $(rpad(string(round(u"cm", d; digits=1)), 9))  $(rpad(string(round(u"cm", l; digits=1)), 9))  $(round(b; digits=1))")
    end
    println()
end

# ── How to use limb_aspect_ratio with BiophysicalGeometry ────────────────────

println("─── Feeding limb_aspect_ratio into BiophysicalGeometry.Cylinder ───")
println()
println("For a 20 kg dog under elastic similarity:")
m = 20.0u"kg"
b_e = limb_aspect_ratio(ElasticSimilarity(),   m)
b_g = limb_aspect_ratio(GeometricSimilarity(), m)
r_e = limb_diameter(ElasticSimilarity(),   m) / 2
r_g = limb_diameter(GeometricSimilarity(), m) / 2

println("  ElasticSimilarity:   b = $(round(b_e; digits=2)),  r_leg = $(round(u"cm", r_e; digits=1))")
println("  GeometricSimilarity: b = $(round(b_g; digits=2)),  r_leg = $(round(u"cm", r_g; digits=1))")
println()
println("Usage in BiophysicalGeometry:")
println("  leg = Body(Cylinder(m_leg, density, b_leg), fur)   # b from limb_aspect_ratio")
println("  Join(:ventral, Attachment(:lateral, (z=..., φ=...), Disc(r_leg)), ...)  # r from limb_diameter/2")
println()

# ── Skeleton mass constraint check ────────────────────────────────────────────

println("─── Skeleton mass scaling check (Schmidt-Nielsen 1975) ───")
println()
println("Skeleton/body mass ratio increases with size (exponent 1.13, not 1.0):")
println()
println("  $(rpad("Animal", 12))  $(rpad("Body mass", 12))  $(rpad("Skeleton mass", 16))  Skeleton %")
println("  " * "─"^58)

for (name, mass) in animals[3:end]
    mass_kg = Unitful.uconvert(u"kg", mass)
    sk   = allometric(SkeletonMass(), EutherianMammal(), mass_kg)
    pct  = round(100 * ustrip(u"kg", sk) / ustrip(u"kg", mass_kg); digits=1)
    println("  $(rpad(name, 12))  $(rpad(string(mass), 12))  $(rpad(string(round(u"kg", sk; digits=2)), 16))  $pct%")
end
