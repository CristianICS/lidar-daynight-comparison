## mission_vertical_error

|Site                 | Altitude (m)| Median bias day (m)| Median bias night (m)| Median RMSE day (m)| Median RMSE night (m)|
|:--------------------|------------:|-------------------:|---------------------:|-------------------:|---------------------:|
|Alfred               |           40|                0.00|                  0.10|                0.11|                  0.15|
|Alfred               |           75|                0.00|                  0.11|                0.17|                  0.18|
|Alfred               |          100|                0.10|                  5.56|                0.27|                  5.56|
|Alfred LOff          |          100|                0.02|                  0.04|                0.11|                  0.11|
|Encinacorba hillside |           40|                0.03|                 -0.05|                0.10|                  0.08|
|Encinacorba hillside |           75|                0.02|                 -0.04|                0.10|                  0.08|
|Encinacorba hillside |          100|               -0.01|                 -0.05|                0.09|                  0.08|
|Encinacorba scenery  |           40|                0.18|                  0.14|                0.18|                  0.15|
|Encinacorba scenery  |           75|                0.16|                  0.13|                0.17|                  0.14|
|Encinacorba scenery  |          100|                0.15|                  0.13|                0.17|                  0.14|
|Quinces              |           40|               -1.11|                 -1.10|                1.11|                  1.10|
|Quinces              |           75|               -1.17|                 -1.08|                1.17|                  1.08|
|Quinces              |          100|               -1.19|                  0.01|                1.19|                  0.06|

## detection

|Site                 | Altitude (m)|Class       |  n| Both| Day only| Night only| Neither|p      |p (BH)   |p (Bonf.) |Bonf. attainable |
|:--------------------|------------:|:-----------|--:|----:|--------:|----------:|-------:|:------|:--------|:---------|:----------------|
|Alfred               |           75|Dense treed |  7|    0|        0|          7|       0|0.016  |0.059    |0.297     |no               |
|Alfred               |           75|Open treed  | 36|   16|        0|         20|       0|<0.001 |<0.001** |<0.001    |yes              |
|Alfred               |           75|Shrub       | 10|    4|        0|          6|       0|0.031  |0.099    |0.594     |no               |
|Alfred               |          100|Dense treed |  7|    4|        0|          3|       0|0.250  |0.475    |1.000     |no               |
|Alfred               |          100|Open treed  | 36|   27|        0|          9|       0|0.004  |0.019*   |0.074     |no               |
|Alfred               |          100|Shrub       | 10|    9|        0|          1|       0|1.000  |1.000    |1.000     |no               |
|Alfred LOff          |          100|Dense treed |  7|    6|        0|          1|       0|1.000  |1.000    |1.000     |no               |
|Alfred LOff          |          100|Open treed  | 36|   35|        0|          1|       0|1.000  |1.000    |1.000     |no               |
|Alfred LOff          |          100|Shrub       | 10|    9|        0|          1|       0|1.000  |1.000    |1.000     |no               |
|Encinacorba hillside |          100|Open treed  | 43|   38|        0|          5|       0|0.062  |0.148    |1.000     |no               |
|Encinacorba scenery  |          100|Dense treed | 26|   25|        0|          1|       0|1.000  |1.000    |1.000     |no               |
|Encinacorba scenery  |          100|Open treed  | 37|   36|        0|          1|       0|1.000  |1.000    |1.000     |no               |
|Quinces              |           40|Road        | 19|   14|        5|          0|       0|0.062  |0.148    |1.000     |no               |
|Quinces              |           40|Shrub       |  8|    7|        1|          0|       0|1.000  |1.000    |1.000     |no               |
|Quinces              |           75|Dense treed | 15|    1|        1|         12|       1|0.003  |0.019*   |0.065     |yes              |
|Quinces              |           75|Road        | 19|   13|        5|          1|       0|0.219  |0.462    |1.000     |no               |
|Quinces              |           75|Shrub       |  8|    6|        0|          2|       0|0.500  |0.792    |1.000     |no               |
|Quinces              |          100|Dense treed | 15|    2|        0|         13|       0|<0.001 |0.002**  |0.005     |yes              |
|Quinces              |          100|Road        | 19|   17|        0|          2|       0|0.500  |0.792    |1.000     |no               |

