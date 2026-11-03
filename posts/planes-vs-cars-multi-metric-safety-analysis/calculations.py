"""
Transportation Safety: Multi-Metric Comparison
Data sources: IATA 2025, WHO 2025, NTSB 2013, USAFacts/BTS 2023, NSC 2024
"""

print("=" * 72)
print("TRANSPORTATION RISK ANALYSIS: PLANES vs CARS")
print("All calculations shown. All data sourced from public records.")
print("=" * 72)

# =========================================================================
# SECTION 1: RAW FLEET DATA (Global 2025)
# =========================================================================
print("\n--- SECTION 1: Global Fleet Inventory (2025) ---\n")

cars_global = 1_644_000_000       # Source: OICA / industry estimates
planes_commercial = 30_300        # Source: IATA 2025 Safety Report
planes_ga_us = 200_000            # Source: FAA registry (US general aviation)
planes_us_total = 220_000         # All US civil aviation (commercial + GA)

car_deaths_global = 1_190_000     # Source: WHO 2025
plane_deaths_commercial_2025 = 394  # Source: IATA 2025 (onboard fatalities)
plane_fatal_accidents_2025 = 8    # Source: IATA 2025
plane_total_accidents_2025 = 51   # Source: IATA 2025
total_flights_2025 = 38_700_000   # Source: IATA 2025

print(f"Global passenger vehicles:       {cars_global:>15,}")
print(f"Global commercial aircraft:      {planes_commercial:>15,}")
print(f"US general aviation aircraft:    {planes_ga_us:>15,}")
print(f"Ratio (cars per plane):          {cars_global / planes_commercial:>15,.0f}")
print(f"")
print(f"Global road deaths (annual):     {car_deaths_global:>15,}")
print(f"Commercial plane deaths (2025):  {plane_deaths_commercial_2025:>15,}")
print(f"Commercial flights (2025):       {total_flights_2025:>15,}")

# =========================================================================
# SECTION 2: UNIT RISK (Deaths per vehicle per year)
# =========================================================================
print("\n--- SECTION 2: Unit Risk (Deaths per Vehicle per Year) ---\n")

risk_per_car = car_deaths_global / cars_global
risk_per_plane = plane_deaths_commercial_2025 / planes_commercial

print(f"Deaths per car per year:")
print(f"  {car_deaths_global:,} / {cars_global:,} = {risk_per_car:.6f}")
print(f"")
print(f"Deaths per commercial plane per year:")
print(f"  {plane_deaths_commercial_2025:,} / {planes_commercial:,} = {risk_per_plane:.6f}")
print(f"")
ratio_unit = risk_per_plane / risk_per_car
print(f"Ratio: {risk_per_plane:.6f} / {risk_per_car:.6f} = {ratio_unit:.1f}x")
print(f"")
print(f"RESULT: A single commercial plane is associated with")
print(f"        {ratio_unit:.1f}x more deaths per year than a single car.")

# =========================================================================
# SECTION 3: PER-MILE COMPARISON (US 2023)
# =========================================================================
print("\n--- SECTION 3: Per-Mile Comparison (US 2023) ---\n")

car_passenger_miles_us = 3_200_000_000_000   # 3.2 trillion, BTS
plane_passenger_miles_us = 773_000_000_000   # 773 billion, BTS
car_deaths_us = 43_000                       # NHTSA 2022/2023
plane_deaths_us_2023 = 20                    # USAFacts (2023)

car_deaths_per_100m_miles = (car_deaths_us / car_passenger_miles_us) * 100_000_000
plane_deaths_per_100m_miles = (plane_deaths_us_2023 / plane_passenger_miles_us) * 100_000_000

