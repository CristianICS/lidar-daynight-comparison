## 3.X Day–night comparison of target-level metrics

### 3.X.1 Mission-level vertical error

Table 1 lists the median signed error (bias) and RMSE of last-return heights against the GNSS targets for each mission. Most missions have a bias within ±0.2 m. Two sites have much larger systematic offsets. The Alfred night flight at 100 m has a bias of +5.56 m, while the day flight at the same altitude has +0.10 m. At Quinces, five of the six missions have a bias of about −1.1 m, and only the night flight at 100 m is close to zero (+0.01 m). These offsets are constant across targets and do not depend on vegetation class or flight altitude. They point to errors in the vertical georeferencing of those missions, not to a property of day or night acquisition. Because RMSE and the proportion of incoherent last returns both include bias, results for those metrics at Alfred 100 m and at Quinces are reported but not read as day/night effects.

**Table 1.** Median last-return bias and RMSE (m) per mission, over all ground-reference targets inside the common area of interest (50 cm buffer).

| Site | Altitude (m) | Bias day | Bias night | RMSE day | RMSE night |
|:--|--:|--:|--:|--:|--:|
| Alfred | 40 | 0.00 | 0.10 | 0.11 | 0.15 |
| Alfred | 75 | 0.00 | 0.11 | 0.17 | 0.18 |
| Alfred | 100 | 0.10 | **5.56** | 0.27 | **5.56** |
| Alfred LOff | 100 | 0.02 | 0.04 | 0.11 | 0.11 |
| Encinacorba hillside | 40 | 0.03 | −0.05 | 0.10 | 0.08 |
| Encinacorba hillside | 75 | 0.02 | −0.04 | 0.10 | 0.08 |
| Encinacorba hillside | 100 | −0.01 | −0.05 | 0.09 | 0.08 |
| Encinacorba scenery | 40 | 0.18 | 0.14 | 0.18 | 0.15 |
| Encinacorba scenery | 75 | 0.16 | 0.13 | 0.17 | 0.14 |
| Encinacorba scenery | 100 | 0.15 | 0.13 | 0.17 | 0.14 |
| Quinces | 40 | **−1.11** | **−1.10** | 1.11 | 1.10 |
| Quinces | 75 | **−1.17** | **−1.08** | 1.17 | 1.08 |
| Quinces | 100 | **−1.19** | 0.01 | 1.19 | 0.06 |

### 3.X.2 Ground detection

Because the number of ground last returns per buffer was similar in all missions (median 12–13), differences in ground penetration showed up only as whether ground was detected at all, not as differences in return count. In 20 of the 39 site × altitude × class groups, every target had the same detection status in both flights. These include all Encinacorba groups at 40 and 75 m and all Quinces dense-treed targets at 40 m. In the remaining 19 groups (Table 2), detection was strongly uneven between conditions. Across all groups, 86 targets were detected only at night and 12 only by day. All day-only detections were at Quinces 40 and 75 m, mostly on roads, and none of those groups was significant.

The night advantage was concentrated in vegetated classes at 75 and 100 m. After Benjamini–Hochberg correction, four groups showed significantly more night detection:
- Alfred 75 m open treed: 20 targets detected only at night, none only by day.
- Alfred 100 m open treed: 9 and 0.
- Quinces 75 m dense treed: 12 and 1.
- Quinces 100 m dense treed: 13 and 0.

The first and last of these remained significant after Bonferroni correction. Where detection did not differ significantly, statistical power was often the limit. Only 3 of the 19 tested groups had enough discordant targets (at least 10) to reach significance after Bonferroni correction, even if every discordant target had favoured one condition. For example, all seven dense-treed targets at Alfred 75 m were detected only at night, but the smallest possible adjusted p-value for that group is 0.30. No group showed a significant day advantage in detection.

**Table 2.** Exact McNemar tests of ground detection (at least one ground last return within the 50 cm buffer), for groups with at least one discordant target.