## test_families

|Family                          | Tests| Sig. (Bonf.)| Sig. (BH)| Night > day (BH)| Day > night (BH)|
|:-------------------------------|-----:|------------:|---------:|----------------:|----------------:|
|detection (n_pnts_last > 0)     |    19|            2|         4|               NA|               NA|
|magnitude: intensity_avg        |    37|           12|        15|               14|                1|
|magnitude: prop_last_incoherent |    23|            6|        13|                2|               11|
|magnitude: rmse_last            |    37|           11|        19|                7|               12|

## magnitude_overview

|Site                 | Altitude (m)|Class       |Δ Mean intensity |Δ Proportion of incoherent last returns |Δ Last-return RMSE (m) |
|:--------------------|------------:|:-----------|:----------------|:---------------------------------------|:----------------------|
|Alfred               |           40|Dense treed |4.35             |0.11                                    |0.027                  |
|Alfred               |           40|Open treed  |4.54**           |0.08                                    |-0.006                 |
|Alfred               |           40|Shrub       |-0.14            |0.29**                                  |0.082*                 |
|Alfred               |           75|Dense treed |–                |–                                       |–                      |
|Alfred               |           75|Open treed  |4.40**           |0.14                                    |-0.001                 |
|Alfred               |           75|Shrub       |-4.65            |0.38                                    |0.101                  |
|Alfred               |          100|Dense treed |1.13             |0.93                                    |5.463                  |
|Alfred               |          100|Open treed  |-1.34            |0.96**                                  |4.489**                |
|Alfred               |          100|Shrub       |-0.63            |0.42                                    |5.652*                 |
|Alfred LOff          |          100|Dense treed |-0.38            |–                                       |-0.003                 |
|Alfred LOff          |          100|Open treed  |0.70             |-0.01                                   |0.000                  |
|Alfred LOff          |          100|Shrub       |0.77             |0.00                                    |-0.003                 |
|Encinacorba hillside |           40|Dense treed |-0.60            |–                                       |0.077                  |
|Encinacorba hillside |           40|Open treed  |4.86**           |-0.08*                                  |-0.023**               |
|Encinacorba hillside |           40|Road        |4.89**           |–                                       |0.031*                 |
|Encinacorba hillside |           75|Dense treed |-0.10            |–                                       |0.086                  |
|Encinacorba hillside |           75|Open treed  |5.38**           |-0.09*                                  |-0.021**               |
|Encinacorba hillside |           75|Road        |6.10**           |–                                       |0.032*                 |
|Encinacorba hillside |          100|Dense treed |3.38             |–                                       |0.037                  |
|Encinacorba hillside |          100|Open treed  |5.66**           |-0.10*                                  |-0.013*                |
|Encinacorba hillside |          100|Road        |6.51**           |–                                       |0.021**                |
|Encinacorba scenery  |           40|Dense treed |2.28             |-0.15*                                  |-0.034**               |
|Encinacorba scenery  |           40|Open treed  |6.03**           |-0.28**                                 |-0.047**               |
|Encinacorba scenery  |           40|Road        |7.95             |-0.12                                   |-0.042                 |
|Encinacorba scenery  |           75|Dense treed |-0.06            |-0.08*                                  |-0.017*                |
|Encinacorba scenery  |           75|Open treed  |5.77**           |-0.14**                                 |-0.027**               |
|Encinacorba scenery  |           75|Road        |4.31             |–                                       |-0.035                 |
|Encinacorba scenery  |          100|Dense treed |2.75             |-0.18*                                  |-0.024*                |
|Encinacorba scenery  |          100|Open treed  |6.10**           |-0.19**                                 |-0.032**               |
|Encinacorba scenery  |          100|Road        |3.94             |–                                       |-0.029                 |
|Quinces              |           40|Dense treed |0.25             |–                                       |0.022**                |
|Quinces              |           40|Road        |0.90*            |–                                       |-0.005                 |
|Quinces              |           40|Shrub       |5.92*            |–                                       |0.001                  |
|Quinces              |           75|Dense treed |–                |–                                       |–                      |
|Quinces              |           75|Road        |-0.85**          |–                                       |-0.066**               |
|Quinces              |           75|Shrub       |1.59             |–                                       |-0.073                 |
|Quinces              |          100|Dense treed |0.31             |-0.75                                   |-0.880                 |
|Quinces              |          100|Road        |0.53             |-1.00**                                 |-1.164**               |
|Quinces              |          100|Shrub       |9.69*            |-0.93*                                  |-1.095*                |

