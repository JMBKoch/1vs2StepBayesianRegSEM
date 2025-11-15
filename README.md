# Testrun Introductie

Deze branch is een minimale versie van de repo voor testdoeleinden. Ik heb deze testrun zelf succesvol uitgevoerd
op mijn mac en op mijn linux-server (debian bookworm).

# Overzicht branch

- [R](./R): Hier zijn de R scripts om de analyse te draaien.
  - [R/parameters.R](R/parameters.R): Hier zitten 2 reeks parameters, waarvan er eentje is uitgecommented. De uitgecommente
   is de versie van parameters die ik stand vandaag obv de review zou gebruiken. 
- [stan](./stan): Hier is de stan code van alle modellen. Nu nog en in wishart en in loop-over-1-t/m-N
specificatie.
  - Relevant om te checken: [LASSO.stan](./stan/LASSO.stan), [LASSO_wishart.stan](./stan/LASSO_wishart.stan),
  [LASSO_hyper.stan](./stan/LASSO_hyper.stan) & [LASSO_hyper_wishart.stan](./stan/LASSO_hyper_wishart.stan)
- [renv](./renv): R-package dependency environment voor deze repo met `renv::`. Hier hoef je niets mee te doen. 
- [renv.lock](./renv.lock): `renv::` houdt hier de dependencies bij. Hoef je niets mee te doen.

# Testrun Instructies

## 1. Clone deze branch

```bash
git clone -b testrun-sara --single-branch --depth 1 https://github.com/JMBKoch/1vs2StepBayesianRegSEM 
```

## 2. Run main-script 

Run in de linux shell, **vanuit de root van deze repo**:

```bash
Rscript R/main.R
```

of laad [1vs2StepBayesianRegSEM.Rproj](./1vs2StepBayesianRegSEM.Rproj) in RStudio 
en source [R/main.R](./R/main.R).

De run was succesvol wanneer er geen errors zijn en per prior in [R/main.R](./R/main.R) en 
resultaten en convergence-resultaten in [output](./output) komen te staan. 

Er zitten nu 5 priors in [R/main.R](./R/main.R):

1. SVNP (wishart)
2. SVNP met hyper prior (wishart)
3. LASSO (wishart)
4. LASSO met hyper prior (wishart)
5. RSHP (wishart)

In totaal wil je dus 5 x 2 = 10 .RDS-bestanden in de output-map hebben zitten.

## Checks Programmatuur

- Zijn de uitgecommente parameters in  [R/parameters.R](R/parameters.R) zinvole keuzes voor de finale draai?

- Zijn de specificaties van de LASSO-prior (en met en zonder hyperprior, en met en zonder wishart specificatie) correct?

## Optioneel: Check Resultaten

Voel je vrij om zelf parameters aan te passen en hierdoor bijvoorbeeld te gaan checken of de wishart specificatie wel klopt.