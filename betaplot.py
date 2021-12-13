import numpy as np
from scipy.stats import beta
import matplotlib.pyplot as plt
from math import sqrt



##ALL
x = np.linspace(0.0,0.01,1000)
control_n=156938 
treatment_n=170497 
control_p=1106
treatment_p=1086
control_a=control_p+1
control_b=control_n-control_p+1
treatment_a=treatment_p+1
treatment_b=treatment_n-treatment_p+1
rho = 0.007
de=1+(((control_n+treatment_n)/572)-1)*rho
plt.clf()
plt.plot(x, beta.pdf(x, control_a, control_b))
plt.plot(x, beta.pdf(x, treatment_a, treatment_b))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/all.png')
plt.clf()
plt.plot(x, beta.pdf(x, control_a/de, control_b/de))
plt.plot(x, beta.pdf(x, treatment_a/de, treatment_b/de))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/all-de.png')

##Surgical
x = np.linspace(0.0,0.01,1000)
control_n=103247 
treatment_n=113082 
control_p=774
treatment_p=756
control_a=control_p+1
control_b=control_n-control_p+1
treatment_a=treatment_p+1
treatment_b=treatment_n-treatment_p+1
rho = 0.007
de=1+(((control_n+treatment_n)/572)-1)*rho
plt.clf()
plt.plot(x, beta.pdf(x, control_a, control_b))
plt.plot(x, beta.pdf(x, treatment_a, treatment_b))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/surgical.png')
plt.clf()
plt.plot(x, beta.pdf(x, control_a/de, control_b/de))
plt.plot(x, beta.pdf(x, treatment_a/de, treatment_b/de))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/surgical-de.png')

##Cloth
x = np.linspace(0.0,0.01,1000)
control_n=53691 
treatment_n=57415 
control_p=332
treatment_p=330
control_a=control_p+1
control_b=control_n-control_p+1
treatment_a=treatment_p+1
treatment_b=treatment_n-treatment_p+1
rho = 0.007
de=1+(((control_n+treatment_n)/572)-1)*rho
plt.clf()
plt.plot(x, beta.pdf(x, control_a, control_b))
plt.plot(x, beta.pdf(x, treatment_a, treatment_b))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/cloth.png')
plt.clf()
plt.plot(x, beta.pdf(x, control_a/de, control_b/de))
plt.plot(x, beta.pdf(x, treatment_a/de, treatment_b/de))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/cloth-de.png')

##Green
x = np.linspace(0.0,0.01,1000)
control_n=51230 
treatment_n=55162 
control_p=394
treatment_p=378
control_a=control_p+1
control_b=control_n-control_p+1
treatment_a=treatment_p+1
treatment_b=treatment_n-treatment_p+1
rho = 0.007
de=1+(((control_n+treatment_n)/572)-1)*rho
plt.clf()
plt.plot(x, beta.pdf(x, control_a, control_b))
plt.plot(x, beta.pdf(x, treatment_a, treatment_b))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/green.png')
plt.clf()
plt.plot(x, beta.pdf(x, control_a/de, control_b/de))
plt.plot(x, beta.pdf(x, treatment_a/de, treatment_b/de))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/green-de.png')

##Blue
x = np.linspace(0.0,0.01,1000)
control_n=52017 
treatment_n=57920 
control_p=380
treatment_p=378
control_a=control_p+1
control_b=control_n-control_p+1
treatment_a=treatment_p+1
treatment_b=treatment_n-treatment_p+1
rho = 0.007
de=1+(((control_n+treatment_n)/572)-1)*rho
plt.clf()
plt.plot(x, beta.pdf(x, control_a, control_b))
plt.plot(x, beta.pdf(x, treatment_a, treatment_b))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/blue.png')
plt.clf()
plt.plot(x, beta.pdf(x, control_a/de, control_b/de))
plt.plot(x, beta.pdf(x, treatment_a/de, treatment_b/de))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/blue-de.png')

##Purple
x = np.linspace(0.0,0.01,1000)
control_n=27918 
treatment_n=29541 
control_p=177
treatment_p=187
control_a=control_p+1
control_b=control_n-control_p+1
treatment_a=treatment_p+1
treatment_b=treatment_n-treatment_p+1
rho = 0.007
de=1+(((control_n+treatment_n)/572)-1)*rho
plt.clf()
plt.plot(x, beta.pdf(x, control_a, control_b))
plt.plot(x, beta.pdf(x, treatment_a, treatment_b))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/purple.png')
plt.clf()
plt.plot(x, beta.pdf(x, control_a/de, control_b/de))
plt.plot(x, beta.pdf(x, treatment_a/de, treatment_b/de))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/purple-de.png')