## magnitude_intensity_avg

|Site                 | Altitude (m)|Class       | n pairs| n non-zero| Median day| Median night|  HL Δ|   V|p      |p (BH)   |p (Bonf.) |Method         |
|:--------------------|------------:|:-----------|-------:|----------:|----------:|------------:|-----:|---:|:------|:--------|:---------|:--------------|
|Alfred               |           40|Dense treed |       6|          6|      12.60|        18.19|  4.35|  16|0.313  |0.482    |1.000     |exact          |
|Alfred               |           40|Open treed  |      36|         36|      24.25|        28.65|  4.54| 626|<0.001 |<0.001** |<0.001    |exact          |
|Alfred               |           40|Shrub       |      10|         10|      21.67|        23.14| -0.14|  26|0.922  |1.000    |1.000     |exact          |
|Alfred               |           75|Dense treed |       0|          0|         NA|           NA|    NA|  NA|–      |–        |–         |–              |
|Alfred               |           75|Open treed  |      16|         16|      22.92|        27.25|  4.40| 130|<0.001 |0.002**  |0.016     |exact          |
|Alfred               |           75|Shrub       |       4|          4|      17.10|        12.89| -4.65|   1|0.250  |0.420    |1.000     |exact          |
|Alfred               |          100|Dense treed |       4|          4|      16.00|        17.42|  1.13|   7|0.625  |0.797    |1.000     |exact          |
|Alfred               |          100|Open treed  |      27|         27|      26.09|        26.19| -1.34| 145|0.301  |0.482    |1.000     |exact          |
|Alfred               |          100|Shrub       |       9|          9|      20.19|        17.00| -0.63|  21|0.910  |1.000    |1.000     |exact          |
|Alfred LOff          |          100|Dense treed |       6|          6|      14.03|        12.21| -0.38|   9|0.844  |0.976    |1.000     |exact          |
|Alfred LOff          |          100|Open treed  |      35|         35|      17.64|        17.57|  0.70| 412|0.115  |0.212    |1.000     |exact          |
|Alfred LOff          |          100|Shrub       |       9|          9|      12.00|        13.40|  0.77|  37|0.097  |0.189    |1.000     |normal approx. |
|Encinacorba hillside |           40|Dense treed |       6|          6|      25.18|        24.27| -0.60|   9|0.844  |0.976    |1.000     |exact          |
|Encinacorba hillside |           40|Open treed  |      43|         43|      20.18|        24.75|  4.86| 946|<0.001 |<0.001** |<0.001    |exact          |
|Encinacorba hillside |           40|Road        |      11|         11|      18.43|        23.27|  4.89|  66|<0.001 |0.003**  |0.036     |exact          |
|Encinacorba hillside |           75|Dense treed |       6|          6|      22.45|        22.95| -0.10|  10|1.000  |1.000    |1.000     |exact          |
|Encinacorba hillside |           75|Open treed  |      43|         43|      19.46|        24.91|  5.38| 946|<0.001 |<0.001** |<0.001    |normal approx. |
|Encinacorba hillside |           75|Road        |      11|         11|      18.54|        24.73|  6.10|  66|<0.001 |0.003**  |0.036     |exact          |
|Encinacorba hillside |          100|Dense treed |       6|          6|      14.81|        24.29|  3.38|  15|0.438  |0.648    |1.000     |exact          |
|Encinacorba hillside |          100|Open treed  |      38|         38|      19.65|        24.64|  5.66| 741|<0.001 |<0.001** |<0.001    |exact          |
|Encinacorba hillside |          100|Road        |      11|         11|      19.64|        25.85|  6.51|  66|<0.001 |0.003**  |0.036     |exact          |
|Encinacorba scenery  |           40|Dense treed |      26|         26|      27.64|        28.84|  2.28| 259|0.033  |0.074    |1.000     |exact          |
|Encinacorba scenery  |           40|Open treed  |      37|         37|      20.31|        26.73|  6.03| 700|<0.001 |<0.001** |<0.001    |exact          |
|Encinacorba scenery  |           40|Road        |       2|          2|      18.16|        26.11|  7.95|   3|0.500  |0.661    |1.000     |exact          |
|Encinacorba scenery  |           75|Dense treed |      26|         26|      26.14|        27.13| -0.06| 174|0.980  |1.000    |1.000     |exact          |
|Encinacorba scenery  |           75|Open treed  |      37|         37|      20.47|        26.00|  5.77| 702|<0.001 |<0.001** |<0.001    |exact          |
|Encinacorba scenery  |           75|Road        |       2|          2|      18.67|        22.98|  4.31|   3|0.500  |0.661    |1.000     |exact          |
|Encinacorba scenery  |          100|Dense treed |      25|         25|      22.75|        27.10|  2.75| 241|0.034  |0.074    |1.000     |exact          |
|Encinacorba scenery  |          100|Open treed  |      36|         36|      20.39|        26.04|  6.10| 664|<0.001 |<0.001** |<0.001    |normal approx. |
|Encinacorba scenery  |          100|Road        |       2|          2|      19.04|        22.98|  3.94|   3|0.500  |0.661    |1.000     |exact          |
|Quinces              |           40|Dense treed |      15|         15|      14.29|        14.40|  0.25|  67|0.720  |0.888    |1.000     |exact          |
|Quinces              |           40|Road        |      14|         14|       6.04|         7.00|  0.90|  94|0.007  |0.019*   |0.248     |exact          |
|Quinces              |           40|Shrub       |       7|          7|      20.67|        25.80|  5.92|  28|0.016  |0.039*   |0.578     |exact          |
|Quinces              |           75|Dense treed |       1|          1|      13.92|        12.50|    NA|  NA|–      |–        |–         |–              |
|Quinces              |           75|Road        |      13|         13|       6.80|         5.79| -0.85|   0|<0.001 |0.001**  |0.009     |exact          |
|Quinces              |           75|Shrub       |       6|          6|      19.85|        22.49|  1.59|  19|0.094  |0.189    |1.000     |exact          |
|Quinces              |          100|Dense treed |       2|          2|      11.69|        12.00|  0.31|   2|1.000  |1.000    |1.000     |exact          |
|Quinces              |          100|Road        |      17|         16|       7.50|         7.86|  0.53|  97|0.141  |0.248    |1.000     |normal approx. |
|Quinces              |          100|Shrub       |       8|          8|      20.43|        29.92|  9.69|  36|0.008  |0.021*   |0.289     |exact          |