print(f"Car deaths per 100M passenger miles:")
print(f"  ({car_deaths_us:,} / {car_passenger_miles_us:,}) * 100,000,000")
print(f"  = {car_deaths_per_100m_miles:.4f}")
print(f"")
print(f"Plane deaths per 100M passenger miles:")
print(f"  ({plane_deaths_us_2023:,} / {plane_passenger_miles_us:,}) * 100,000,000")
print(f"  = {plane_deaths_per_100m_miles:.6f}")
print(f"")
ratio_mile = car_deaths_per_100m_miles / plane_deaths_per_100m_miles
print(f"Ratio: {car_deaths_per_100m_miles:.4f} / {plane_deaths_per_100m_miles:.6f} = {ratio_mile:.0f}x")
print(f"")
print(f"RESULT: Per mile traveled, cars are {ratio_mile:.0f}x more dangerous.")
print(f"        This is the standard metric used in safety reports.")

# =========================================================================
# SECTION 4: SPEED BIAS IN PER-MILE METRIC
# =========================================================================
print("\n--- SECTION 4: Speed Bias in the Per-Mile Metric ---\n")

car_avg_speed_mph = 45     # blended city/highway average
plane_avg_speed_mph = 525  # cruise speed

speed_ratio = plane_avg_speed_mph / car_avg_speed_mph

hours_car_1b_miles = 1_000_000_000 / car_avg_speed_mph
hours_plane_1b_miles = 1_000_000_000 / plane_avg_speed_mph

print(f"Average car speed:   {car_avg_speed_mph} mph")
print(f"Average plane speed: {plane_avg_speed_mph} mph")
print(f"Speed ratio:         {speed_ratio:.1f}x")
print(f"")
print(f"Hours to cover 1 billion miles:")
print(f"  Car:   1,000,000,000 / {car_avg_speed_mph} = {hours_car_1b_miles:,.0f} hours")
print(f"  Plane: 1,000,000,000 / {plane_avg_speed_mph} = {hours_plane_1b_miles:,.0f} hours")
print(f"")
print(f"A car must spend {speed_ratio:.1f}x more TIME to cover the same distance.")
print(f"The per-mile metric divides deaths by distance, which inherently")
print(f"dilutes the rate for faster vehicles by a factor of ~{speed_ratio:.0f}.")

# =========================================================================
# SECTION 5: PER-HOUR COMPARISON (Exposure Time)
# =========================================================================
print("\n--- SECTION 5: Per-Hour Comparison (Exposure Time) ---\n")

# US data
car_fatality_per_million_hours = 0.33     # Derived: ~43,000 deaths / ~130B hours
plane_commercial_per_million_hours = 0.037  # IATA-derived
ga_fatal_per_million_hours = 9.5          # NTSB general aviation

print(f"Deaths per million hours of exposure:")
print(f"  Cars (US):                   {car_fatality_per_million_hours}")
print(f"  Commercial planes (global):  {plane_commercial_per_million_hours}")
print(f"  General aviation (US):       {ga_fatal_per_million_hours}")
print(f"")

ratio_hour_commercial = car_fatality_per_million_hours / plane_commercial_per_million_hours
ratio_hour_ga = ga_fatal_per_million_hours / car_fatality_per_million_hours

print(f"Per hour, cars are {ratio_hour_commercial:.0f}x more dangerous than commercial planes.")
print(f"Per hour, general aviation is {ratio_hour_ga:.0f}x more dangerous than cars.")

# =========================================================================
# SECTION 6: ACCIDENT FREQUENCY AND SURVIVAL RATES
# =========================================================================
print("\n--- SECTION 6: Accident Frequency and Survival ---\n")

car_accidents_us = 6_000_000
car_deaths_in_accidents = 43_000
car_fatality_rate_per_accident = car_deaths_in_accidents / car_accidents_us * 100

print(f"Cars (US annual):")
print(f"  Total accidents:     {car_accidents_us:,}")
print(f"  Deaths:              {car_deaths_in_accidents:,}")
print(f"  Fatality rate:       {car_deaths_in_accidents:,} / {car_accidents_us:,} = {car_fatality_rate_per_accident:.2f}%")
print(f"  Survival rate:       {100 - car_fatality_rate_per_accident:.2f}%")
print(f"")