##Red
x = np.linspace(0.0,0.01,1000)
control_n=25773 
treatment_n=27874 
control_p=155
treatment_p=143
control_a=control_p+1
control_b=control_n-control_p+1
treatment_a=treatment_p+1
treatment_b=treatment_n-treatment_p+1
rho = 0.007
de=1+(((control_n+treatment_n)/572)-1)*rho
plt.clf()
plt.plot(x, beta.pdf(x, control_a, control_b))
plt.plot(x, beta.pdf(x, treatment_a, treatment_b))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/red.png')
plt.clf()
plt.plot(x, beta.pdf(x, control_a/de, control_b/de))
plt.plot(x, beta.pdf(x, treatment_a/de, treatment_b/de))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/red-de.png')


###################################################
## only use tested folks for N
###################################################

##ALL
x = np.linspace(0.15,0.3,1000)
control_n=4798 
treatment_n=4714 
control_p=1106
treatment_p=1086
control_a=control_p+1
control_b=control_n-control_p+1
treatment_a=treatment_p+1
treatment_b=treatment_n-treatment_p+1
rho = 0.007
de=1+(((control_n+treatment_n)/572)-1)*rho
plt.clf()
plt.plot(x, beta.pdf(x, control_a/de, control_b/de))
plt.plot(x, beta.pdf(x, treatment_a/de, treatment_b/de))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/all-test.png')

##Surgical
x = np.linspace(0.1,0.2,1000)
control_n=4798 
treatment_n=4714 
control_p=774
treatment_p=756
control_a=control_p+1
control_b=control_n-control_p+1
treatment_a=treatment_p+1
treatment_b=treatment_n-treatment_p+1
rho = 0.007
de=1+(((control_n+treatment_n)/572)-1)*rho
plt.clf()
plt.plot(x, beta.pdf(x, control_a/de, control_b/de))
plt.plot(x, beta.pdf(x, treatment_a/de, treatment_b/de))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/surgical-test.png')

##Cloth
x = np.linspace(0.0,0.15,1000)
control_n=4798 
treatment_n=4714 
control_p=332
treatment_p=330
control_a=control_p+1
control_b=control_n-control_p+1
treatment_a=treatment_p+1
treatment_b=treatment_n-treatment_p+1
rho = 0.007
de=1+(((control_n+treatment_n)/572)-1)*rho
plt.clf()
plt.plot(x, beta.pdf(x, control_a/de, control_b/de))
plt.plot(x, beta.pdf(x, treatment_a/de, treatment_b/de))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/cloth-test.png')

##Green
x = np.linspace(0.0,0.2,1000)
control_n=4798 
treatment_n=4714 
control_p=394
treatment_p=378
control_a=control_p+1
control_b=control_n-control_p+1
treatment_a=treatment_p+1
treatment_b=treatment_n-treatment_p+1
rho = 0.007
de=1+(((control_n+treatment_n)/572)-1)*rho
plt.clf()
plt.plot(x, beta.pdf(x, control_a/de, control_b/de))
plt.plot(x, beta.pdf(x, treatment_a/de, treatment_b/de))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/green-test.png')

##Blue
x = np.linspace(0.0,0.2,1000)
control_n=4798 
treatment_n=4714 
control_p=380
treatment_p=378
control_a=control_p+1
control_b=control_n-control_p+1
treatment_a=treatment_p+1
treatment_b=treatment_n-treatment_p+1
rho = 0.007
de=1+(((control_n+treatment_n)/572)-1)*rho
plt.clf()
plt.plot(x, beta.pdf(x, control_a/de, control_b/de))
plt.plot(x, beta.pdf(x, treatment_a/de, treatment_b/de))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/blue-test.png')

##Purple
x = np.linspace(0.0,0.2,1000)
control_n=4798 
treatment_n=4714 
control_p=177
treatment_p=187
control_a=control_p+1
control_b=control_n-control_p+1
treatment_a=treatment_p+1
treatment_b=treatment_n-treatment_p+1
rho = 0.007
de=1+(((control_n+treatment_n)/572)-1)*rho
plt.clf()
plt.plot(x, beta.pdf(x, control_a/de, control_b/de))
plt.plot(x, beta.pdf(x, treatment_a/de, treatment_b/de))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/purple-test.png')

##Red
x = np.linspace(0.0,0.2,1000)
control_n=4798 
treatment_n=4714 
control_p=155
treatment_p=143
control_a=control_p+1
control_b=control_n-control_p+1
treatment_a=treatment_p+1
treatment_b=treatment_n-treatment_p+1
rho = 0.007
de=1+(((control_n+treatment_n)/572)-1)*rho
plt.clf()
plt.plot(x, beta.pdf(x, control_a/de, control_b/de))
plt.plot(x, beta.pdf(x, treatment_a/de, treatment_b/de))
plt.legend(['Control','Treatment'])
plt.xlabel('Fraction of Seropositivity')
plt.ylabel('Probability Density')
plt.savefig('documents/red-test.png')