## magnitude_prop_last_incoherent

|Site                 | Altitude (m)|Class       | n pairs| n non-zero| Median day| Median night|  HL Δ|     V|p      |p (BH)   |p (Bonf.) |Method         |
|:--------------------|------------:|:-----------|-------:|----------:|----------:|------------:|-----:|-----:|:------|:--------|:---------|:--------------|
|Alfred               |           40|Dense treed |       6|          4|       0.14|         0.16|  0.11|   7.0|0.584  |0.639    |1.000     |normal approx. |
|Alfred               |           40|Open treed  |      36|         10|       0.00|         0.11|  0.08|  45.0|0.083  |0.127    |1.000     |normal approx. |
|Alfred               |           40|Shrub       |      10|         10|       0.17|         0.51|  0.29|  55.0|0.002  |0.007**  |0.045     |exact          |
|Alfred               |           75|Dense treed |       0|          0|         NA|           NA|    NA|    NA|–      |–        |–         |–              |
|Alfred               |           75|Open treed  |      16|          4|       0.00|         0.18|  0.14|  10.0|0.100  |0.144    |1.000     |normal approx. |
|Alfred               |           75|Shrub       |       4|          4|       0.24|         0.72|  0.38|  10.0|0.125  |0.169    |1.000     |exact          |
|Alfred               |          100|Dense treed |       4|          2|       0.54|         1.00|  0.93|   3.0|0.371  |0.449    |1.000     |normal approx. |
|Alfred               |          100|Open treed  |      27|         15|       0.18|         1.00|  0.96| 120.0|<0.001 |0.002**  |0.012     |normal approx. |
|Alfred               |          100|Shrub       |       9|          6|       0.71|         1.00|  0.42|  21.0|0.036  |0.058    |0.817     |normal approx. |
|Alfred LOff          |          100|Dense treed |       6|          1|       0.00|         0.00|    NA|    NA|–      |–        |–         |–              |
|Alfred LOff          |          100|Open treed  |      35|          5|       0.00|         0.00| -0.01|   7.0|1.000  |1.000    |1.000     |normal approx. |
|Alfred LOff          |          100|Shrub       |       9|          5|       0.00|         0.06|  0.00|   8.0|1.000  |1.000    |1.000     |normal approx. |
|Encinacorba hillside |           40|Dense treed |       6|          0|       1.00|         1.00|    NA|    NA|–      |–        |–         |–              |
|Encinacorba hillside |           40|Open treed  |      43|         21|       0.00|         0.00| -0.08|  39.0|0.008  |0.024*   |0.189     |normal approx. |
|Encinacorba hillside |           40|Road        |      11|          0|       0.00|         0.00|    NA|    NA|–      |–        |–         |–              |
|Encinacorba hillside |           75|Dense treed |       6|          0|       1.00|         1.00|    NA|    NA|–      |–        |–         |–              |
|Encinacorba hillside |           75|Open treed  |      43|         22|       0.07|         0.00| -0.09|  57.0|0.025  |0.050*   |0.575     |normal approx. |
|Encinacorba hillside |           75|Road        |      11|          0|       0.00|         0.00|    NA|    NA|–      |–        |–         |–              |
|Encinacorba hillside |          100|Dense treed |       6|          0|       1.00|         1.00|    NA|    NA|–      |–        |–         |–              |
|Encinacorba hillside |          100|Open treed  |      38|         16|       0.00|         0.00| -0.10|  25.0|0.028  |0.050*   |0.641     |normal approx. |
|Encinacorba hillside |          100|Road        |      11|          0|       0.00|         0.00|    NA|    NA|–      |–        |–         |–              |
|Encinacorba scenery  |           40|Dense treed |      26|         16|       0.22|         0.07| -0.15|  10.5|0.003  |0.010*   |0.073     |normal approx. |
|Encinacorba scenery  |           40|Open treed  |      37|         36|       0.46|         0.15| -0.28|   6.0|<0.001 |<0.001** |<0.001    |normal approx. |
|Encinacorba scenery  |           40|Road        |       2|          2|       0.12|         0.00| -0.12|   0.0|0.500  |0.575    |1.000     |exact          |
|Encinacorba scenery  |           75|Dense treed |      26|         14|       0.08|         0.00| -0.08|  17.0|0.028  |0.050*   |0.644     |normal approx. |
|Encinacorba scenery  |           75|Open treed  |      37|         29|       0.27|         0.11| -0.14|  16.0|<0.001 |<0.001** |<0.001    |normal approx. |
|Encinacorba scenery  |           75|Road        |       2|          1|       0.04|         0.00|    NA|    NA|–      |–        |–         |–              |
|Encinacorba scenery  |          100|Dense treed |      25|         13|       0.08|         0.00| -0.18|  13.0|0.025  |0.050*   |0.582     |normal approx. |
|Encinacorba scenery  |          100|Open treed  |      36|         29|       0.32|         0.10| -0.19|  57.0|<0.001 |0.002**  |0.012     |normal approx. |
|Encinacorba scenery  |          100|Road        |       2|          1|       0.04|         0.00|    NA|    NA|–      |–        |–         |–              |
|Quinces              |           40|Dense treed |      15|          0|       1.00|         1.00|    NA|    NA|–      |–        |–         |–              |
|Quinces              |           40|Road        |      14|          0|       1.00|         1.00|    NA|    NA|–      |–        |–         |–              |
|Quinces              |           40|Shrub       |       7|          0|       1.00|         1.00|    NA|    NA|–      |–        |–         |–              |
|Quinces              |           75|Dense treed |       1|          0|       1.00|         1.00|    NA|    NA|–      |–        |–         |–              |
|Quinces              |           75|Road        |      13|          0|       1.00|         1.00|    NA|    NA|–      |–        |–         |–              |
|Quinces              |           75|Shrub       |       6|          0|       1.00|         1.00|    NA|    NA|–      |–        |–         |–              |
|Quinces              |          100|Dense treed |       2|          2|       1.00|         0.25| -0.75|   0.0|0.346  |0.442    |1.000     |normal approx. |
|Quinces              |          100|Road        |      17|         17|       1.00|         0.00| -1.00|   0.0|<0.001 |<0.001** |<0.001    |normal approx. |
|Quinces              |          100|Shrub       |       8|          7|       1.00|         0.07| -0.93|   0.0|0.022  |0.050*   |0.495     |normal approx. |

