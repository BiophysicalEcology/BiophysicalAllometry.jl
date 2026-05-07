# dog_proportions.jl
#
# Demonstrates using BiologicalScaling to derive body-part proportions
# for a multi-part organism from total body mass alone, then feeding those
# values into BiophysicalGeometry to build a CompositeBody.
#
# This is the allometry-driven counterpart to BiophysicalGeometry's dog.jl
# example, which uses hardcoded proportions.
#
# Run from the BiologicalScaling.jl root:
#   julia --project examples/dog_proportions.jl

using BiologicalScaling
using Unitful

# ── Parameters ────────────────────────────────────────────────────────────────

m_total = 20.0u"kg"
taxon   = EutherianMammal()
density = 1000.0u"kg/m^3"

# ── Step 1: Structural proportions from allometry ─────────────────────────────

sim = ElasticSimilarity()   # swap to GeometricSimilarity() to compare

# Limb length-to-diameter ratio — the `b` parameter for BiophysicalGeometry.Cylinder
b_leg = limb_aspect_ratio(sim, m_total)

# Limb diameter → Disc radius for attaching legs to the torso
d_leg = limb_diameter(sim, m_total)
r_leg = d_leg / 2

# Limb length → estimate each leg's volume, then mass
l_leg = limb_length(sim, m_total)
m_one_leg = π * r_leg^2 * l_leg * density
m_four_legs = 4 * m_one_leg

# ── Step 2: Head mass from brain allometry ────────────────────────────────────

# Brain mass as a proxy for head mass.
# Human/primate brain = 8–10% of head mass; for a generic mammal ~8%.
m_brain = allometric(BrainMass(), taxon, m_total)
m_head  = m_brain / 0.08

# ── Step 3: Remaining body mass ───────────────────────────────────────────────

m_body = m_total - m_head - m_four_legs

# ── Report ────────────────────────────────────────────────────────────────────

r_b     = round(b_leg;             digits=2)
r_d     = round(u"cm", d_leg;      digits=1)
r_l     = round(u"cm", l_leg;      digits=1)
r_mleg  = round(u"kg", m_one_leg;  digits=3)
r_mlegs = round(u"kg", m_four_legs;digits=3)
r_brain = round(u"g",  m_brain;    digits=1)
r_mhead = round(u"kg", m_head;     digits=3)
r_mbody = round(u"kg", m_body;     digits=3)

println("Dog allometric proportions ($(typeof(sim)), M_total = $m_total)")
println()
println("  Limb aspect ratio  b_leg  = $r_b")
println("  Limb diameter      d_leg  = $r_d")
println("  Limb length        l_leg  = $r_l")
println("  Mass per leg              = $r_mleg")
println("  Total leg mass            = $r_mlegs")
println()
println("  Brain mass                = $r_brain")
println("  Estimated head mass       = $r_mhead")
println()
println("  Body (torso) mass         = $r_mbody")
println()

# ── Step 4: Show how to feed into BiophysicalGeometry ─────────────────────────
# (requires BiophysicalGeometry to be installed)

s_half  = round(u"kg", m_body/2;  digits=3)
s_leg   = round(u"kg", m_one_leg; digits=3)
s_b     = round(b_leg;            digits=1)
s_head  = round(u"kg", m_head;    digits=3)
s_rdisc = round(u"cm", r_leg;     digits=2)

println("To build the CompositeBody in BiophysicalGeometry:")
println()
println("  using BiophysicalGeometry")
println("  dorsal_fur  = Fur(15.0u\"mm\", 30.0u\"μm\", 3000u\"cm^-2\")")
println("  ventral_fur = Fur( 5.0u\"mm\", 30.0u\"μm\", 3000u\"cm^-2\")")
println("  limb_fur    = Fur( 8.0u\"mm\", 30.0u\"μm\", 3000u\"cm^-2\")")
println()
println("  dorsal  = Body(HalfCylinder($s_half, density, 3.0), dorsal_fur)")
println("  ventral = Body(HalfCylinder($s_half, density, 3.0), ventral_fur)")
println("  leg     = Body(Cylinder($s_leg, density, $s_b), limb_fur)")
println("  head    = Body(Ellipsoid($s_head, density, 1.5, 1.0), limb_fur)")
println()
println("  # Disc radius at leg–torso joints (from allometry):")
println("  r_disc = $s_rdisc")

# ── Comparison: elastic vs geometric similarity ───────────────────────────────

println()
println("─── Comparison: ElasticSimilarity vs GeometricSimilarity ───")
for s in (ElasticSimilarity(), GeometricSimilarity())
    b = round(limb_aspect_ratio(s, m_total); digits=2)
    d = round(u"cm", limb_diameter(s, m_total); digits=1)
    l = round(u"cm", limb_length(s, m_total); digits=1)
    println("  $(rpad(string(typeof(s)), 22)) b=$b  d=$d  l=$l")
end

# ── Other allometries for context ─────────────────────────────────────────────

bmr_str  = round(u"W",         allometric(BasalMetabolicRate(), taxon, m_total); digits=2)
skin_str = round(u"m^2",      Unitful.uconvert(u"m^2", allometric(SkinArea(), taxon, m_total)); digits=4)
skel_str = round(u"kg",       allometric(SkeletonMass(), taxon, m_total); digits=3)
hr_str   = round(u"minute^-1",allometric(HeartRate(),   taxon, m_total); digits=1)
ls_str   = round(u"yr",       allometric(Lifespan(),    taxon, m_total); digits=1)

println()
println("─── Other allometries for $m_total $(nameof(typeof(taxon))) ───")
println("  BMR            = $bmr_str")
println("  Skin area      = $skin_str")
println("  Skeleton mass  = $skel_str")
println("  Heart rate     = $hr_str")
println("  Lifespan       = $ls_str")
