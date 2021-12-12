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

def est_treatment_effect(pairIDs):
    # Input: a list of IDs of paired villages
    # Output: relative risk reduction of treatment. Also prints basic cross tabulation and counts    

    CT = pd.crosstab(df[df.pairID.isin(pairIDs)].treatment, df[df.pairID.isin(pairIDs)].posXsymp)

    print(CT)
    
    i_C_sub = CT[1][0]
    n_C_sub = CT[0][0]+i_C_sub
    i_T_sub = CT[1][1]
    n_T_sub = CT[0][1]+i_T_sub
    
    print('number of control subjects = {}'.format(n_C_sub))
    print('number symp&sero+ in control = {}'.format(i_C_sub))
    print('number of treatment subjects = {}'.format(n_T_sub))
    print('number symp&sero+ in treatment = {}\n'.format(i_T_sub))

    rr = i_C_sub/i_T_sub*n_T_sub/n_C_sub
    
    print('point estimate of risk reduction: {:.2f}'.format(1/rr))
    print('point estimate of effectiveness: {:.0f}%'.format(100*(1-1/rr)))

    return rr

print('------------------------------------------------------------------------')
print('All Villages')
all_pairs = df.pairID.unique()
est_treatment_effect(all_pairs)
print('\n')

print('------------------------------------------------------------------------')
print('Surgical Masks')
surgical_subset = df[df.surgical=='received surgical masks'].pairID.unique()
est_treatment_effect(surgical_subset)
print('\n')

print('------------------------------------------------------------------------')
print('Cloth Masks')
cloth_subset = df[df.cloth=='received cloth masks'].pairID.unique()
est_treatment_effect(cloth_subset)
print('\n')

print('------------------------------------------------------------------------')
print('Green Surgical Masks')
purple_subset = df[df.mask_treat_color=='green'].pairID.unique()
est_treatment_effect(purple_subset)
print('\n')

print('------------------------------------------------------------------------')
print('Blue Surgical Masks')
purple_subset = df[df.mask_treat_color=='blue'].pairID.unique()
est_treatment_effect(purple_subset)
print('\n')

print('------------------------------------------------------------------------')
print('Purple Cloth Masks')
purple_subset = df[df.mask_treat_color=='purple'].pairID.unique()
est_treatment_effect(purple_subset)
print('\n')

print('------------------------------------------------------------------------')
print('Red Cloth Masks')
purple_subset = df[df.mask_treat_color=='red'].pairID.unique()
est_treatment_effect(purple_subset)
print('\n')

# intra-cluster correlation coefficients using ANOVA method.

aov = anova(data=df[df.treatment==0], between='union', dv='posXsymp', detailed=True)
print('symptomatic and seropositive: rho={:.1e}'.format(aov.np2[0]))

aov = anova(data=df[df.treatment==0], between='union', dv='symp', detailed=True)
print('symptomatic only: rho={:.1e}'.format(aov.np2[0]))

# design-effect adjusted p-values and confidence intervals

n_T=170497 # number in treatment
n_C=156938 # number in control
k_C=286 # clusters in treatment
k_T=286 # clusters in control
i_T=1086 # number seropositive and sytmptomatic in treatment
i_C=1106 # number seropositive and sytmptomatic in control

rho = 0.007 # intra-cluster correlation coefficient

design_effect=1+rho*((n_T+n_C)/(k_T+k_C)-1) 
print('design effect = {:.1f}\n'.format(design_effect))


# z-score for the z-test of proportions assuming balance
prop_T=i_T/n_T
prop_C=i_C/n_T
prop=(i_T+i_C)/(n_T+n_T)

z_score_balanced = (prop_C-prop_T)/np.sqrt((prop*(1-prop)*(1/n_T+1/n_T)))

print('unadjusted z-score if balanced = {:.2f}'.format(z_score_balanced))
print('unadjusted p-value if balanced = {:.1e}'.format(1-gaussian.cdf(z_score_balanced)))

print('\n-------------------------------------------------')

# z-score for the z-test of proportions (post survey selection bias)
prop_T=i_T/n_T
prop_C=i_C/n_C
prop=(i_T+i_C)/(n_T+n_C)

z_score = (prop_C-prop_T)/np.sqrt((prop*(1-prop)*(1/n_C+1/n_T)))

print('unadjusted z-score = {:.2f}'.format(z_score))
print('unadjusted p-value = {:.1e}'.format(1-gaussian.cdf(z_score)))

print('design-effect adjusted z-score = {:.2f}'.format(z_score/np.sqrt(design_effect)))
print('design-effect adjusted p-value = {:.1e}'.format(1-gaussian.cdf(z_score/np.sqrt(design_effect))))

