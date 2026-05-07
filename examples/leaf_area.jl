# leaf_area.jl
#
# Demonstrates the Montgomery leaf area model and leaf dry mass allometry
# across different plant groups.
#
# Run from the BiologicalScaling.jl root:
#   julia --project examples/leaf_area.jl

using BiologicalScaling
using Unitful

# ── Montgomery parameter by plant group ───────────────────────────────────────

println("Montgomery parameters by plant group (Shi et al. 2019):")
println("  (a₁ = 0.5 → triangular leaf; a₁ = π/4 ≈ 0.785 → elliptical leaf)")
println()

taxa = [
    (Rosaceae(),      "Rosaceae"),
    (Lauraceae(),     "Lauraceae"),
    (BroadleafPlant(),"Generic broadleaf"),
    (Oleaceae(),      "Oleaceae"),
    (Liriodendron(),  "Liriodendron (tulip trees)"),
    (Bambusoideae(),  "Bambusoideae"),
]

for (taxon, label) in taxa
    ml = montgomery_law(LeafArea(), taxon)
    println("  $(rpad(label, 28))  a₁ = $(ml.coefficient)")
end

# ── Leaf area predictions ──────────────────────────────────────────────────────

println()
println("Leaf area predictions (L = 80 mm, W = 40 mm):")
println()

l, w = 80.0u"mm", 40.0u"mm"
for (taxon, label) in taxa
    area = allometric(LeafArea(), taxon, l, w)
    println("  $(rpad(label, 28))  A = $(round(u"cm^2", area; digits=2))")
end

# ── Effect of leaf dimensions on area ─────────────────────────────────────────

println()
println("Broadleaf area vs length (W/L = 0.5 fixed, BroadleafPlant):")
println()

for l_mm in [20, 40, 60, 80, 100, 150, 200]
    local l = l_mm * u"mm"
    local w = 0.5 * l
    area = allometric(LeafArea(), BroadleafPlant(), l, w)
    mass = allometric(LeafDryMass(), BroadleafPlant(), l, w)
    println("  L = $(lpad(l_mm, 4)) mm  →  A = $(rpad(round(u"cm^2", area; digits=2), 12))  dry mass = $(round(u"mg", mass; digits=1))")
end

# ── Leaf dry mass from area ────────────────────────────────────────────────────

println()
println("Leaf dry mass from area (Milla & Reich 2007, exponent 1.10):")
println("  (larger leaves are thinner per unit area → exponent < 1.5)")
println()

for area_cm2 in [1, 5, 10, 20, 50, 100, 200]
    area = area_cm2 * u"cm^2"
    mass = allometric(LeafDryMass(), BroadleafPlant(), area)
    sla  = area / Unitful.uconvert(u"g", mass)  # specific leaf area
    println("  A = $(lpad(area_cm2, 4)) cm²  →  M = $(rpad(round(u"mg", mass; digits=1), 10))  SLA = $(round(u"cm^2/g", sla; digits=1))")
end

# ── Reference retrieval ───────────────────────────────────────────────────────

println()
println("Literature sources:")
println("  LeafArea    → ", reference(montgomery_law(LeafArea(), BroadleafPlant())))
println("  LeafDryMass → ", reference(power_law(LeafDryMass(), BroadleafPlant())))