## magnitude_rmse_last

|Site                 | Altitude (m)|Class       | n pairs| n non-zero| Median day| Median night|   HL Δ|   V|p      |p (BH)   |p (Bonf.) |Method |
|:--------------------|------------:|:-----------|-------:|----------:|----------:|------------:|------:|---:|:------|:--------|:---------|:------|
|Alfred               |           40|Dense treed |       6|          6|      0.119|        0.146|  0.027|  14|0.563  |0.631    |1.000     |exact  |
|Alfred               |           40|Open treed  |      36|         36|      0.094|        0.149| -0.006| 294|0.550  |0.631    |1.000     |exact  |
|Alfred               |           40|Shrub       |      10|         10|      0.152|        0.224|  0.082|  55|0.002  |0.006*   |0.072     |exact  |
|Alfred               |           75|Dense treed |       0|          0|         NA|           NA|     NA|  NA|–      |–        |–         |–      |
|Alfred               |           75|Open treed  |      16|         16|      0.107|        0.149| -0.001|  64|0.860  |0.884    |1.000     |exact  |
|Alfred               |           75|Shrub       |       4|          4|      0.206|        0.302|  0.101|  10|0.125  |0.185    |1.000     |exact  |
|Alfred               |          100|Dense treed |       4|          4|      0.281|        5.892|  5.463|  10|0.125  |0.185    |1.000     |exact  |
|Alfred               |          100|Open treed  |      27|         27|      0.144|        5.403|  4.489| 378|<0.001 |<0.001** |<0.001    |exact  |
|Alfred               |          100|Shrub       |       9|          9|      0.354|        6.025|  5.652|  45|0.004  |0.010*   |0.145     |exact  |
|Alfred LOff          |          100|Dense treed |       6|          6|      0.079|        0.071| -0.003|   6|0.438  |0.597    |1.000     |exact  |
|Alfred LOff          |          100|Open treed  |      35|         35|      0.115|        0.115|  0.000| 303|0.852  |0.884    |1.000     |exact  |
|Alfred LOff          |          100|Shrub       |       9|          9|      0.113|        0.112| -0.003|  16|0.496  |0.597    |1.000     |exact  |
|Encinacorba hillside |           40|Dense treed |       6|          6|      2.567|        2.628|  0.077|  21|0.031  |0.053    |1.000     |exact  |
|Encinacorba hillside |           40|Open treed  |      43|         43|      0.106|        0.074| -0.023| 184|<0.001 |0.001**  |0.011     |exact  |
|Encinacorba hillside |           40|Road        |      11|         11|      0.037|        0.067|  0.031|  61|0.010  |0.020*   |0.361     |exact  |
|Encinacorba hillside |           75|Dense treed |       6|          6|      2.499|        2.584|  0.086|  21|0.031  |0.053    |1.000     |exact  |
|Encinacorba hillside |           75|Open treed  |      43|         43|      0.109|        0.079| -0.021| 202|<0.001 |0.003**  |0.028     |exact  |
|Encinacorba hillside |           75|Road        |      11|         11|      0.030|        0.062|  0.032|  64|0.003  |0.008*   |0.108     |exact  |
|Encinacorba hillside |          100|Dense treed |       6|          6|      2.533|        2.575|  0.037|  20|0.063  |0.101    |1.000     |exact  |
|Encinacorba hillside |          100|Open treed  |      38|         38|      0.095|        0.088| -0.013| 207|0.017  |0.033*   |0.624     |exact  |
|Encinacorba hillside |          100|Road        |      11|         11|      0.039|        0.067|  0.021|  66|<0.001 |0.003**  |0.036     |exact  |
|Encinacorba scenery  |           40|Dense treed |      26|         26|      0.166|        0.140| -0.034|  49|<0.001 |0.003**  |0.028     |exact  |
|Encinacorba scenery  |           40|Open treed  |      37|         37|      0.202|        0.158| -0.047|   0|<0.001 |<0.001** |<0.001    |exact  |
|Encinacorba scenery  |           40|Road        |       2|          2|      0.151|        0.108| -0.042|   0|0.500  |0.597    |1.000     |exact  |
|Encinacorba scenery  |           75|Dense treed |      26|         26|      0.149|        0.125| -0.017|  67|0.005  |0.012*   |0.174     |exact  |
|Encinacorba scenery  |           75|Open treed  |      37|         37|      0.173|        0.150| -0.027|   5|<0.001 |<0.001** |<0.001    |exact  |
|Encinacorba scenery  |           75|Road        |       2|          2|      0.127|        0.091| -0.035|   0|0.500  |0.597    |1.000     |exact  |
|Encinacorba scenery  |          100|Dense treed |      25|         25|      0.145|        0.124| -0.024|  62|0.006  |0.013*   |0.206     |exact  |
|Encinacorba scenery  |          100|Open treed  |      36|         36|      0.188|        0.150| -0.032|  47|<0.001 |<0.001** |<0.001    |exact  |
|Encinacorba scenery  |          100|Road        |       2|          2|      0.121|        0.091| -0.029|   0|0.500  |0.597    |1.000     |exact  |
|Quinces              |           40|Dense treed |      15|         15|      0.925|        0.957|  0.022| 119|<0.001 |<0.001** |0.005     |exact  |
|Quinces              |           40|Road        |      14|         14|      1.127|        1.124| -0.005|  44|0.626  |0.681    |1.000     |exact  |
|Quinces              |           40|Shrub       |       7|          7|      1.168|        1.171|  0.001|  15|0.937  |0.937    |1.000     |exact  |
|Quinces              |           75|Dense treed |       1|          1|      1.013|        0.993|     NA|  NA|–      |–        |–         |–      |
|Quinces              |           75|Road        |      13|         13|      1.181|        1.111| -0.066|   0|<0.001 |0.001**  |0.009     |exact  |
|Quinces              |           75|Shrub       |       6|          6|      1.239|        1.113| -0.073|   0|0.031  |0.053    |1.000     |exact  |
|Quinces              |          100|Dense treed |       2|          2|      1.030|        0.151| -0.880|   0|0.500  |0.597    |1.000     |exact  |
|Quinces              |          100|Road        |      17|         17|      1.193|        0.032| -1.164|   0|<0.001 |<0.001** |<0.001    |exact  |
|Quinces              |          100|Shrub       |       8|          8|      1.233|        0.162| -1.095|   0|0.008  |0.017*   |0.289     |exact  |