| Site | Alt. (m) | Class | n | Both | Day only | Night only | Neither | p | p (BH) | p (Bonf.) | Bonf. attainable |
|:--|--:|:--|--:|--:|--:|--:|--:|:--|:--|:--|:--|
| Alfred | 75 | Dense treed | 7 | 0 | 0 | 7 | 0 | 0.016 | 0.059 | 0.297 | no |
| Alfred | 75 | Open treed | 36 | 16 | 0 | 20 | 0 | <0.001 | <0.001** | <0.001 | yes |
| Alfred | 75 | Shrub | 10 | 4 | 0 | 6 | 0 | 0.031 | 0.099 | 0.594 | no |
| Alfred | 100 | Dense treed | 7 | 4 | 0 | 3 | 0 | 0.250 | 0.475 | 1.000 | no |
| Alfred | 100 | Open treed | 36 | 27 | 0 | 9 | 0 | 0.004 | 0.019* | 0.074 | no |
| Alfred | 100 | Shrub | 10 | 9 | 0 | 1 | 0 | 1.000 | 1.000 | 1.000 | no |
| Alfred LOff | 100 | Dense treed | 7 | 6 | 0 | 1 | 0 | 1.000 | 1.000 | 1.000 | no |
| Alfred LOff | 100 | Open treed | 36 | 35 | 0 | 1 | 0 | 1.000 | 1.000 | 1.000 | no |
| Alfred LOff | 100 | Shrub | 10 | 9 | 0 | 1 | 0 | 1.000 | 1.000 | 1.000 | no |
| Encinacorba hillside | 100 | Open treed | 43 | 38 | 0 | 5 | 0 | 0.062 | 0.148 | 1.000 | no |
| Encinacorba scenery | 100 | Dense treed | 26 | 25 | 0 | 1 | 0 | 1.000 | 1.000 | 1.000 | no |
| Encinacorba scenery | 100 | Open treed | 37 | 36 | 0 | 1 | 0 | 1.000 | 1.000 | 1.000 | no |
| Quinces | 40 | Road | 19 | 14 | 5 | 0 | 0 | 0.062 | 0.148 | 1.000 | no |
| Quinces | 40 | Shrub | 8 | 7 | 1 | 0 | 0 | 1.000 | 1.000 | 1.000 | no |
| Quinces | 75 | Dense treed | 15 | 1 | 1 | 12 | 1 | 0.003 | 0.019* | 0.065 | yes |
| Quinces | 75 | Road | 19 | 13 | 5 | 1 | 0 | 0.219 | 0.462 | 1.000 | no |
| Quinces | 75 | Shrub | 8 | 6 | 0 | 2 | 0 | 0.500 | 0.792 | 1.000 | no |
| Quinces | 100 | Dense treed | 15 | 2 | 0 | 13 | 0 | <0.001 | 0.002** | 0.005 | yes |
| Quinces | 100 | Road | 19 | 17 | 0 | 2 | 0 | 0.500 | 0.792 | 1.000 | no |

*\* significant after Benjamini–Hochberg (BH) correction; \*\* also significant after Bonferroni correction (adjusted p < 0.05; family of 19 tests). "Bonf. attainable": whether the number of discordant targets allows p < 0.05/19 at all.*

### 3.X.3 Day–night differences in metric values

Table 3 summarises the magnitude tests per metric, and Table 4 gives the Hodges–Lehmann night-minus-day shift for every group. Full per-group statistics are in Supplementary Tables S1–S3.

**Table 3.** Paired Wilcoxon signed-rank tests per metric family. Direction is counted among BH-significant tests.

| Metric | Tests | Sig. (Bonf.) | Sig. (BH) | Night > day | Day > night |
|:--|--:|--:|--:|--:|--:|
| Mean intensity | 37 | 12 | 15 | 14 | 1 |
| Proportion of incoherent last returns | 23 | 6 | 13 | 2 | 11 |
| Last-return RMSE | 37 | 11 | 19 | 7 | 12 |

*Intensity.* Night intensity was higher in 14 of the 15 groups that differed significantly. The effect was clearest in open-treed targets: night intensity was significantly higher at every site and altitude with open-treed targets except Alfred 100 m and Alfred LOff. The shifts were +4.4 to +6.1 intensity units, or roughly 18–32% above the day medians. Road targets at Encinacorba hillside showed a similar increase at all three altitudes (+4.9 to +6.5; 26–33%), and so did shrub targets at Quinces 40 and 100 m (+5.9 and +9.7). No dense-treed group differed significantly. The only significant decrease was on roads at Quinces 75 m (−0.85). Alfred 100 m and Alfred LOff 100 m showed no significant intensity difference in any class.

*Vertical accuracy (RMSE).* Of the 19 BH-significant RMSE differences, four come from the mission offsets in Table 1: Alfred 100 m (+4.5 to +5.7 m) and Quinces 100 m (−0.9 to −1.2 m). Among the other 15, night RMSE was lower in 10 groups:
- all six dense-treed and open-treed groups at Encinacorba scenery (−0.017 to −0.047 m);
- the three open-treed groups at Encinacorba hillside (−0.013 to −0.023 m);
- roads at Quinces 75 m (−0.066 m), although that difference sits on top of the −1.1 m offset present in both flights.

Night RMSE was higher on the Encinacorba hillside roads at all altitudes (+0.021 to +0.032 m), on shrubs at Alfred 40 m (+0.082 m), and on dense-treed targets at Quinces 40 m (+0.022 m). Apart from the offset-affected groups, all significant RMSE differences were below 0.1 m, small compared with the 0.08–0.20 m RMSE of each flight. Dense-treed targets at Encinacorba hillside had RMSE of about 2.5 m in both flights, with no significant day/night difference.

*Incoherent last returns.* At Quinces 40 and 75 m, every last return was incoherent in both flights (proportion = 1) because of the −1.1 m offset, so no test was possible. The same was true for dense-treed targets at Encinacorba hillside. At Alfred 100 m (open treed, +0.96) and Quinces 100 m (road and shrub, −0.93 to −1.00), the significant differences again come from the offsets in Table 1. Among the remaining groups, the incoherent proportion was lower at night in nine of the 11 BH-significant cases:
- all six dense-treed and open-treed groups at Encinacorba scenery (−0.08 to −0.28; Bonferroni-significant for open treed at every altitude);
- the open-treed groups at Encinacorba hillside (−0.08 to −0.10).