plane_fatal_rate_of_accidents = plane_fatal_accidents_2025 / plane_total_accidents_2025 * 100
print(f"Commercial planes (global 2025):")
print(f"  Total accidents:     {plane_total_accidents_2025}")
print(f"  Fatal accidents:     {plane_fatal_accidents_2025}")
print(f"  % of accidents that are fatal: {plane_fatal_rate_of_accidents:.1f}%")
print(f"  Deaths:              {plane_deaths_commercial_2025}")
print(f"  Avg deaths per fatal accident: {plane_deaths_commercial_2025 / plane_fatal_accidents_2025:.1f}")

# =========================================================================
# SECTION 7: THE "SELECT GROUP" ANALYSIS
# =========================================================================
print("\n--- SECTION 7: Population Exposure (The 'Select Group') ---\n")

world_population = 8_000_000_000
total_air_passengers_2025 = 4_800_000_000  # IATA, ~4.7-4.8B
# Note: this counts passenger trips, not unique people.
# A frequent flyer taking 50 flights = 50 passengers counted

# Estimate unique flyers (industry estimates ~1.2B unique people fly/year)
unique_flyers_estimate = 1_200_000_000

pct_population_flies = unique_flyers_estimate / world_population * 100
pct_population_drives = 85  # rough estimate, most adults in motorized countries

print(f"World population:             {world_population:,}")
print(f"Total air passenger trips:    {total_air_passengers_2025:,}")
print(f"Estimated unique people who fly: {unique_flyers_estimate:,}")
print(f"% of world that flies:        {pct_population_flies:.0f}%")
print(f"% of world exposed to roads:  ~{pct_population_drives}%")
print(f"")

# Deaths per unique participant
car_death_rate_per_person = car_deaths_global / (world_population * pct_population_drives / 100)
plane_death_rate_per_person = plane_deaths_commercial_2025 / unique_flyers_estimate

print(f"Deaths per participant per year:")
print(f"  Cars:   {car_deaths_global:,} / {world_population * pct_population_drives / 100:,.0f} = {car_death_rate_per_person:.8f}")
print(f"  Planes: {plane_deaths_commercial_2025} / {unique_flyers_estimate:,} = {plane_death_rate_per_person:.8f}")
print(f"")
ratio_participant = car_death_rate_per_person / plane_death_rate_per_person
print(f"Per unique participant, cars are {ratio_participant:.1f}x more deadly.")
print(f"")
print(f"However: the 'select group' argument notes that the flying")
print(f"population is concentrated. {unique_flyers_estimate/1e9:.1f}B people absorb ALL the")
print(f"aviation risk, while {world_population * pct_population_drives / 100 / 1e9:.1f}B people spread the road risk.")

# =========================================================================
# SECTION 8: NTSB BREAKDOWN (US Civil Aviation 2013)
# =========================================================================
print("\n--- SECTION 8: US Aviation Fatality Breakdown (NTSB 2013) ---\n")

part121_accidents = 23
part121_fatal = 2
part121_deaths = 9

part135_accidents = 51
part135_fatal = 12
part135_deaths = 30

ga_accidents = 1224
ga_fatal = 222
ga_deaths = 390

total_aviation_deaths = part121_deaths + part135_deaths + ga_deaths
pct_commercial = part121_deaths / total_aviation_deaths * 100
pct_ga = ga_deaths / total_aviation_deaths * 100
pct_part135 = part135_deaths / total_aviation_deaths * 100

print(f"{'Segment':<30} {'Accidents':>10} {'Fatal':>8} {'Deaths':>8} {'% of Total':>10}")
print(f"{'-'*66}")
print(f"{'Part 121 (Airlines)':<30} {part121_accidents:>10} {part121_fatal:>8} {part121_deaths:>8} {pct_commercial:>9.1f}%")
print(f"{'Part 135 (Commuter/On-demand)':<30} {part135_accidents:>10} {part135_fatal:>8} {part135_deaths:>8} {pct_part135:>9.1f}%")
print(f"{'General Aviation':<30} {ga_accidents:>10} {ga_fatal:>8} {ga_deaths:>8} {pct_ga:>9.1f}%")
print(f"{'-'*66}")
print(f"{'TOTAL':<30} {part121_accidents+part135_accidents+ga_accidents:>10} {part121_fatal+part135_fatal+ga_fatal:>8} {total_aviation_deaths:>8} {'100.0%':>10}")
print(f"")
print(f"RESULT: {pct_ga:.0f}% of US aviation deaths come from general aviation,")
print(f"        not the commercial airlines that cite the safety statistics.")

