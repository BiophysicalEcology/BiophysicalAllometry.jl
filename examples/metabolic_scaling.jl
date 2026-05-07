# metabolic_scaling.jl
#
# Demonstrates basal metabolic rate scaling across taxa and body sizes,
# and other physiological allometries, from mycoplasma to blue whale.
#
# Run from the BiologicalScaling.jl root:
#   julia --project examples/metabolic_scaling.jl

using BiologicalScaling
using Unitful

# ── BMR across a size range ────────────────────────────────────────────────────

println("Basal metabolic rate — eutherian mammals across body sizes:")
println()
println("  $(rpad("Animal (approx.)", 22))  $(rpad("Mass", 12))  $(rpad("BMR", 12))  BMR/mass (W/kg)")
println("  " * "─"^70)

animals = [
    ("Shrew",       2.0u"g"),
    ("Mouse",       20.0u"g"),
    ("Rat",         250.0u"g"),
    ("Cat",         4.0u"kg"),
    ("Dog",         20.0u"kg"),
    ("Human",       70.0u"kg"),
    ("Horse",       500.0u"kg"),
    ("Elephant",    4000.0u"kg"),
]

for (name, mass) in animals
    bmr     = allometric(BasalMetabolicRate(), EutherianMammal(), mass)
    bmr_sp  = bmr / Unitful.uconvert(u"kg", mass)
    println("  $(rpad(name, 22))  $(rpad(string(mass), 12))  $(rpad(string(round(u"W", bmr; digits=3)), 12))  $(round(u"W/kg", bmr_sp; digits=2))")
end

# ── BMR across taxa at the same body mass ──────────────────────────────────────

println()
println("BMR at 1 kg body mass across taxonomic groups:")
println()

m = 1.0u"kg"
groups = [
    (EutherianMammal(),  "Eutherian mammal"),
    (Marsupial(),        "Marsupial"),
    (NonPasserineBird(), "Non-passerine bird"),
    (PasserineBird(),    "Passerine bird"),
]

for (taxon, label) in groups
    bmr = allometric(BasalMetabolicRate(), taxon, m)
    pl  = power_law(BasalMetabolicRate(), taxon)
    println("  $(rpad(label, 22))  BMR = $(rpad(string(round(u"W", bmr; digits=3)), 10))  exponent = $(pl.exponent)  ref: $(pl.reference)")
end

# ── Physiological time ────────────────────────────────────────────────────────

println()
println("Physiological allometries — eutherian mammals:")
println()
println("  $(rpad("Mass", 10))  $(rpad("Heart rate", 12))  $(rpad("Lifespan", 12))  $(rpad("Gen. time", 12))  $(rpad("Lung vol.", 12))")
println("  " * "─"^70)

for (name, mass) in animals[2:end]   # skip shrew (too small for reliable breath data)
    hr  = allometric(HeartRate(),      EutherianMammal(), mass)
    ls  = allometric(Lifespan(),       EutherianMammal(), mass)
    gt  = allometric(GenerationTime(), EutherianMammal(), mass)
    lv  = allometric(LungVolume(),     EutherianMammal(), mass)
    println("  $(rpad(string(mass), 10))  $(rpad(string(round(u"minute^-1", hr; digits=0)), 12))  $(rpad(string(round(u"yr", ls; digits=1)), 12))  $(rpad(string(round(u"yr", gt; digits=2)), 12))  $(round(u"mL", lv; digits=0))")
end

# ── Locomotion ────────────────────────────────────────────────────────────────

println()
println("Locomotion scaling — mammals:")
println()
println("  $(rpad("Mass", 10))  $(rpad("Stride freq.", 14))  Cost of transport")
println("  " * "─"^50)

for (name, mass) in animals
    sf  = allometric(StrideFrequency(), EutherianMammal(), mass)
    cot = allometric(CostOfTransport(), EutherianMammal(), mass)
    println("  $(rpad(string(mass), 10))  $(rpad(string(round(u"Hz", sf; digits=3)), 14))  $(round(u"J/kg/m", cot; digits=2))")
end

# ── Brain and skeleton ─────────────────────────────────────────────────────────

println()
println("Brain and skeleton mass — mammals:")
println()
println("  $(rpad("Mass", 10))  $(rpad("Brain mass", 14))  Brain %  Skeleton mass  Skeleton %")
println("  " * "─"^65)

for (name, mass) in animals
    mass_kg = Unitful.uconvert(u"kg", mass)
    bm  = allometric(BrainMass(),    EutherianMammal(), mass_kg)
    sk  = allometric(SkeletonMass(), EutherianMammal(), mass_kg)
    bp  = round(100 * ustrip(u"kg", bm)  / ustrip(u"kg", mass_kg); digits=2)
    skp = round(100 * ustrip(u"kg", sk)  / ustrip(u"kg", mass_kg); digits=1)
    println("  $(rpad(string(mass), 10))  $(rpad(string(round(u"g", bm; digits=1)), 14))  $(rpad(string(bp)*"%", 9))  $(rpad(string(round(u"kg", sk; digits=3)), 14))  $skp%")
end
