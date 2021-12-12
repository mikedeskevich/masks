COVID-19 Face Mask Study
-----------------------------------------------

* [Introduction](#introduction)
* [Setup](#setup)
* [Notes](#notes)
* [Contact Us](#contact-us)
* [People](#people)

Introduction
------------

This repository provides the raw data and do-files to replicate the empirical analysis in "The Impact of Community Masking on COVID-19: A Cluster-Randomized Trial in Bangladesh".


Setup
------------
Follow the steps below to get the code running on your local machine.

### Prerequisites
The data cleaning and analysis for this project was completed in Stata-16 SE. Install the dependicies via ``02_code\installRequirements.do``.

The file paths are defined in ``02_code\00_preamble.do``. Change the ``main`` global prior to running.

### File Structure
The file structure of the project is as follows:

- `project`
    - `01_data` - All raw data and generated clean data as `.dta` files.
    - `02_code` - All code to clean data and run analyses as `.do` files.
    - `03_output` - All generated figures as `.svg` files.
    - `04_table` - All generated regression results as `.dta` files.

Each of the sub-folders are organized according to primary data source. See the README in ``01_data`` for more details on the data.

```

└───00_common
└───01_surveillance
└───02_baselineHH
└───03_phoneSurvey
└───04_followupVisit
└───05_bloodEndline
└───06_pilot
```

### Compiling
To create output generated in the paper, execute ``main.do`` while specifying the analysis you want to run. For example, to run the analyses used to generate Table 1, run the following command in Stata:

```
do main.do table1
```
Ensure that the working directory of Stata is the main project folder. All supported analyses are specified in ``02_code\options.do``.

Notes
----------
A few additional notes about the vocabulary used in the data.

### Geography
Bangladesh is defined into the following geographical units:

```
Bangladesh
│
└───Division
    └─── District
        └─── Upazila
            └─── Union
                └─── Village
```

Our intervention was conducted at the village level. We enrolled multiple villages in each division, district, and upazila. However, in a given union, we only enrolled *one* unique village. Therefore, for brevity, villages are referred to as ``union`` in the code.

To de-identify individual data, we do not link data points to their associated village, union, or upazila. We do provide information on the district. Unions are provided with with random codes.

### Execution of the Intervention
The intervention for each village was conducted in stages: baseline (week 0), week 2, week 4, week 6, week 8, week 10, and followup. The active intervention occured from week 2 to week 8.

The intervention started in different villages at different times, rolling out over 7 waves.

Contact Us
----------
For any questions, comments, or suggestions please reach out to Emily Crawford.

People
------

Emily L. Crawford

    email:       emily.crawford [AT] yale [DOT] edu
    institution: Yale School of Management
    role:        Author


Jason Abaluck

    email:       jason.abaluck [AT] yale [DOT] edu
    institution: Yale School of Management
    role:        First Author
