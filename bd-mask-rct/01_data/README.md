COVID-19 Face Mask Study - Data
-----------------------------------------------

* [Introduction](#introduction)
* [File Structure](#file-structure)
* [Data](#data)
    * [Surveillance](#surveillance)
    * [Baseline Household Visit](#baseline-household-visit)
    * [Phone Survey](#phone-survey)
    * [In-Person Followup Visit](#in-person-followup-visit)
    * [Endline Blood Collection](#endline-blood-collection)
    * [Pilot](#pilot)

Introduction
------------
The data used in our analysis was collected by Innovations for Poverty Action (IPA) through SurveyCTO. The data can be organized into seven broad categories, outlined in [Data](#data).

File Structure
------------
Each of the folders is organized into ``00_raw`` and ``01_clean``.

``00_raw`` contains all raw data.

``00_clean`` contains any maniuplated and cleaned data.

Data
------------
### Surveillance
This data was collected prior-to, during, and after the active intervention. Enumerators stationed at various points throughout the village discreetly recorded mask wearing and social distancing behavior of all passing individuals.
The data is at the union-date-location level.

Enumerators surveilled individuals at the following locations in each village:
- Mosque
- Market
- Tea Stall
- Outside the main entrace of a restaurant
- Main road to enter the village

For each individual observed, they collected data on:
- Mask Wearing Behavior
- Mask Color (if individual was wearing a mask distributed during our intervention)
- If the individual was social distancing
- The gender of the individual


### Baseline Household Visit
This data was collected prior to the start of the intervention. Enumerators visited every household in treatment and control villages, and collected data on the following characteristics:
- Number of Adults Living in the Household;
- The name, age, and gender of each household member;
- Symptoms each family member experienced in the past 7 days, including:
    - Fever;
    - Dry cough;
    - Wet cough;
    - Shortness of breath;
    - Sore throat;
    - Headache;
    - Diarrhea;
    - Fatigue;
    - Body aches;
    - Runny nose;
    - Loss of taste or smell.
 
This data is at the union-household level.

To de-identify individuals, we do not provide information on the upazila, union, or village of the households. We remove real names, and only provide age in 10-year age bins.

### Phone Survey
Following week 5 of the intervention, enumerators attempted to call each household in the treatment and control villages. The same phone surveys were also collected for some households following week 9 of the intervention. After finding low response rates in the week 9 surveys, our team switched to in-person visits for the remainder of households in week 9.
They collected information of the symptoms each family member experienced in the past 7 days and past 4 weeks, including
- Fever;
- Dry cough;
- Wet cough;
- Shortness of breath;
- Sore throat;
- Headache;
- Diarrhea;
- Fatigue;
- Body aches;
- Runny nose;
- Loss of taste or smell.

This data is at the union-household-week level, where week={week5, week9}.

### In-Person Followup Visit
Following week 9 of the intervention, enumerators attempted to visit every household. They collected information of the symptoms each family member experienced in the past 7 days and past 4 weeks, including
- Fever;
- Dry cough;
- Wet cough;
- Shortness of breath;
- Sore throat;
- Headache;
- Diarrhea;
- Fatigue;
- Body aches;
- Runny nose;
- Loss of taste or smell.

This data is at the union-household level.

### Endline Blood Collection
Our team identified every adult household member who had COVID-19 symptoms as defined by the WHO during the week 5 or week 9 surveys. Ths includes:
- Fever and Cough;
- Any three of the following: 
    - fever, 
    - cough, 
    - general weakness/fatigue, 
    - headache, 
    - muscle aches, 
    - sore throat, 
    - coryza [nasal congestion or runny nose], 
    - dyspnoea [shortness of breath or difficulty breathing], 
    - anorexia [loss of appetite]/nausea/vomiting, 
    - diarrhoea, 
    - altered mental status;
- Anosmia [loss of smell] and ageusia [loss of taste].

For every individual that had WHO-defined COVID symptoms in the week 5 or week 9 surveys, we visited their household following the end of the intervention and attempted to draw their blood.
This data is at the union-household-individual level.


### Pilot
Prior to the full rollout of the intervention, we ran two pilots in 10 villages each (these villages are seperate from the 600 chosen for the intervention). Enumerators stationed at various points throughout the villages discreetly recorded mask wearing and social distancing behavior of all passing individuals.

The data is at the union-date-location level.