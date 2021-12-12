import pandas as pd
import numpy as np

# a few stats functions
from pingouin import anova
from scipy.stats import norm as gaussian
from statsmodels.stats.power import zt_ind_solve_power

# The data file is in the git repo https://gitlab.com/emily-crawford/bd-mask-rct
# in the folder 01_data/05_bloodEndline/01_clean/
dtafile = 'endlineBlood_data.dta'
df = pd.read_stata(dtafile)
df.to_csv('endlineBlood_data.csv',index=False)
exit()
'''
NOTE:
 The authors remove individuals from their regressions if 
 1. they did not collect symptom data from them in the midline or endline surveys. 
 2. the individual reported symptoms but did not have blood drawn
 3. they thought they drew blood from the individual, but couldn't match to a blood sample.

 Under an intention-to-treat analysis, these should not be dropped, so I leave them in. But you
 can run the analysis dropping these individuals by uncommenting the following line:
'''
# df = df[(df.recorded_blood_no_result!=1) & (df.elig_no_blood!=1) & (df.mi_symp!=1)]

### Display dataframe properties
print(df.tail())
print(len(df.name.unique()))
print(df.columns)
print(df.shape)