The only clear increase at night was on shrubs at Alfred 40 m (+0.29), the same group whose night RMSE was higher.

*Altitude.* The higher night intensity was present at all three altitudes and did not weaken at 100 m. The night advantage in ground detection appeared only at 75 and 100 m: at 40 m, ground was detected on nearly every target in both conditions. Alfred LOff 100 m showed no significant day/night difference in any metric or test.

**Table 4.** Hodges–Lehmann estimate of the night-minus-day shift per group. Positive values are higher at night. † marks groups affected by a mission-level vertical offset (Table 1). \* BH-adjusted p < 0.05; \*\* also Bonferroni-adjusted p < 0.05 (one family per metric). "–": not tested (fewer than two non-zero paired differences). Intensity is in sensor units.

| Site | Alt. (m) | Class | Δ Intensity | Δ Prop. incoherent | Δ RMSE (m) |
|:--|--:|:--|:--|:--|:--|:--|
| Alfred | 40 | Dense treed | 4.35 | 0.11 | 0.027 |
| Alfred | 40 | Open treed | 4.54\*\* | 0.08 | −0.006 |
| Alfred | 40 | Shrub | −0.14 | 0.29\*\* | 0.082\* |
| Alfred | 75 | Dense treed | – | – | – |
| Alfred | 75 | Open treed | 4.40\*\* | 0.14 | −0.001 |
| Alfred | 75 | Shrub | −4.65 | 0.38 | 0.101 |
| Alfred† | 100 | Dense treed | 1.13 | 0.93 | 5.463 |
| Alfred† | 100 | Open treed | −1.34 | 0.96\*\* | 4.489\*\* |
| Alfred† | 100 | Shrub | −0.63 | 0.42 | 5.652\* |
| Alfred LOff | 100 | Dense treed | −0.38 | – | −0.003 |
| Alfred LOff | 100 | Open treed | 0.70 | −0.01 | 0.000 |
| Alfred LOff | 100 | Shrub | 0.77 | 0.00 | −0.003 |
| Encinacorba hillside | 40 | Dense treed | −0.60 | – | 0.077 |
| Encinacorba hillside | 40 | Open treed | 4.86\*\* | −0.08\* | −0.023\*\* |
| Encinacorba hillside | 40 | Road | 4.89\*\* | – | 0.031\* |
| Encinacorba hillside | 75 | Dense treed | −0.10 |– | 0.086 |
| Encinacorba hillside | 75 | Open treed | 5.38\*\* | −0.09\* | −0.021\*\* |
| Encinacorba hillside | 75 | Road | 6.10\*\* | – | 0.032\* |
| Encinacorba hillside | 100 | Dense treed | 3.38 | – | 0.037 |
| Encinacorba hillside | 100 | Open treed | 5.66\*\* | −0.10\* | −0.013\* |
| Encinacorba hillside | 100 | Road | 6.51\*\* | – | 0.021\*\* |
| Encinacorba scenery | 40 | Dense treed | 2.28 | −0.15\* | −0.034\*\* |
| Encinacorba scenery | 40 | Open treed | 6.03\*\* |  −0.28\*\* | −0.047\*\* |
| Encinacorba scenery | 40 | Road | 7.95 | −0.12 | −0.042 |
| Encinacorba scenery | 75 | Dense treed | −0.06 | −0.08\* | −0.017\* |
| Encinacorba scenery | 75 | Open treed | 5.77\*\* | −0.14\*\* | −0.027\*\* |
| Encinacorba scenery | 75 | Road | 4.31 | – | −0.035 |
| Encinacorba scenery | 100 | Dense treed | 2.75 | −0.18\* | −0.024\* |
| Encinacorba scenery | 100 | Open treed | 6.10\*\* | −0.19\*\* | −0.032\*\* |
| Encinacorba scenery | 100 | Road | 3.94 | – | −0.029 |
| Quinces† | 40 | Dense treed | 0.25 | – | 0.022\*\* |
| Quinces† | 40 | Road | 0.90\* | – | −0.005 |
| Quinces† | 40 | Shrub | 5.92\* | – | 0.001 |
| Quinces† | 75 | Dense treed | – | – | – |
| Quinces† | 75 | Road | −0.85\*\* | – | −0.066\*\* |
| Quinces† | 75 | Shrub | 1.59 | – | −0.073 |
| Quinces† | 100 | Dense treed | 0.31 | −0.75 | −0.880 |
| Quinces† | 100 | Road | 0.53 | −1.00\*\* | −1.164\*\* |
| Quinces† | 100 | Shrub | 9.69\* | −0.93\* | −1.095\* |

**Supplementary Tables S1–S4** give the full Wilcoxon results for each metric: n pairs, n non-zero, median day, median night, HL Δ, V, raw/BH/Bonferroni p-values and whether the exact or approximate method was used. They are in [paper_tables.md](results/stats/_tables/paper_tables.md) under the `magnitude_*` sections, with matching CSVs for your journal's table format.