# log relative risk lRR and associated standard error SE
lRR=np.log(i_C/i_T*n_T/n_C)
SE=np.sqrt(1/i_C+1/i_T-1/n_C-1/n_T)

print('\n-------------------------------------------------')
print('Risk ratio: {:.3f}'.format(np.exp(-lRR)))
print('Standard Error: {:.2e}'.format(SE))
print('Unadjusted confidence interval: [{:.3f}, {:.3f}]'.format(np.exp(-lRR-1.96*SE),
    np.exp(-lRR+1.96*SE)))
print('Effectiveness: {:.1f}%'.format(100*(1-np.exp(-lRR))))
print('Unadjusted confidence interval: [{:.1f}%, {:.1f}%]'.format(100*(1-np.exp(-lRR+1.96*SE)),
    100*(1-np.exp(-lRR-1.96*SE))))

print('\n')
print('Risk ratio, design-effect adjusted confidence interval: [{:.2f}, {:.2f}]'.format(
    np.exp(-lRR-1.96*SE*np.sqrt(design_effect)),
    np.exp(-lRR+1.96*SE*np.sqrt(design_effect))))
print('Effectiveness, design-effect adjusted confidence interval: [{:.1f}%, {:.1f}%]'.format(
    100*(1-np.exp(-lRR+1.96*SE*np.sqrt(design_effect))),
    100*(1-np.exp(-lRR-1.96*SE*np.sqrt(design_effect)))))

# examining the effect of surgical masks on people over 60.
# this cell just pastes together a bunch of the functionality from above, but focuses on this subquery.

design_effect = 5

surgical_subset = df[df.surgical=='received surgical masks'].pairID.unique()
pairIDs=surgical_subset

CT = pd.crosstab(df[(df.pairID.isin(pairIDs)) & (df.above_60==1)].treatment, 
                 df[(df.pairID.isin(pairIDs)) & (df.above_60==1)].posXsymp)
print(CT)

i_C_sub = CT[1][0]
n_C_sub = CT[0][0]+i_C_sub
i_T_sub = CT[1][1]
n_T_sub = CT[0][1]+i_T_sub

print('number of control subjects = {}'.format(n_C_sub))
print('number symp&sero+ in control = {}'.format(i_C_sub))
print('number of treatment subjects = {}'.format(n_T_sub))
print('number symp&sero+ in treatment = {}\n'.format(i_T_sub))

rr = i_C_sub/i_T_sub*n_T_sub/n_C_sub

print('point estimate of risk reduction: {:.2f}'.format(1/rr))
print('point estimate of effectiveness: {:.0f}%'.format(100*(1-1/rr)))

# z-score.
prop_T=i_T_sub/n_T_sub
prop_C=i_C_sub/n_C_sub
prop=(i_T_sub+i_C_sub)/(n_T_sub+n_C_sub)

z_score = (prop_C-prop_T)/np.sqrt((prop*(1-prop)*(1/n_C_sub+1/n_T_sub)))/np.sqrt(design_effect)

print('design-effect adjusted p-value for z-test = {:.1e}'.format(1-gaussian.cdf(z_score)))

# log relative risk and its standard error.
lRR=np.log(i_C_sub/n_C_sub*n_T_sub/i_T_sub)
SE=np.sqrt(1/i_C_sub+1/i_T_sub-1/n_C_sub-1/n_T_sub)

print('Adjusted confidence interval for RR: [{:.2f}, {:.2f}]'.format(
    np.exp(-lRR-1.96*SE*np.sqrt(design_effect)),
    np.exp(-lRR+1.96*SE*np.sqrt(design_effect))))

print('Adjusted confidence interval for EFF: [{:.0f}%, {:.0f}%]'.format(
    100*(1-1/np.exp(lRR-1.96*SE*np.sqrt(design_effect))),
    100*(1-1/np.exp(lRR+1.96*SE*np.sqrt(design_effect)))))   

# power calculation to account for design effect.
background_prev = 0.0076 # assumed background prevalence with no intervention
rr = 0.9 # proposed risk reduction to power for
M = 600 # average number of individuals per cluster
rho = 0.007 # intra-cluster correlation coefficient

design_effect = 1+rho*(M-1)

pC_guess = background_prev
pT_guess = rr*pC_guess
p_guess = 0.5*pC_guess+0.5*pT_guess
effect_size = (pC_guess-pT_guess)/np.sqrt(p_guess*(1-p_guess))

N_needed = zt_ind_solve_power(effect_size=effect_size, 
                              nobs1=None, alpha=0.05, power=0.90, 
                              alternative='larger')*design_effect

print('Estimated Number Needed={:.1e}'.format(N_needed))
print('Trial size needs to be increased by {:.1f}x'.format(N_needed/342183))     