# =========================================================================
# SECTION 9: HYPOTHETICAL EQUAL-VOLUME SCENARIO
# =========================================================================
print("\n--- SECTION 9: Hypothetical Equal-Volume Scenario ---\n")

boeing_737_capacity = 150
days_per_year = 365
equivalent_crashes = car_deaths_us / boeing_737_capacity

print(f"US car deaths per year:        {car_deaths_us:,}")
print(f"Boeing 737 capacity:           {boeing_737_capacity} passengers")
print(f"Equivalent 737 crashes needed: {car_deaths_us:,} / {boeing_737_capacity}")
print(f"                             = {equivalent_crashes:.0f} crashes per year")
print(f"                             = {equivalent_crashes / days_per_year:.1f} crashes per day")
print(f"")
print(f"To match the US car death toll, aviation would need to crash")
print(f"a fully loaded 737 roughly every {days_per_year * 24 / equivalent_crashes:.0f} hours, with no survivors.")
print(f"In reality, US commercial aviation had ZERO fatal accidents")
print(f"in multiple recent years.")

# =========================================================================
# SECTION 10: LIFETIME ODDS (NSC 2024)
# =========================================================================
print("\n--- SECTION 10: Lifetime Odds (NSC 2024 Data) ---\n")

lifetime_car = 101       # 1 in 101
lifetime_plane = None     # "Too few deaths to calculate"

print(f"Lifetime odds of dying (NSC 2024):")
print(f"  Motor vehicle crash:     1 in {lifetime_car}")
print(f"  Airplane passenger:      Too few deaths in 2024 to calculate")
print(f"  Motorcycle:              1 in 726")
print(f"  Pedestrian incident:     1 in 492")
print(f"")
print(f"Note: These odds reflect TOTAL EXPOSURE over a lifetime.")
print(f"Americans spend ~700 hours/year in cars vs ~20 hours/year flying.")
print(f"The exposure difference is {700/20:.0f}x, which is why plane deaths")
print(f"are 'too few to calculate' at the population level.")

# =========================================================================
# SUMMARY TABLE
# =========================================================================
print("\n" + "=" * 72)
print("SUMMARY: WHICH METRIC FAVORS WHICH MODE?")
print("=" * 72)
print(f"")
print(f"{'Metric':<40} {'Safer Mode':<15} {'Factor':>10}")
print(f"{'-'*65}")
print(f"{'Deaths per billion passenger miles':<40} {'Plane':<15} {'~519x':>10}")
print(f"{'Deaths per million hours (commercial)':<40} {'Plane':<15} {f'~{ratio_hour_commercial:.0f}x':>10}")
print(f"{'Deaths per vehicle per year':<40} {'Car':<15} {f'~{ratio_unit:.0f}x':>10}")
print(f"{'Deaths per million hours (gen. aviation)':<40} {'Car':<15} {f'~{ratio_hour_ga:.0f}x':>10}")
print(f"{'% of accidents that are fatal':<40} {'Car (lower)':<15} {f'{plane_fatal_rate_of_accidents:.0f}% vs {car_fatality_rate_per_accident:.1f}%':>10}")
print(f"{'Lifetime odds (total exposure)':<40} {'Plane':<15} {'>>35x':>10}")
print(f"{'Deaths per participant per year':<40} {'Plane':<15} {f'~{ratio_participant:.0f}x':>10}")
print(f"")
print(f"CONCLUSION: The answer depends entirely on which metric you use.")
print(f"Per mile and per participant, planes win. Per vehicle, per hour")
print(f"(general aviation), and per accident severity, cars win.")
print(f"No single number tells the complete story.")
