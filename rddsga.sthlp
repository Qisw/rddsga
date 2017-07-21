{smcl}
{* *! version 1.0 Jul 2017}{...}

{title:Title}

{pstd}
{hi:rddsga} {hline 2} Subgroup analysis with propensity score weighting in RDD settings


{title:Syntax}

{p 8 16 2}
{cmd:rddsga} {depvar} {it:assignvar} [{indepvars}] {ifin}
[{cmd:,} {it:options}]
{p_end}

{phang}
{it:assignvar} is the assignment variable for which there is a known cutoff at which the conditional mean of the treatment variable changes abruptly.{p_end}

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Model}
{synopt :{opt nocon:stant}}suppress constant term{p_end}
{synopt :{opt h:ascons}}has user-supplied constant{p_end}

{syntab :SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt un:adjusted},
   {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap},
   {opt jack:knife}, or {opt hac} {help ivregress##kernel:{it:kernel}}{p_end}



{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synoptset 20 tabbed}{...}
{synopt:{opth t:otry(indepvars)}} specify list of covariates to try; default is all{p_end}
{synopt:{opth not:ry(varlist)}} specify list of covariates to exclude; default is none{p_end}
{synopt:{opt nol:in}} prevent algorithm of testing linear terms{p_end}
{synopt:{opt noq:uad}} prevent algorithm of testing quadratic terms{p_end}
{synopt:{opt cl:inear(real)}} threshold value for likelihood ratio test of first order covariates; default is 1{p_end}
{synopt:{opt cq:uadratic(real)}} threshold value for likelihood ratio test of second order covariates; default is 2.71{p_end}
{synopt:{opt iter:ate(#)}} perform maximum of # iterations in each logit; default is 16000{p_end}
{synopt:{opth genps:core(newvar)}} generate new variable with propensity score estimation{p_end}
{synopt:{opth genl:or(newvar)}} generate new variable with log odds ratio{p_end}
{synoptline}
{p 4 6 2}
{it:indepvars} may contain factor variables; see {help fvvarlist}.{p_end}


{p 4 6 2}

{title:Description}

{pstd}
This program implements a binary subgroup analysis in RDD settings based on propensity score weighting.
Observations in each subgroup are weighted by the inverse of their conditional probabilities to belong to that subgroup, given a set of covariates.
Performing RDD analysis separately within each weighted subgroup eliminates potential confounding differences due to other observable factors that may vary systematically across (uneweighted) subgroups.

{pstd}
A binary treatment variable must be specified as {help depvar:dependent variable}.
A subset of covariates may be explicitly included in the linear part of the specification as {help indepvars:independent variables}.
This initial configuration corresponds to the base model.
All specifications are fitted with a {manhelp logit R:logit} model by maximum likelihood.

{pstd}
The algorithm selects first order terms from all remaining variables of the dataset (i.e. excluding variables of the base model),
unless a subset of variables is specified with the {opth totry(indepvars)} option.
Specific variables may be excluded using the {opth notry(varlist)} option.

{pstd}
The selection of first order terms is performed in a stepwise fashion, comparing the base (nested) model to a model with one single additional covariate.
A likelihood ratio test (LRT) on the null hypothesis of non-significance of the additional coefficient is performed (see {manhelp lrtest R:lrtest}).
All covariates that have not been included are tested and the algorithm selects the one associated with the highest LRT statistic,
unless no covariate meets the LRT statistic threshold specified in {opth clinear(real)}. 
This covariate is then included in the model.

{pstd}
The process of selecting and including additional linear terms is carried out until the highest LRT statistic is less than {opt clinear(real)} or there are no remaining covariates to add.

{pstd}
The algorithm chooses second order terms only from covariates selected for the linear specification, performing analogue tests for selection among all interactions and quadratic terms.
This second process of selecting and including additional quadratic terms is carried out until the highest LRT statistic is less than {opt cquadratic(real)} or there are no remaining quadratic terms to add.

{title:Options}

{phang}
{opth totry(varlist)} specifies the vector of covariates from which the first (and potentially second) order terms are going to be selected.
The default is to include all variables in the dataset, exluding the {depvar} and other base model covariates indicated in {indepvars} (if any).

{phang}
{opth notry(varlist)} specifies a vector of covariates to be excluded from the selection of terms.

{phang}
{opt nolin} prevents the program from testing linear terms, choosing quadratic terms from covariates specified as {help indepvars:independent variables}.
It can be useful to speed up the algorithm if the linear part is already chosen.
If specified, option {opt clinear} is irrelevant.
This option may not be combined with {opt noquad}.

{phang}
{opt noquad} prevents the program from testing quadratic terms, ending when all linear terms have been added.
It can be useful to speed up the algorithm if the quadratic part is not desired.
If specified, option {opt cquadratic} is irrelevant.
This option may not be combined with {opt nolin}.

{phang}
{opt clinear(real)} specifies the threshold value used for the addition of first order (linear) terms.
The decision is based on the likelihood ratio test statistic for the null hypothesis that the coefficient of the additional first order term is equal to zero.
See {manhelp lrtest R:lrtest} for additional information.
If the {opt nolin} option is specified, then this option is irrelevant.
Default value is 1.

{phang}
{opt cquadratic(real)} specifies the threshold value used for the addition of second order (quadratic) terms.
The decision is based on the likelihood ratio test statistic for the null hypothesis that the coefficient of the additional second order term is equal to zero.
See {manhelp lrtest R:lrtest} for additional information.
If the {opt noquad} option is specified, then this option is irrelevant.
Default value is 2.71.

{phang}
{opt iterate(#)} specifies the maximum number of iterations in each logit estimation.
Stata's default value is 1600.
See {manhelp logit R:logit} and {manhelp maximize R:maximize} for additional information.

{phang}
{opth genpscore(newvar)} specifies that a new variable with the estimated propensity scores is generated, named {it: newvar}.

{phang}
{opth genlor(newvar)} specifies that a new variable with the log odds ratio of the estimated propensity score is generated, named {it: newvar}.

{marker remarks}{...}
{title:Remarks on executing time}

{pstd}
The algorithm implemented by {cmd: rddsga} may take a (very) long time executing.
A progress indicator is displayed while the program selects first and second order terms, to monitor progress.
The number in parenthesis corresponds to the upper bound of iterations the algorithm could perform before running out of covariates (or its combinations, if applicable) to try.

{pstd}
The selection of linear terms is usually faster than that of quadratic ones.
It is a good idea to start using the command with the {opt noquad} option and then, when linear terms are chosen, include them explicitely as {indepvars} and use {opt nolin} to skip the first stage.

{title:Examples}

{pstd}
For these examples I use the "Lalonde Experimental Data (Dehejia-Wahba Sample)", corresponding to the data analyzed by {help rddsga##DW_1999:Dehejia and Wahba (1999)} and available on Dehejia's website.
The dataset contains 445 observations with information on treatment status and various other characteristics.

{pstd}
To install the ancillary files (nswre74.dta and replicate_lalonde.do), remember to use {cmd: net gate} after {cmd: ssc install}:

{phang2}{cmd:. ssc install rddsga}{p_end}
{phang2}{cmd:. net get rddsga}{p_end}

{pstd}Setup{p_end}
{phang2}{cmd:. use nswre74}{p_end}

{pstd}Select PS model for treatment variable{p_end}
{phang2}{cmd:. rddsga treat}{p_end}

{pstd}Select PS model from restricted list of covariates and lowered quadratic threshold{p_end}
{phang2}{cmd:. rddsga treat, totry(age-nodeg re*) cquad(.8)}{p_end}

{pstd}Select PS model with income and unemployment dummies as basic covariates{p_end}
{phang2}{cmd:. foreach y in 74 75 78 {c -(}} {p_end}
{phang2}{cmd:.	gen u`y' = (re`y'==0)}{p_end}
{phang2}{cmd:. }}{p_end}
{phang2}{cmd:. rddsga treat re* u*}{p_end}

{pstd}Estimate propensity score with no quadratic terms{p_end}
{phang2}{cmd:. rddsga treat, genpscore(ps) noquad}{p_end}

{pstd}Estimate log odds ratio with explicit selection of linear terms{p_end}
{phang2}{cmd:. rddsga treat age-nodeg, nolin genlor(logodds)}{p_end}

{title:Stored results}

{pstd}
{cmd:rddsga} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(oribal_N_G0)}}number of observations in subgroup 0 (original balance){p_end}
{synopt:{cmd:r(oribal_N_G1)}}number of observations in subgroup 1 (original balance){p_end}
{synopt:{cmd:r(oribal_Fstat)}}F-statistic (original balance){p_end}
{synopt:{cmd:r(oribal_pvalue)}}F-statistic p-value (original balance){p_end}
{synopt:{cmd:r(oribal_avgdiff)}}Average of absolute values of standardized differences (original balance){p_end}

{synopt:{cmd:r(pswbal_N_G0)}}number of observations in subgroup 0 (PSW balance){p_end}
{synopt:{cmd:r(pswbal_N_G1)}}number of observations in subgroup 1 (PSW balance){p_end}
{synopt:{cmd:r(pswbal_Fstat)}}F-statistic (PSW balance){p_end}
{synopt:{cmd:r(pswbal_pvalue)}}F-statistic p-value (PSW balance){p_end}
{synopt:{cmd:r(pswbal_avgdiff)}}Average of absolute values of standardized differences (PSW balance){p_end}

{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(pswbal)}}balance table matrix (original balance){p_end}
{synopt:{cmd:r(oribal)}}balance table matrix (PSW balance){p_end}
{p2colreset}{...}

{pstd}
Additionally, {cmd:rddsga} stores all results stored in {cmd:e()} by {manhelp ivregress R:ivregress} after fitting the final model with all selected terms.

{title:Authors}

{pstd}
Alvaro Carril{break}
Research Analyst at J-PAL LAC{break}
acarril@fen.uchile.cl

{pstd}
Andre Cazor{break}
Research Analyst at J-PAL LAC{break}
ajcazor@uc.cl

{pstd}
Stephan Litschig{break}
Associate Professor at GRIPS{break}
s-litschig@grips.ac.jp

{title:Disclaimer}

{pstd}
This software is provided "as is", without warranty of any kind.
If you have suggestions or want to report problems, please create a new issue in the {browse "https://github.com/acarril/rddsga/issues":project repository}.
All remaining errors are our own.

{title:References}

{marker DW_1999}{...}
{phang}Dehejia, Rajeev H. and Sadek Wahba. 1999.
"Causal Effects in Nonexperimental Studies".
{it:Journal of the American Statistical Association} 94(448): 1053-1062.

{marker imbens_rubin_2015}{...}
{phang}Imbens, Guido W. and Donald B. Rubin. 2015.
{it: Causal Inference in Statistics, Social, and Biomedical Sciences}.
New York: Cambridge University Press.

{marker imbens_2015}{...}
{phang}Imbens, Guido W. 2015.
"Matching Methods in Practice: Three Examples".
{it:Journal of Human Resources} 50(2): 373-419.
{p_end}
