# ── Basal metabolic rate power-law constants ──────────────────────────────────

"""
    _BMR_EUTHERIAN

Kleiber's law for eutherian (placental) mammals: BMR = 3.34 × M^0.75 W (M in kg).

Source: Schmidt-Nielsen, K. (1975). Scaling in Biology: The Consequences of Size.
*American Zoologist* 15:295–305, Table 4-2.
See also: McNab, B. K. (2008). An analysis of the factors that influence the level
and scaling of mammalian BMR. *Comparative Biochemistry and Physiology A* 151:5–28.
"""
const _BMR_EUTHERIAN = PowerLaw(
    3.34, 0.75;
    input_unit  = u"kg",
    output_unit = u"W",
    reference   = "Schmidt-Nielsen 1975 Am. Zool. 15:295–305; McNab 2008 Comp. Biochem. Physiol. A 151:5–28"
)

"""
    _BMR_MARSUPIAL

Basal metabolic rate for marsupials: BMR = 2.36 × M^0.737 W (M in kg).

Source: Dawson, T. J., & Hulbert, A. J. (1970). Standard metabolism, body temperature,
and surface areas of Australian marsupials.
*American Journal of Physiology* 218:1233–1238.
"""
const _BMR_MARSUPIAL = PowerLaw(
    2.36, 0.737;
    input_unit  = u"kg",
    output_unit = u"W",
    reference   = "Dawson & Hulbert 1970 Am. J. Physiol. 218:1233–1238"
)

"""
    _BMR_NONPASSERINE

Basal metabolic rate for non-passerine birds: BMR = 3.79 × M^0.723 W (M in kg).

Source: Bennett, P. M., & Harvey, P. H. (1987). Active and resting metabolism in birds:
allometry, phylogeny and ecology. *Journal of Zoology* 213:327–363.
"""
const _BMR_NONPASSERINE = PowerLaw(
    3.79, 0.723;
    input_unit  = u"kg",
    output_unit = u"W",
    reference   = "Bennett & Harvey 1987 J. Zool. 213:327–363"
)

"""
    _BMR_PASSERINE

Basal metabolic rate for passerine birds: BMR = 6.25 × M^0.724 W (M in kg).

Source: Bennett, P. M., & Harvey, P. H. (1987). Active and resting metabolism in birds:
allometry, phylogeny and ecology. *Journal of Zoology* 213:327–363.
"""
const _BMR_PASSERINE = PowerLaw(
    6.25, 0.724;
    input_unit  = u"kg",
    output_unit = u"W",
    reference   = "Bennett & Harvey 1987 J. Zool. 213:327–363"
)

# ── allometric dispatch ────────────────────────────────────────────────────────

"""
    allometric(::BasalMetabolicRate, taxon, mass) → Power (W)

Predict basal metabolic rate from body mass using a taxon-specific power law.

# Examples
```julia
allometric(BasalMetabolicRate(), EutherianMammal(), 1.0u"kg")   # → ~3.34 W
allometric(BasalMetabolicRate(), Marsupial(),       500.0u"g")
allometric(BasalMetabolicRate(), PasserineBird(),   20.0u"g")
```
"""
allometric(::BasalMetabolicRate, ::EutherianMammal,  mass) = _BMR_EUTHERIAN(mass)
allometric(::BasalMetabolicRate, ::Marsupial,        mass) = _BMR_MARSUPIAL(mass)
allometric(::BasalMetabolicRate, ::NonPasserineBird, mass) = _BMR_NONPASSERINE(mass)
allometric(::BasalMetabolicRate, ::PasserineBird,    mass) = _BMR_PASSERINE(mass)
allometric(v::BasalMetabolicRate, ::AbstractMammal,  mass) = allometric(v, EutherianMammal(), mass)
allometric(v::BasalMetabolicRate, ::AbstractBird,    mass) = allometric(v, NonPasserineBird(), mass)

# ── power_law accessors ────────────────────────────────────────────────────────

"""
    power_law(::BasalMetabolicRate, taxon) → PowerLaw

Return the underlying `PowerLaw` for the given taxon.
"""
power_law(::BasalMetabolicRate, ::EutherianMammal)  = _BMR_EUTHERIAN
power_law(::BasalMetabolicRate, ::Marsupial)        = _BMR_MARSUPIAL
power_law(::BasalMetabolicRate, ::NonPasserineBird) = _BMR_NONPASSERINE
power_law(::BasalMetabolicRate, ::PasserineBird)    = _BMR_PASSERINE
power_law(v::BasalMetabolicRate, ::AbstractMammal)  = power_law(v, EutherianMammal())
power_law(v::BasalMetabolicRate, ::AbstractBird)    = power_law(v, NonPasserineBird())

# ── allometric_inputs ──────────────────────────────────────────────────────────

allometric_inputs(::BasalMetabolicRate, ::AbstractTaxon) = (:mass,)
