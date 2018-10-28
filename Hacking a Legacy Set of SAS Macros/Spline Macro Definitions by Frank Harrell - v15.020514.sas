*** Reference: http://biostat.mc.vanderbilt.edu/wiki/Main/SasMacros;
***
*** Version 15: Based on Version 11. Write out spline data to CSV file
*** for plotting in R, as was done in Version 8. (But this version retains
*** the convention that the censoring variable has a value of 0
*** rather than 1 for censoring.)
*** Define flag for macro PSPLINET that turns on / off TIES=DISCRETE.
***
*** Version 11: Based on Spline Macro Definitions by Frank Harrel - v9.061113.sas
*** rather than on Version 10, since the censoring variable has a value of 0
*** rather than 1 for censoring.
*** Modification for the BPA-Phthalates project, with Adjust4 covariates.
***
*** Version 9: Similar to Version 8, but write out spline data to
*** SAS data sets. Will attempt plotting in SAS outside of the
*** Vanderbilt macros.
***
*** Version 8: Write out spline data for plotting in R. This is just
*** a simple hack building upon Version 7.
*** This version still retains the changes in Version 4 that are specific
*** to the LIFE study, that will not work outside that context.
***
*** Version 7: Draw the horizontal line at 1.0 with black dashed line
*** rather than a solid blue line. Note: the line appears as a solid
*** black line rather than as a dashed black line. This appears to be
*** a SAS bug.
***
*** Version 6: Draw a line at Hazard Ratio = 1.0
***
*** Version 5: Do plot in terms of Hazard Ratio rather than Log(Hazard Ratio).
*** This version still retains the changes in Version 4 that are specific
*** to the LIFE study, that will not work outside that context.
***
*** Version 4: Light hack: In invocation of PROC PHREG in macro PSPLINET,
*** insert left truncation. This hack ASSUMES left truncation variables
*** as defined in the LIFE study (nttp and nummths) and will not work
*** outside that context.
***
*** Version 3: Light hack: suppress Results Viewer output of invocation
*** of PROC PHREG in macro PSPLINET.
***
*** Version 2: removed DATA STEPs that were popping up distracting
*** interactive windows when this file is sourced. They look cool,
*** but are not necessary for the spline project and may even interfere.;

/*

                SAS macros and data step programs useful in survival
                analysis and logistic regression.  Includes several
                macros for fitting spline functions.
                NOTE: These macros are unsupported.

                Author: Frank E Harrell Jr
                                                                         */

 /* SAS Macro AXISSPEC

    In a DATA step, calculates the  minima  and  maxima  for  a  list  of
    variables, and at the last observation in the dataset, defines global
    macro  variables  spec1,...,specp, where p is the number of variables
    being  processed.   These  macro   variables   define   "nice"   axis
    specifications that are generally more pleasing than those derived by
    PROC  PLOT  or PROC GPLOT.  The specifications are of the form low TO
    high BY inc.  The user may specify the number of  intervals  to  make
    and   may   optionally   specify   the  interval  width  (STEP).   If
    unspecified,  this  width  will  be  computed.   AXISSPEC  uses   the
    algorithm  of  J.  A.  Nelder, Applied Statistics 25:94-7, 1976.  The
    default number of intervals is N=10.

    Usage:

    DATA ...; SET ...  END=e;
    %AXISSPEC(VAR=x y z); *Specify VAR (in quotes if >1) first call only;
    %AXISSPEC;             *Used if x,y,z values change more than once
                            for current observation;
    %AXISSPEC(END=e,(N=),(STEP=)); *Issue once at end. e=1 if end of file;
    PROC PLOT;PLOT y*x/HAXIS=&spec1 VAXIS=&spec2; *For example;

    The %AXISSPEC  command  above  without  END=e  is  only  issued  when
    variable  values change within the current observation.  This happens
    for example when preparing for  overlaying  multiple  curves  on  one
    graph.   Suppose  for  example  that one wishes to plot a value v and
    lower and upper confidence limits cl,cu on the same graph.  One would
    specify commands such as the following:

    y=cl; %AXISSPEC(VAR=y); y=cu; %AXISSPEC(END=e);
    PROC PLOT;PLOT v*x='*' cl*x='.' cu*x='.'/OVERLAY VAXIS=&spec1;

    If variable values do not change  within  an  observation,  only  one
    AXISSPEC statement is needed:  %AXISSPEC(VAR=x y z,END=e);

    Author   : Frank Harrell
               Clinical Biostatistics, Duke University Medical Center
               Takima West Corporation
    Date     : 16 Sep 86
    Modified : 17 Sep 86
                                                                      */
%MACRO AXISSPEC(var=,end=,n=10,step=);
%LET var=%SCAN(&var,1,'"''');
%IF &var^=  %THEN %DO;
   %LOCAL _nv_ i; %LET _nv_=0;
     %DO i=1 %TO 1000;
     %IF %SCAN(&var,&i)=  %THEN %GOTO nomorev;
     %LET _nv_=%EVAL(&_nv_+1);
     %END;
   %nomorev:
   DROP _rn_ _x_ _fmax_ _fmin_ _step_ _range_ _fact_ _omin_ _omax_
    _j_ _ctf_ _unit_1-_unit_13 _tol_ _bias_ _xmin_ _xmax_
    _k_ _min_1-_min_&_nv_ _max_1-_max_&_nv_;
   RETAIN _unit_1 1 _unit_2 1.2 _unit_3 1.4 _unit_4 1.5 _unit_5 1.6
    _unit_6 2 _unit_7 2.5 _unit_8 3 _unit_9 4 _unit_10 5 _unit_11 6
    _unit_12 8 _unit_13 10 _tol_ 5E-6 _bias_ 1E-4
    _min_1-_min_&_nv_ 1E30 _max_1-_max_&_nv_ -1E30;
   ARRAY _unit_{13} _unit_1-_unit_13;
   ARRAY _var_{*} &var;
   ARRAY _min_{*} _min_1-_min_&_nv_; ARRAY _max_{*} _max_1-_max_&_nv_;
   %END;
 DO _k_=1 TO DIM(_var_);
 _min_{_k_}=MIN(_var_{_k_},_min_{_k_});
 _max_{_k_}=MAX(_var_{_k_},_max_{_k_});
 END;
%IF &end^=  %THEN %DO;
IF &end THEN DO _k_=1 TO DIM(_var_);
_RN_=&n;_FMAX_=_max_{_k_};_FMIN_=_min_{_k_};_X_=ABS(_FMAX_);
_OMIN_=_FMIN_;_OMAX_=_FMAX_;_FACT_=1;_CTF_=0;
IF _X_=0 THEN _X_=1;
IF (_FMAX_-_FMIN_)/_X_<=_TOL_ THEN DO; %*VALUES EFFECTIVELY EQUAL;
     IF _FMAX_<0 THEN _FMAX_=0;
     ELSE IF _FMAX_=0 THEN _FMAX_=1;
     ELSE _FMIN_=0;
     END;
%IF &step^=  %THEN %DO; _step_=&step; %GOTO SKIPSTEP; %END;
DROP _s_ _i_;
TRYAGAIN:_STEP_=(_FMAX_-_FMIN_)/_RN_*_FACT_; _S_=_STEP_;
%*THE FACTOR 1+1/_RN_ IS INSERTED IN THE NELDER ALGORITHM TO INSURE
  THAT THE RESULTING LIMITS INCLUDE ALL THE DATA;
LOOP1:IF _S_>=1 THEN GO TO LOOP10;_S_=_S_*10;GO TO LOOP1;
LOOP10:IF _S_<10 THEN GO TO CALC;_S_=_S_/10;GO TO LOOP10;
CALC:_X_=_S_-_BIAS_;
     DO _I_=1 TO 13;
      IF _X_<=_UNIT_{_I_} THEN GO TO FOUND_U;
     END;
FOUND_U:_step_=_step_*_unit_{_i_}/_s_;
%SKIPSTEP: _range_=_step_*_rn_;
%* MAKE FIRST ESTIMATE OF XMIN;
_X_=.5*(1+(_FMIN_+_FMAX_-_RANGE_)/_STEP_);_J_=INT(_X_-_BIAS_);
IF _X_<0 THEN _J_=_J_-1;_XMIN_=_STEP_*_J_;
%* TEST IF XMIN COULD BE ZERO;
IF _FMIN_>=0 & _RANGE_>=_FMAX_ THEN _XMIN_=0;_XMAX_=_XMIN_+_RANGE_;
%* TEST IF XMAX COULD BE ZERO;
IF _FMAX_<=0 & _RANGE_>=-_FMIN_ THEN DO;_XMAX_=0;_XMIN_=-_RANGE_;END;
%IF &step=  %THEN %DO;
IF _CTF_<4 & ((_XMAX_<_OMAX_)|(_XMIN_>_OMIN_)) THEN DO;
      _CTF_=_CTF_+1; _FACT_=_FACT_*(1+1/_RN_);  GO TO TRYAGAIN;   END;
 %END;
CALL SYMPUT("spec"||trim(left(_k_)),
 trim(left(_xmin_))||" TO "||trim(left(_xmax_))
 ||" BY "||trim(left(_step_)));
END;
%END;
%MEND;
 /* SAS macro BPOWER - Plot power of binomial test for two proportions for
                       a fixed sample size.

Requires: Macro DSHIDE.

For a given type I error rate (ALPHA) and sample  size  for  each  sample
(n),  calculates  the  power  of  the  two-tailed  test for comparing two
proportions when the population proportions are P1  and  P2.   P1  varies
>from  PLOW to PHIGH and is plotted on
the x-axis.  Power is on the y-axis.  Five power curves are generated for
10%, 20%, 30%, 40%, and 50% reductions in P1.  I.e., for  each  value  of
P1, P2 varies from .9*P1, .8*P1, ..., to .5*P1.  The method of Casagrande
and  Pike  (Biometrics  34:482-486,  1978) is used to estimate the power.
The plotting symbol is for line printer plots is the first digit  of  the
percent  reduction.

    Usage:

         %BPOWER(n,plow,phigh,alpha,plot)

    The parameters are defined as follows:

         n    =common sample size for the two groups
         ALPHA=type I error rate
         PLOW =minimum value of P1
         PHIGH=maximum value of P1
         PLOT=1 for PROC PLOT, 2 for PROC GPLOT (default)

Example:  Plot power curves for testing for 10%-50% reductions in mortality
rates, when the baseline mortality rate may be between .05  and  .30.   The
common sample size in each of the two groups is n=200.

         %BPOWER(200,.05,.30,.05);

    Author   : Frank Harrell
    Date     : 13 Nov 85
    Modified : 02 Jun 86
               28 Apr 87 - SAS/PC Version
               02 Nov 87 - changed final RUN to QUIT
               14 Sep 88 - Added DSHIDE
               22 Nov 91 - added PROC GPLOT output
                               */

%MACRO BPOWER(n,plow,phigh,alpha,plot=2);
%LOCAL _lastds_;
%DSHIDE;
DATA _power_; LENGTH DEFAULT=4; FORMAT alpha 5.3;
n=&n; alpha=&alpha; z=probit(1-alpha/2);
     DO p1=&plow TO &phigh BY (&phigh-&plow)/100;
     DO reductn=10 to 50 BY 10;
     p2=p1*(1-reductn/100);
     q1=1-p1; q2=1-p2; pm=(p1+p2)/2; qm=1-pm;
     ds=.5+z*sqrt(.5*n*pm*qm); ex=.5*n*abs(p1-p2);
     sd=sqrt(.25*n*(p1*q1+p2*q2));
     power=1-probnorm((ds-ex)/sd)+probnorm((-ds-ex)/sd);
     OUTPUT;
     END;END;
 KEEP n alpha p1 p2 reductn power;
%IF &plot=1 %THEN %DO;
PROC PLOT;BY n alpha;PLOT power*p1=reductn/vaxis=0 to 1 by .1;
LABEL n="n" alpha="alpha" power="Power" p1="Group 1 Proportion";
FOOTNOTE "Symbols Used:   1-10%  2-20%  3-30%  4-40%  5-50% Reduction";
 %END;
%ELSE %DO;
 PROC GPLOT;BY n alpha;
   PLOT power*p1=reductn/vaxis=0 to 1 by .1;
   LABEL n="n" alpha="alpha" power="Power" p1="Group 1 Proportion";
   SYMBOL1 I=JOIN L=1 V=NONE;
   SYMBOL2 I=JOIN L=2 V=NONE;
   SYMBOL3 I=JOIN L=3 V=NONE;
   SYMBOL4 I=JOIN L=4 V=NONE;
   SYMBOL5 I=JOIN L=5 V=NONE;
   FOOTNOTE "Curves represent 10% - 50% reductions";
   %END;
QUIT;FOOTNOTE;
OPTIONS _LAST_= &_lastds_;
%MEND;
 /* SAS macro BSAMSIZ

Calculate the minimum sample size necessary to achieve a given power for  a
two-tailed  binomial  test comparing two proportions.  Input values are the
type I error rate ALPHA, the minimum power POWER, and  the  two  population
proportions  P1  and  P2.   The  method  of Casagrande and Pike (Biometrics
34:482-486, 1978) is used.  The sample size required, n, is the  number  of
observations  in  each  sample.  Therefore, a total of 2*n observations are
required.

    Usage:

         %BSAMSIZ(P1,P2,ALPHA,POWER)

ALPHA=type I error rate and POWER=minimum power.

Example:  Find the minimum sample size that will achieve a power of  .9  to
detect a difference if the true proportions are .1 and .3.

         %BSAMSIZ(.1,.3,.05,.9);

    Author  : Frank Harrell
    Date    : 13 Nov 85
    Modified: 28 Apr 87 - for SAS/PC

                                                                      */
%MACRO bsamsiz(p1,p2,alpha,power);
DATA _NULL_;
 z=probit(1-&alpha/2); q1=1-&p1; q2=1-&p2; pm=(&p1+&p2)/2; qm=1-pm;
 c=.25*(&p1*q1+&p2*q2); d=.5*abs(&p1-&p2);
      DO n=5 TO 15000;
      ds=.5+z*sqrt(.5*n*pm*qm); ex=d*n; sd=sqrt(n*c);
      power=1-probnorm((ds-ex)/sd)+probnorm((-ds-ex)/sd);
      IF power>=&power THEN DO;
           PUT n= ' yields ' power=;
           STOP;
           END;
      END;
 PUT 'n must be >15000 to achieve the desired power.';
 RUN;
%MEND;

 /*MACRO PROCEDURE DASPLINE

Requires:  Macro DSHIDE.

   For a given list of variables, generates formulas for dummy  variables
   that  allow fitting of Stone and Koo's additive splines constrained to
   be linear in the tails.  If the variables  are  named  A  and  B,  for
   example,  the  generated  dummy  variables  will  be  A1,A2,...,Ap and
   B1,B2,...,Bq, where p and q are the number of  knots  minus  2  (if  a
   variable name is 8 characters long, the last character is ignored when
   forming  dummy  variable names).  The spline models are then fitted by
   specifying as independent variables A A1-Ap B B1-Bq.  If  knot  points
   are  not  specified, NK knots will be selected automatically, where NK
   =3 -7.  The following quantiles are used according to NK:

        NK              Quantiles
        3       .05     .5      .95
        4       .05     .35     .65     .95
        5       .05     .275    .5      .725    .95
        6       .05     .23     .41     .59     .77     .95
        7       .025    .18333  .34166  .5      .65833  .81666  .975

   Stone and Koo (see
   3rd reference below) recommend using the following  quantiles  if  the
   sample  size  is  n:   0, 1/(1+m), .5, 1/(1+1/m), 1, where m is n**.5.
   The second percentile can be derived approximately from the following
   table:

        n     Percentile
       <23      25
     23-152     10
    153-1045     5
      1046+      1

   Instead of letting DASPLINE choose knots, knots may be given for up to
   20 variables by specifying KNOTi=knot points  separated  by  spaces,
   where  i  corresponds  to variable number i in the list.  Formulas for
   dummy variables to compute spline components for variable V are stored
   in macro _V (eighth letter of V is truncated if needed).  Knot  points
   computed  by  DASPLINE or given by the user are stored in global macro
   variables named _knot1_,_knot2_,...

   Usage:

   %DASPLINE(list of variables separated by spaces,
            NK=number of knots to use if KNOTi is not given for variable
                 i (default=4),
            KNOT1=at least 3 knot points, ... KNOT20=knot points,
            DATA=dataset to use for automatic determination of knot points
                 if not given in KNOTi (default=_LAST_) );

        norm=0 : no normalization of constructed variables
        norm=1 : divide by cube of difference in last 2 knots
                 makes all variables unitless
        norm=2 : (default) divide by square of difference in outer knots
                 makes all variables in original units of x

   References:

   Devlin TF, Weeks BJ (1986): Spline functions for logistic regression
   modeling. Proc Eleventh Annual SAS Users Group International.
   Cary NC: SAS Institute, Inc., pp. 646-51.

   Stone CJ, Koo CY (1985): Additive splines in statistics. Proc Stat
   Comp Sect Am Statist Assoc, pp. 45-8.

   Stone CJ (1986): Comment, pp. 312-314, to paper by Hastie T. and
   Tibshirani R. (1986): Generalized additive models. Statist
   Sciences 1:297-318.

   Author  : Frank E. Harrell, Jr.
             Takima West Corporation
             Clinical Biostatistics, Duke University Medical Center
   Date    : 15 July 86
   Modified: 27 Aug  86 - added GLOBAL definitions for _knoti_
             28 Aug  86 - added NORM option
             23 Sep  86 - added %QUOTE to %IF &&knot etc.,OUTER
             24 Sep  86 - tolerance check on knots close to zero
             04 Oct  86 - added SECOND and changed NK default to 5
             19 May  87 - changed NK default to 4
             08 Apr  88 - modified for SAS Version 6
             14 Sep  88 - Added DSHIDE
             03 Jan  90 - modified for UNIX
             10 Apr  90 - modified to use more flexible knots with
                          UNIVARIATE 6.03
             06 May  91 - added more norm options, changed default
             10 May  91 - fixed bug re precedence of <>

                                                                      */
%MACRO DASPLINE(x,nk=4,knot1=,knot2=,knot3=,knot4=,knot5=,knot6=,knot7=,
       knot8=,knot9=,knot10=,knot11=,knot12=,knot13=,knot14=,knot15=,
       knot16=,knot17=,knot18=,knot19=,knot20=,
       norm=2,data=_LAST_);
%LOCAL i j needknot nx lastds v v7 k tk tk1 t t1 k2 low hi slow shi kd;
%LOCAL _e_1 _e_2 _e_3 _e_4 _e_5 _e_6 _e_7 _e_8 _e_9;
%LOCAL _lastds_;
%DSHIDE;
%LET x=%SCAN(&x,1,'"''');
%LET needknot=0; %LET nx=0;
%*Strip off quotes in KNOTs and see if any KNOTS unspecified;
     %DO i=1 %TO 20;
     %IF %SCAN(&x,&i)=  %THEN %GOTO nomorex;
     %LET nx=%EVAL(&nx+1);
     %IF %QUOTE(&&knot&i)=  %THEN %LET needknot=%EVAL(&needknot+1);
     %ELSE %LET knot&i=%SCAN(&&knot&i,1,'"''');
     %END;
%nomorex:
%IF &needknot^=0 %THEN %DO;
  %LET lastds=&sysdsn; %IF &lastds^=_NULL_ %THEN
    %LET lastds=%SCAN(&sysdsn,1).%SCAN(&sysdsn,2);
  RUN;OPTIONS NONOTES;
  PROC UNIVARIATE DATA=&data NOPRINT;VAR
    %DO i=1 %TO &nx;
    %IF %QUOTE(&&knot&i)=  %THEN %SCAN(&x,&i);
    %END;
  ; OUTPUT OUT=_stats_ pctlpts=
        %IF &nk=3 %THEN 5 50 95;
        %IF &nk=4 %THEN 5 35 65 95;
        %IF &nk=5 %THEN 5 27.5 50 72.5 95;
        %IF &nk=6 %THEN 5 23 41 59 77 95;
        %IF &nk=7 %THEN 2.5 18.3333 34.1667 50 65.8333 81.6667 97.5;
   PCTLPRE=x1-x&needknot PCTLNAME=p1-p&nk;
  DATA _NULL_;SET _stats_;
  %*For knot points close to zero, set to zero;
  ARRAY _kp_ _NUMERIC_;DO OVER _kp_;IF ABS(_kp_)<1E-9 THEN _kp_=0;END;
    %LET j=0;
    %DO i=1 %TO &nx;
    %IF %QUOTE(&&knot&i)=  %THEN %DO;
      %LET j=%EVAL(&j+1);
      CALL SYMPUT("knot&i",
      TRIM(LEFT(x&j.p1))
        %DO k=2 %TO &nk;
        ||" "||TRIM(LEFT(x&j.p&k))
        %END;
      );
      %END;
    %END;
  RUN; OPTIONS NOTES _LAST_=&lastds;
  %END;
  %DO i=1 %TO &nx;
  %GLOBAL _knot&i._; %LET _knot&i._=&&knot&i;
  %PUT Knots for %SCAN(&x,&i):&&knot&i;
  %END;
%*Generate code for calculating dummy variables;
  %DO i=1 %TO &nx;
  %LET v=%SCAN(&x,&i); %IF %LENGTH(&v)=8 %THEN %LET v7=%SUBSTR(&v,1,7);
  %ELSE %LET v7=&v;
  %GLOBAL _&v7; %LET _&v7=;
  %*Get no. knots, last knot, next to last knot;
    %DO k=1 %TO 99;
    %IF %QUOTE(%SCAN(&&knot&i,&k,%STR( )))=  %THEN %GOTO nomorek;
    %END;
  %nomorek: %LET k=%EVAL(&k-1); %LET k2=%EVAL(&k-2);
  %LET tk=%SCAN(&&knot&i,&k,%STR( ));
  %LET tk1=%SCAN(&&knot&i,%EVAL(&k-1),%STR( ));
  %LET t1=%SCAN(&&knot&i,1,%STR( ));
  %IF &norm=0 %THEN %LET kd=1;
  %ELSE %IF &norm=1 %THEN %LET kd=(&tk - &tk1);
  %ELSE %LET kd=((&tk - &t1)**.666666666666);
  %LET _e_1=; %LET _e_2=; %LET _e_3=; %LET _e_4=; %LET _e_5=;
  %LET _e_6=; %LET _e_7=; %LET _e_8=; %LET _e_9=;
    %DO j=1 %TO &k2;
    %LET t=%SCAN(&&knot&i,&j,%STR( ));
     %LET
_e_&j=&v7&j=max((&v-&t)/&kd,0)**3+((&tk1-&t)*max((&v-&tk)/&kd,0)**3
        -(&tk-&t)*max((&v-&tk1)/&kd,0)**3)/(&tk-&tk1)%STR(;);
    %END;
  %LET _&v7=&_e_1 &_e_2 &_e_3 &_e_4 &_e_5 &_e_6 &_e_7 &_e_8 &_e_9;
  %END;
OPTIONS _LAST_ = &_lastds_;
%MEND;
  /*  SAS MACRO DSHIDE

Macro procedure used to ensure that the default data set
remains the same after a macro procedure call as it was
prior to the call.  DSHIDE is to be used within another
macro therefore the %LOCAL and OPTIONS statements illustrated
below are very improtant to the use of DSHIDE.

USAGE: Assume DSHIDE is used in a macro called x:

%MACRO x(...parameters......);
            .
            .
  (Statements prior to first data step in Macro X)
            .
            .
%LOCAL _lastds_;
%DSHIDE;
            .
            .
  (Statements until end of Macro X)
            .
            .
OPTIONS _LAST_ = &_lastds_;
%MEND x;

Author: Steve Peck and Frank Harrell
Date  : 3 Aug 88
                                      */

%MACRO DSHIDE;
%LET _lastds_ = &sysdsn;
%IF &_lastds_ ^= _NULL_ %THEN
%IF %SCAN(&sysdsn,2) ^= %THEN %DO;
     %LET _lastds_ = %SCAN(&sysdsn,1).%SCAN(&sysdsn,2); %END;
%ELSE %DO; %LET _lastds_ = %SCAN(&sysdsn,1); %END;
%MEND DSHIDE;
*---------------------------------------------------------------*
 EKMPL -MACRO FOR COMPUTING KAPLAN-MEIER EMPIRICAL SURVIVAL FUNCT
        FOR ANY NUMBER OF GROUPS FOR CASE WHERE SUBJECTS ENTER THE RISK
        SET AT DIFFERENT TIMES.  AUTHOR: FRANK HARRELL 1981.
        Converted to SAS macro language 7/23/91.
        This uses the Mantel-Byar method.
 USAGE: %EKMPL(te,t,d,class,data,out)
        te - time to enter risk set
        t  - failure/censoring time
        d  - event (1)/censoring (0) indicator
        class - subdivide analysis by class variable (not required)
        data - input dataset (default=last created)
        out  - output dataset (default=DATAn)
 OUTPUT VARIABLES:
        survival=KAPLAN-MEIER ESTIMATE stderr=estimated S.E. of log-log
survival
        events=# DEATHS AT TIME t  ktied=# TIMES TIED AT t
        nrisk=# AT RISK AT TIME t
*----------------------------------------------------------------;
%MACRO ekmpl(te,t,d,class,data=_LAST_,out=_DATA_);
DATA &out;SET &data(KEEP=&class &te &t &d);IF &t+&te+&d>.;
%IF &class=  %THEN %DO;
    %LET class=_class_; RETAIN _class_ 1; LENGTH _class_ 3;
    %END;
OUTPUT;&t=&te;&d=-1;OUTPUT;
PROC SORT;BY &class &t &d;
*COMPUTE ESTIMATE AT EACH EVENT;
DATA &out;RETAIN;SET;BY &class &t;
_FT_=FIRST.&t;_LT_=LAST.&t;DROP _FT_ _LT_;
*NOTE:NEXT SET STATEMENT DESTROYS FIRST.&t & LAST.&t;
IF FIRST.&class=0 THEN GO TO NOTFIRST;
nrisk=0;survival=1;_SV_=0;DROP _SV_;
*OUTPUT RECORD CONTAINING &t=0 survival=1 TO START SURVIVAL CURVE;
_THOLD_=&t;&t=0; events=0;ktied=0;stderr=.;OUTPUT;&t=_THOLD_;
DROP _THOLD_;
*COUNT # DEATHS AT TIME &t & NO. TIMES TIED AT &t;
NOTFIRST: IF _FT_ THEN events=0;IF _FT_ THEN ktied=0;
IF &d=-1 THEN nrisk=nrisk+1;ELSE DO;events=events+&d;ktied=ktied+1;END;
IF _LT_; *WAIT FOR LAST &t BEFORE OUTPUTTING;
IF events=0 THEN nrisk=nrisk-ktied; IF events=0 THEN RETURN;
*ESTIMATE CHANGES ONLY AT A DEATH;
survival=survival*(1-events/nrisk);_SV_=_SV_+events/(nrisk-events)/nrisk;
stderr=-sqrt(_SV_)/log(survival);
OUTPUT;nrisk=nrisk-ktied;
LENGTH DEFAULT=4;
LABEL survival="Mantel-Byar Estimate" stderr="S.E. of log[-log survival]";
KEEP &class &t survival stderr events ktied nrisk;
%MEND;
 /* SAS Macro EMPTREND

REQUIRES DSHIDE, AXISSPEC

Macro procedure to display empirical trends of a dependent  variable  (Y)
vs.   an independent variable (X).  The data can optionally be grouped by
an additional classification variable (CLASS, omit  if  not  used).   For
each  CLASS  group, X is first rounded to the nearest ROUND, grouped into
GROUPS quantile groups, or ordered by X and grouped into  subsets  having
at  least N observations.  (ROUND, GROUPS, and N are mutually exclusive).
If the number of observations in a class, say Nc, is not a multiple of N,
N is replaced by Nc/FLOOR(Nc/N), and if there are <NMIN observations left
over in the last group, the last group is ignored.  For each X group, the
mean X and mean (median if option MEDIAN is given) Y are  computed.   The
mean or median Y is displayed versus the mean X in the interval.  The X-Y
coordinates  may  optionally  be stored in a dataset OUT (omit OUT for no
output).  No estimates are made for any  group  having  fewer  than  NMIN
observations.   The default value for NMIN is 10.  Code NMIN=0 to get all
estimates.  The estimates are printed if option PRINT is  specified.   If
option  LOGIT  is  specified,  the  logit  (log(P/(1-P)))  of  cell means
(assumed to be cell proportions) is also computed and  plotted,  assuming
that  option MEDIAN is not given.  If CROUND is given, the class variable
is first rounded to the nearest CROUND, or if CGROUPS is given, the class
variable is first grouped into  CGROUPS  quantile  groups.   Quantile  or
N-groups for X are figured separately for each class of observations.  If
N  is  given  and  there  are  ties on the X variable, tied values may be
distributed between two or more groups.  This  will  be  done  at  random
since the data are sorted by a random number after being sorted by X.  To
perform  all operations on a series of independent or dependent variables
(or both), substitute a list of variables for  X  and/or  Y  enclosed  in
single  or  double  quotes.   When  a  list is given for both X and Y, an
analysis is performed for each possible pairing of an X with a Y.   If  Y
is  an  ordinal variable having values 0,1,...,K, use the K= parameter to
obtain all proportions Y>=1,Y>=2,...,Y>=K.  The LOGIT  option  will  also
compute  and plot the logits of these cumulative proportions, to visually
check the assumptions of the ordinal logistic model.   If  PLOT=3,  plots
will be made using SAS/GRAPH procedure GPLOT in addition using PROC PLOT.
If  PLOT=2, PROC GPLOT will be used but PROC PLOT output will not appear.
The default is PLOT=1, printer output only.  If PLOT>1 and FONT is given,
the specified font will be used in the major titles  of  the  graph.   If
FONT  is  not  given, EMPTREND will use the TRIPLEX, TITALIC, and COMPLEX
fonts.  If PLOT=0, no plots will be made.  If PLOT>1 and a CLASS variable
is given, you can specify LLABEL="any label" to use your own legend label
for  the  CLASS  variable.   By  default,  no  label  appears.    Specify
HAXIS="low  to  high  by  inc"  or VAXIS="low to high by inc" to override
default axis scaling from PROC PLOT or PROC GPLOT.

Usage:

%EMPTREND(X,Y,DATA=name of input dataset (default=_LAST_),
         CLASS=,ROUND=,GROUPS=,N=,K=,CROUND=,CGROUPS=,NMIN=,OUT=,
         MEDIAN=1,PRINT=1,LOGIT=1,PLOT=,HAXIS=,VAXIS=,FONT=,LLABEL=);

Note:

EMPTREND does not use the first title line (TITLE1 or  TITLE).   This  is
reserved  for  the  user.   The AXISSPEC macro is invoked to compute nice
axis limits for plotting if PLOT>1 and HAXIS or VAXIS is omitted.

Author   :Frank Harrell
Date     :15Jun82
Modified :24Jun86
          30Jul86 - added back H=1.3 in LEGEND VALUE since SAS bug fixed
          17Sep86 - added use of AXISSPEC macro
          10Apr88 - modified for SAS Version 6
          21APR89 - added DSHIDE-STEVE PECK
          31May90 - fix bug in MEDIAN
          02Jan90 - removed quote from comment
          09Sep91 - changed plot default to 2
                      */

%MACRO EMPTREND(XX,YY,DATA=_LAST_,CLASS=,ROUND=,GROUPS=,CROUND=,CGROUPS=,
         N=,MEDIAN=0,NMIN=10,K=1,LOGIT=0,PRINT=0,OUT=,PLOT=2,
         HAXIS=,VAXIS=,SASGRAPH=0,FONT=,LLABEL=NONE,DEBUG=0);
%LOCAL X Y JX JY YLIST VARNAME ISUB FF;
%LET XX=%SCAN(&XX,1,'"''');  %LET YY=%SCAN(&YY,1,'"''');
%LET haxis=%SCAN(&haxis,1,'"'''); %LET vaxis=%SCAN(&vaxis,1,'"''');
%IF &CLASS^=  %THEN %LET CLASS=%UPCASE(&CLASS);
RUN; %LOCAL _lastds_;
%DSHIDE;
%IF &sasgraph=1 %THEN %LET plot=2; %*Obsolete parameter;
DATA _MAIN_;SET &DATA(KEEP=&XX &YY &CLASS);
%IF &DEBUG=0 %THEN %DO; OPTIONS NONOTES; %END;
%LET JY=1;  %LET Y=%SCAN(&YY,1);
%DO %WHILE(&Y^= );
%LET JX=1;   %LET X=%SCAN(&XX,1);
%DO %WHILE(&X^= );
%LET X=%UPCASE(&X);  %LET Y=%UPCASE(&Y);
DATA _STATS_;SET _MAIN_(KEEP=&X &Y &CLASS);
 /*
IF _N_=1 THEN DO; LENGTH _lab_ $ 40;
 CALL LABEL(&x,_lab_); CALL SYMPUT("_xlabel_",_lab_);
 CALL LABEL(&y,_lab_); CALL SYMPUT("_ylabel_",_lab_);  END;
 */
IF &X+&Y>.;
%LET YLIST=&Y; %IF &K^=1 %THEN %DO;
     %LET YLIST=_Y_1-_Y_&K;
     LENGTH &YLIST 2; ARRAY _Y_ &YLIST;
     DO OVER _Y_;_Y_=&Y>=_I_;END;
     %END;
%IF &N^=  %THEN %DO;
     LENGTH _U_ 4;_U_=UNIFORM(0);
     %END;
%IF &ROUND^=   %THEN %DO;_GX_=ROUND(&X,&ROUND);%END;
%IF &CROUND^=  %THEN %DO;IF &CLASS>.;&CLASS=ROUND(&CLASS,&CROUND);%END;
%IF &CGROUPS^=  %THEN %DO;
     IF &CLASS>.;
     PROC RANK DATA=_STATS_(RENAME=(&CLASS=_C_)) OUT=_STATS_
          GROUPS=&CGROUPS;VAR _C_;RANKS &CLASS;
     PROC SUMMARY;CLASS &CLASS;VAR _C_;
     OUTPUT OUT=_STATS2_ N=N MEAN=_MEANC_ MIN=_MINC_ MAX=_MAXC_;
     DATA _STATS2_;SET;IF &CLASS^=.;
     PROC PRINT LABEL SPLIT='/';ID N;VAR &CLASS _MINC_ _MAXC_ _MEANC_;
     LABEL N="N" &CLASS="Quantile/Group" _MINC_="Minimum/&CLASS"
           _MAXC_="Maximum/&CLASS" _MEANC_="Mean/&CLASS";
     TITLE2 "Quantile Groups for class variable &CLASS";
     %END;
PROC SORT DATA=_STATS_;BY &CLASS &X
%IF &N^=  %THEN %DO; _U_   %END;
   ;
%IF &GROUPS^=   %THEN %DO;
     PROC RANK OUT=_STATS_ GROUPS=&GROUPS;VAR &X;RANKS _GX_;
     %IF &CLASS^=  %THEN %DO;BY &CLASS;%END;
     %END;
%IF &N^=  %THEN %DO;
     PROC MEANS DATA=_STATS_ NOPRINT;VAR &X;
     %IF &CLASS^=  %THEN %DO; BY &CLASS; %END;
     OUTPUT OUT=_STATS2_ N=_NCLASS_;
     DATA _STATS_; DROP _U_;
     %IF &CLASS=  %THEN %DO;
          RETAIN _NCLASS_;IF _N_=1 THEN SET _STATS2_;RETAIN _NN_ 0;DROP
_NN_;
          SET _STATS_;
          %END;
     %ELSE %DO;
          MERGE _STATS_ _STATS2_;BY &CLASS;RETAIN _NN_;DROP _NN_;
          IF FIRST.&CLASS THEN _NN_=0;
          %END;
     _NN_=_NN_+1;
     _GX_=FLOOR(.0000001+_NN_/(_NCLASS_/FLOOR(_NCLASS_/&N)));
     %END;
%IF &MEDIAN=0  %THEN %DO;PROC MEANS NOPRINT;VAR &X &YLIST;
     BY &CLASS _GX_;OUTPUT OUT=_STATS_ N=N MEAN=&X &YLIST MIN=MINX MAX=MAXX;
     %END;
%ELSE %DO;
   PROC UNIVARIATE NOPRINT;BY &CLASS _GX_;VAR &X &YLIST;
   OUTPUT OUT=_STATS_ N=N MEAN=&X MEDIAN=_JUNK_ &YLIST
          MIN=MINX MAX=MAXX;
   DATA _stats_;SET _stats_(DROP=_junk_); *Bug in SAS 6.03 cant drop above;
   %END;
%IF &logit=1 | &nmin^=0 | (&plot>1 & (&haxis=  | &vaxis= )) %THEN %DO;
 DATA _STATS_;SET _STATS_ END=_eof_;
 %IF &NMIN^=0 %THEN %DO;IF N<&NMIN THEN &x=.;%END;
 %IF &LOGIT=1 %THEN %DO;
      %IF &K=1 %THEN %DO;
           LOGIT=LOG(&Y/(1-&Y)); %END;
      %ELSE %DO;
           ARRAY LOGIT LOGIT1-LOGIT&K; ARRAY _Y_ _Y_1-_Y_&K;
           DO OVER LOGIT;LOGIT=LOG(_Y_/(1-_Y_)); END;
           %END;
      %END;
 %IF &plot>1 & (&haxis= | &vaxis= ) %THEN %DO;
  %IF &k=1 %THEN %DO; %AXISSPEC(VAR="&x &y", END=_eof_); %END;
  %ELSE %DO;
   DROP _yy_;_yy_=_y_1; %AXISSPEC(VAR="&x _yy_");
   _yy_=_y_&k; %AXISSPEC(END=_eof_);
   %END;
  %END;
 %END;
%IF &MEDIAN=0  %THEN %LET STAT=Mean; %ELSE %LET STAT=Median;
%IF &LOGIT=1 %THEN %LET STAT=Proportion of;
%LET FF=TRIPLEX; %IF &FONT^=  %THEN %LET FF=&FONT;
%IF &K=1 %THEN %DO;
     TITLE2 H=1.6 F=&FF "&STAT &Y vs. &X"; %END;
%ELSE %DO; TITLE2 H=1.6 F=&FF "Proportions of &Y>=j (j=1-&K) vs. &X";
     %END;
%LET FF=TITALIC; %IF &FONT^=  %THEN %LET FF=&FONT;
%IF &ROUND^=  %THEN %DO;
     TITLE3 H=1.4 F=&FF "Intervals of &X Rounded to the nearest &ROUND";
     %END;
%ELSE %IF &GROUPS^=  %THEN %DO;
     TITLE3 H=1.4 F=&FF "&X Grouped Into &GROUPS Quantile Groups"; %END;
%ELSE %DO;
TITLE3 H=1.4 F=&FF &X "Grouped Into Intervals Having At Least &N
Observations"
;
     %END;
%LET FF=COMPLEX; %IF &FONT^=  %THEN %LET FF=&FONT;
%IF &CROUND^=  %THEN %DO;
     TITLE4 H=1.2 F=&FF "&CLASS Rounded to the Nearest &CROUND";
     %END;
%IF &CGROUPS^=  %THEN %DO;
     TITLE4 H=1.2 F=&FF "&CLASS Grouped into &CGROUPS Quantile Groups";
     %END;
%IF &PRINT=1 %THEN %DO;
     %IF &LOGIT=1 %THEN %DO;
          %IF &K=1 %THEN %LET VARNAME=LOGIT;
          %ELSE %LET VARNAME=LOGIT1-LOGIT&K;
          %END;
     %ELSE %LET VARNAME= ;
     PROC PRINT LABEL SPLIT='/';ID N;
     %IF &CLASS=   %THEN %DO;VAR MINX MAXX &X &YLIST &VARNAME; %END;
     %ELSE %DO; BY &CLASS;VAR MINX MAXX &X &YLIST &VARNAME; %END;
     LABEL N="n" &X="Mean/&X"  MINX="Minimum/&X"  MAXX="Maximum/&X"
     %IF &K=1 %THEN %DO;
          &Y="&STAT/&Y"
          %END;
     %ELSE %DO ISUB=1 %TO &K;
          _Y_&ISUB="Proportion/&Y>=&ISUB"
          %END;
     %IF &CLASS^=   %THEN %DO; &CLASS="&CLASS"  %END;
     ;
     %END;
%IF &plot=1 | &plot=3 %THEN %DO;
     PROC PLOT;PLOT
     %IF &CLASS=  %THEN %DO;
          %IF &K=1 %THEN &Y*&X;
          %ELSE %DO ISUB=1 %TO &K;
               _Y_&ISUB*&X="&ISUB"
               %END;
          %END;
     %ELSE (&YLIST)*&X=&CLASS;
     %IF &k^=1 | &haxis^=  | &vaxis^=  %THEN /;
     %IF &haxis^=  %THEN HAXIS=&haxis;
     %IF &vaxis^=  %THEN VAXIS=&vaxis;
     %IF &K^=1 %THEN OVERLAY;
     ;
     %IF K=1 %THEN %DO; /* LABEL &x="&_xlabel_" &y="&_ylabel_"; */ %END;
     %IF &LOGIT=1 %THEN %DO;
          PROC PLOT;PLOT
          %IF &CLASS=  %THEN %DO;
               %IF &K=1 %THEN LOGIT*&X;
               %ELSE %DO ISUB=1 %TO &K;
                    LOGIT&ISUB*&X="&ISUB"
                    %END;
               %END;
          %ELSE %DO;
               %IF &K=1 %THEN LOGIT*&X=&CLASS;
               %ELSE (LOGIT1-LOGIT&K)*&X=&CLASS;
               %END;
          %IF &K^=1 %THEN %DO; /OVERLAY %END;
           ;
          TITLE5 "Using Logit Transformation of Proportions of &Y";
          RUN;TITLE5 ;
          %END;
     %END;
%IF &plot>1 %THEN %DO;
     SYMBOL1 I=JOIN V=PLUS L=1;SYMBOL2 I=JOIN V=X L=2;
     SYMBOL3 I=JOIN V=STAR L=3;SYMBOL4 I=JOIN V=SQUARE L=4;
     SYMBOL5 I=JOIN V=DIAMOND L=5;SYMBOL6 I=JOIN V=TRIANGLE L=6;
     SYMBOL7 I=JOIN V=HASH L=7;SYMBOL8 I=JOIN V=Y L=8;
     SYMBOL9 I=JOIN V=$ L=9;SYMBOL10 I=JOIN V=- L=10;
     SYMBOL11 I=JOIN V=_ L=11;SYMBOL12 I=JOIN V== L=12;
     SYMBOL13 I=JOIN V=% L=13;SYMBOL14 I=JOIN V=+ L=14;
     SYMBOL15 I=JOIN V=: L=15;
     PROC GPLOT;PLOT (&YLIST)*&X
     %IF &CLASS^=   %THEN %DO; =&CLASS  %END;
     /  %IF &K^=1 %THEN OVERLAY;
     HAXIS=AXIS1 VAXIS=AXIS2 LEGEND=LEGEND;
     AXIS1 VALUE=(H=1.2 F=duplex) LABEL=(H=1.3 F=COMPLEX)
     %IF &haxis^=  %THEN ORDER=&haxis;
     %ELSE ORDER=&spec1;
     ;
     AXIS2 VALUE=(H=1.2 F=duplex) LABEL=(H=1.3 F=complex A=90 R=0)
     %IF &vaxis^=  %THEN ORDER=&vaxis;
     %ELSE ORDER=&spec2;
     ;
     %IF &K=1 %THEN %DO;
      /* LABEL &x="&_xlabel_" &y="&_ylabel_"; */ %END;
     LEGEND VALUE=(H=1.3 F=complex) FRAME LABEL=
     %IF &llabel=NONE %THEN NONE;
     %ELSE (H=1.3 F=complex &llabel); ;
     %IF &LOGIT=1 %THEN %DO;
          %IF &K=1 %THEN %DO;
               PROC GPLOT;PLOT LOGIT*&X
               %END;
          %ELSE %DO;
               PROC GPLOT;PLOT (LOGIT1-LOGIT&K)*&X
               %END;
          %IF &CLASS^=   %THEN %DO; =&CLASS  %END;
          /   %IF &K^=1 %THEN OVERLAY;
          HAXIS=AXIS1 VAXIS=AXIS3 LEGEND=LEGEND;
          AXIS3 VALUE=(H=1.2 F=duplex) LABEL=(H=1.3 F=complex A=90 R=0);
          %LET FF=DUPLEX; %IF &FONT^=  %THEN %LET FF=&FONT;
          TITLE5 H=1 F=&FF "Using Logit Transformation of Proportions of
&Y";
          RUN;TITLE5 ;
          %END;
     %END;
%IF &OUT^=   %THEN %DO; DATA &OUT;SET _STATS_; %END;
RUN;TITLE2;
%LET JX=%EVAL(&JX+1);  %LET X=%SCAN(&XX,&JX);
%END;
%LET JY=%EVAL(&JY+1);  %LET Y=%SCAN(&YY,&JY);
%END;
%IF &DEBUG=0 %THEN %DO; OPTIONS NOTES; %END;
OPTIONS _LAST_=&_lastds_;
%MEND;
/* SAS Macro Procedure INTRVALS - Generate Specs for Interval Grouping

   Given a set of left interval endpoints, generates  specifications  for
   use  with  the  VALUE  statement in PROC FORMAT for grouping a numeric
   variable into intervals.  If for example the endpoints  are  10,20,30,
   the   following   intervals   are   generated:   <10,  10-19.99999999,
   20-29.9999999, 30+.

   Usage: PROC FORMAT;
          VALUE xint %INTRVALS(c1,c2,c3,...); *Specify up to 20 endpoints;
          PROC FREQ;TABLE x;FORMAT x xint.;

   Note : Requires SAS Version 5 or later

   Author  : Frank Harrell
   Date    : 25 Sep 86
   Modified: 15 May 88 - Added documentation for SAS Version 6
                                                                       */
%MACRO INTRVALS(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,
                c16,c17,c18,c19,c20);
%LOCAL i j;
%DO i=0 %TO 20;
    %LET j=%EVAL(&i+1);
    %IF &i=0 %THEN LOW-<&c1="<&c1";
    %ELSE %IF &&c&i=  %THEN %GOTO nomore;
    %ELSE %IF &i<20 %THEN %IF &&c&j^=  %THEN &&c&i-<&&c&j="&&c&i- <&&c&j";
    %ELSE &&c&i-HIGH="&&c&i+";
    %END;
%nomore:
%MEND;
 /* SAS MACRO PROCEDURE KMPL

Requires:  Macro DSHIDE.

SAS macro procedure to calculate the Kaplan-Meier product-limit
survival estimates, standard errors, and 1-ALPHA confidence limits.
The estimates are placed in a dataset for further processing and
by default are plotted using PROC PLOT. Estimates are contained in
variables named SURVIVAL, STDERR, SURV_L, SURV_U, LOGLOG_S.
LOGLOG_S is log[-log(SURVIVAL)] and STDERR is the estimated standard
error of LOGLOG_S.  SURV_L and SURV_U are confidence limits for
survival based on LOGLOG_S. Also computes NRISK (number of subjects
are risk at current time) and NEVENT, number of events at current time.

Usage:

%KMPL    (TIME=time to event or last follow-up (required)              ,
          EVENT=event indicator (required)
                    1=event occurred at TIME
                    0=last follow-up is at TIME (e.g. censored)        ,
          DATA=input dataset name (default=last dataset created)       ,
          CLASS=list of classification variables (default=none)        ,
          OUT=output dataset name (default=DATAn                       ,
          PLOT=  0 (no plot), 1 (PROC PLOT output),
                 2 (PROC GPLOT output, default), 3 (Both PROCs PLOT &
GPLOT),
          ALPHA= type I error rate for confidence limits (default=.05)
          )

Note:     OUT contains one observation for each unique uncensored TIME
          point plus one observation for TIME 0 and one observation for
          the maximum TIME observed, for each block processed.  It will
          also contain the variables SURVIVAL, STDERR, NRISK, NEVENT,
          SURV_L, and SURV_U as well as the dependent TIME variable
          and the CLASS variables.

Author   :Frank Harrell and Mike Helms
Date     :June 1983
Last Mod :11 Apr 88  (Converted to PC SAS by F. H., added PLOT
                      parameter and C.L., hard-wired var. names)
          26 Sep 88  (Added PROC GPLOT by LHM).
          14 Sep 88 - Added DSHIDE
          23 Jun 91 - Removed commend about class in quotes, added LOGLOG_S,
                        fixed lastds
          23 Jul 91 - Fixed comments about output dataset
          09 Sep 91 - Changed plot default to 2
          27 Apr 92 - Added QUIT after GPLOT
          30 Apr 92 - QUIT fixed
          17 Sep 93 - Fixed STDERR, conf. limits to really use log-log S
                                                                 */
%MACRO KMPL(TIME= , EVENT= , DATA=_LAST_, CLASS= , OUT=_DATA_,
            PLOT=2, ALPHA=.05);
 /*       Working Variables.                                    */
 /*       _ft_      First.TIME                                  */
 /*       _lt_      Last.TIME                                   */
 /*       _kt_      # censored or had events occur since        */
 /*                      last TIME                              */
 /*       _sv_      Survival estimate variance                  */
 /*       _thold_   temp storage of TIME                        */
 /*       _w_       used for C.L.                               */
RUN;
%LOCAL J V LAST _lastds_ BY; %LET BY=;
%DSHIDE;
%IF &CLASS^=  %THEN %DO;      /*  CLASS variables present  */
  %LET BY=BY;
  %LET CLASS=%SCAN(&CLASS,1,'"''');
  %DO J=1 %TO 50 %BY 1;    /*  find last CLASS variable  */
    %LET V=%SCAN(&CLASS,&J);
    %IF &V^=  %THEN %LET LAST=&V; %ELSE %GOTO NEXT;
  %END;
%NEXT:
%END;
PROC SORT DATA=&DATA OUT=_TMP_; BY &CLASS &TIME;
PROC MEANS NOPRINT DATA=_TMP_; VAR &TIME; &BY &CLASS;
OUTPUT OUT=_COUNTS_ N=NRISK;
DATA &OUT; RETAIN; SET _TMP_; BY &CLASS &TIME;
_FT_=FIRST.&TIME; _LT_=LAST.&TIME; DROP _FT_ _LT_;
%IF &CLASS^=  %THEN %DO; IF FIRST.&LAST=0 THEN GO TO NOTFIRST; %END;
  %ELSE %DO; IF _N_>1 THEN GO TO NOTFIRST; %END;
LENGTH nrisk 4;
SET _COUNTS_;
SURVIVAL=1; _SV_=0; DROP _SV_;
_THOLD_=&TIME; &TIME=0;  NEVENT=0; _KT_=0; STDERR=.; surv_l=1; surv_u=1;
   OUTPUT;
&TIME=_THOLD_;
DROP _THOLD_; NOTFIRST:IF &TIME>.Z;
IF _FT_ THEN DO; NEVENT=0; _KT_=0; END;
NEVENT=NEVENT+&EVENT; _KT_=_KT_+1;
IF _LT_;
%IF &CLASS^=  %THEN %DO;
IF NEVENT=0 & LAST.&LAST=0 THEN DO; NRISK=NRISK-_KT_; RETURN; END;
%END;
%ELSE %DO; IF NEVENT=0 & (NRISK-_KT_)>0 THEN DO; NRISK=NRISK-_KT_;
           RETURN; END;
%END;
SURVIVAL=SURVIVAL*(1-NEVENT/NRISK); LOGLOG_S=log(-log(survival));
IF nrisk<=nevent THEN _sv_=.;
ELSE _SV_=_SV_+NEVENT/(NRISK-NEVENT)/NRISK;
stderr=-sqrt(_SV_)/log(SURVIVAL);
_w_=PROBIT(1-&alpha/2)*stderr;
IF stderr=. THEN DO; surv_l=.; surv_u=.; END;
ELSE DO;
 surv_l=survival**exp(_w_); surv_u=survival**exp(-_w_);
 END;
IF SURVIVAL=1 THEN DO; surv_l=1; surv_u=1; END;
OUTPUT; NRISK=NRISK-_KT_;
LENGTH DEFAULT=4;
LABEL SURVIVAL="Kaplan-Meier Survival Estimate"
      LOGLOG_S="Estimate of log(-log(Survival))"
      STDERR="Estimated Std. Error of SURVIVAL"
      SURV_L  ="Lower Confidence Limit for SURVIVAL"
      SURV_U  ="Upper Confidence Limit for SURVIVAL"
      NRISK="Number at Risk at time &TIME"
      NEVENT="Number of Events at time &TIME";
KEEP &CLASS &TIME SURVIVAL LOGLOG_S STDERR surv_l surv_u NEVENT NRISK;
RUN;
%IF &plot=1 | &plot=3 %THEN %DO;
 PROC PLOT; PLOT
 %IF &class=  %THEN survival*&time="*" surv_l*&time="."
                    surv_u*&time="." ;
 %ELSE survival*&time=&class surv_l*&time=&class surv_u*&time=&class ;
     /OVERLAY;  RUN;
 %END;
RUN;
%IF &plot>1 %THEN %DO;
     SYMBOL1 I=STEPLJ V=PLUS L=1; SYMBOL2 I=STEPLJ V=X L=2;
     SYMBOL3 I=STEPLJ V=STAR L=3; SYMBOL4 I=STEPLJ V=SQUARE L=4;
     SYMBOL5 I=STEPLJ V=DIAMOND L=5; SYMBOL6 I=STEPLJ V=TRIANGLE L=6;
     SYMBOL7 I=STEPLJ V=HASH L=7; SYMBOL8 I=STEPLJ V=Y L=8;
     SYMBOL9 I=STEPLJ V=$ L=9; SYMBOL10 I=STEPLJ V=- L=10;
     SYMBOL11 I=STEPLJ V=_ L=11; SYMBOL12 I=STEPLJ V== L=12;
     SYMBOL13 I=STEPLJ V=% L=13; SYMBOL14 I=STEPLJ V=+ L=14;
     SYMBOL15 I=STEPLJ V=: L=15;
 PROC GPLOT; PLOT
 %IF &class=  %THEN survival
                    *&time ;
 %ELSE survival*&time=&class ;
     ;  RUN; QUIT;
 /* -LHM I couldn't get all the plots on one page. 9/26/88;
 %IF &class=  %THEN (survival surv_l
                    surv_u)*&time ;
 %ELSE survival*&time=&class surv_l*&time=&class surv_u*&time=&class ;
     ;  RUN;
 */
 %END;
RUN;
RUN;
OPTIONS NOTES _LAST_=&_lastds_;
%MEND KMPL;
%MACRO LOGRANK(DATA=_LAST_,T=,EVENT=,CLASS=);
%LOCAL _lastds_;
%DSHIDE;
DATA _temp_;SET &data(KEEP=&T &EVENT &CLASS);
IF &t+&event+&class>.;
PROC SORT;BY DESCENDING &t;
DATA _NULL_;SET _temp_ END=_eof_;BY DESCENDING &t;
RETAIN oecum 0 vcum 0 d0 0 d1 0 nr0 0 nr1 0;
IF first.&t THEN DO;
     d0=0; d1=0;
     END;
IF &class=0 THEN DO;
     d0=d0+&event; nr0=nr0+1;
     END;
ELSE DO;
     d1=d1+&event; nr1=nr1+1;
     END;
IF last.&t THEN DO;
     rd=d0+d1; rs=nr0+nr1-rd;
     n=nr0+nr1;
     oecum=oecum+d0-rd*nr0/n; IF n>1 THEN
vcum=vcum+rd*rs*nr0*nr1/n/n/(n-1);
     END;
IF _eof_ THEN DO;
     chisq=oecum*oecum/vcum; p=1-probchi(chisq,1);
     PUT "Logrank Statistics for T=&t EVENT=&event:";
     PUT nr0= nr1= oecum= vcum= chisq= p=;
     END;
RUN;
OPTIONS _LAST_ = &_lastds_;
%MEND;
 /*-------------------------------------------------------------*
 MBPL -MACRO FOR COMPUTING Mantel-Byar EMPIRICAL SURVIVAL FUNCTION
        which is an adaptation of the Kaplen-Meier product-limit estimate
        FOR ANY NUMBER OF GROUPS FOR CASE WHERE SUBJECTS ENTER THE RISK
        SET AT DIFFERENT TIMES.
        Reference:JASA 69:81-6, 1974
 USAGE: %MBPL(t,d,te,class=,data=,out=);
         T :NAME OF SURVIVAL TIME VARIABLE
            (MEASURED FROM 0, NOT FROM TE)
         D :NAME OF CENSORING INDICATOR
            (0=RIGHT CENSORED,1=UNCENSORED)
         TE:VARIABLE CONTAINING TIME TO ENTER RISK
         CLASS: optional stratification VARIABLE %
         DATA : input dataset (default=_LAST_)
         OUT  : output dataset (default=_out_)
                will contain 1 obs/event/group
 OUTPUT VARIABLES:
        _surv_=Survival ESTIMATE _SE_=ITS ESTIMATED STD. ERROR
        _M_=# DEATHS AT TIME t  _KT_=# TIMES TIED AT t
        _NR_=# AT RISK AT TIME t
 Author: Frank Harrell
 Date  : 1981
 Mod   : 6Sep88 re-written old-stype macro EKMPL in SAS macro language
*----------------------------------------------------------------*/
%MACRO MBPL(t,d,te,class,data=_LAST_,out=_out_);
DATA &out;SET &data;IF &T + &TE + &d >.;
%IF &class=  %THEN %DO; %LET class=_class_; _class_=1; %END;
OUTPUT;&T=&TE;&D=-1;OUTPUT;
PROC SORT;BY &CLASS &T &D;
*COMPUTE ESTIMATE AT EACH EVENT;
DATA &out;RETAIN;SET;BY &CLASS &T;
_FT_=FIRST.&T;_LT_=LAST.&T;DROP _FT_ _LT_;
*NOTE:NEXT SET STATEMENT DESTROYS FIRST.&T &LAST.&T;
IF FIRST.&CLASS=0 THEN GO TO NOTFIRST;
_NR_=0;_surv_=1;_SV_=0;DROP _SV_;
*OUTPUT RECORD CONTAINING T=0 _surv_=1 TO START SURVIVAL CURVE;
_THOLD_=&T;&T=0; _M_=0;_KT_=0;_SE_=.;OUTPUT;&T=_THOLD_;
DROP _THOLD_;
*COUNT # DEATHS AT TIME T & NO. TIMES TIED AT T;
NOTFIRST: IF _FT_ THEN _M_=0;IF _FT_ THEN _KT_=0;
IF &D=-1 THEN _NR_=_NR_+1;ELSE DO;_M_=_M_+&D;_KT_=_KT_+1;END;
IF _LT_; *WAIT FOR LAST T BEFORE OUTPUTTING;
IF _M_=0 THEN _NR_=_NR_-_KT_; IF _M_=0 THEN RETURN;
*ESTIMATE CHANGES ONLY AT A DEATH;
_surv_=_surv_*(1-_M_/_NR_);_SV_=_SV_+_M_/(_NR_-_M_)/_NR_;
_SE_=SQRT(_surv_*_surv_*_SV_);OUTPUT;_NR_=_NR_-_KT_;
LENGTH DEFAULT=4;
LABEL _surv_="Mantel-Byar Estimate" _SE_="ESTIMATED STD. ERROR OF _surv_";
KEEP &CLASS &T _surv_ _SE_ _M_ _KT_ _NR_;
%MEND;
 /* SAS Macro PLOTHR

Requires: Macro AXISSPEC (if PLOT > 1),
          Macro DSHIDE.

Macro procedure to plot the  log  hazard  ratio  (and  its  95%  confidence
limits)  vs.   time  interval for a single covariate.  Using the Cox model,
the log hazard ratio is estimated using the PHGLM  procedure  by  censoring
all  events  that occur after the upper interval endpoint and excluding all
observations corresponding to survival  times  before  the  lower  interval
endpoint.  The abscissa used for plotting is the left endpoint.  The hazard
ratio   statistics,  number  of  observations,  and  number  of  uncensored
observations are printed by default.

Usage:

     %PLOTHR(X=predictor variable, TIME=time var, EVENT=event indicator,
            DATA=input dataset (default=_LAST_)                        ,
            OUT=output dataset (default=_OUT_)                         ,
            TIMEPTS=time points separated by blanks                    ,
            ADJ=covariates to adjust for                               ,
            EVENTS=mininum number of events in an interval to use for
plotting,
                   (default=10)                                        ,
            NOPRINT to suppress printing of results                    ,
            PLOT=plotting option
                  1=line printer
                  2=graphics device using SAS/GRAPH PROC GPLOT (default)
                  3=both line printer and graphics device              ,
            HAXIS= optional X-axis plotting specs                      ,
            TIES=handling of ties in PROC PHREG (default=EFRON)
);

Example: To plot the log hazard ratio for blood pressure in the time
intervals
0,3), 3,6), 6,9), 9,12), 12,infinity) use

     %PLOTHR(X=bp,TIME=d_time,EVENT=death,TIMEPTS= 3 6 9 12 );

Note: Title line 1 is reserved for the user.
      PLOTHR uses TITLE lines 2 and 3 and FOOTNOTES 1 and 2.
      If PLOT>1, invokes the AXISSPEC macro to determine axis specs.
      for PROC GPLOT (HAXIS will override the x-axis specs).

Author   : Frank Harrell
           Duke University Medical Center and Takima West Corporation
Date     : 20 Jan 86
Modified : 16 Jul 86 (fixed delim. for %SCAN)
           15 Sep 86 (added PLOT and ADJ parms, enhanced GPLOT output)
           17 Sep 86 (added invocation of AXISSPEC macro)
            3 Mar 87 (changed variable PERIOD to _PERIOD_)
           10 Oct 87 (added HAXIS parameter)
           27 Jun 88 (added NEW option to PROC PRINTTO call)
           05 Aug 88 (added DSHIDE)
           30 May 91 (converted to Version 6.06 using PROC PHREG, added
TIES)
            9 Sep 91 (changed plot default to 2)

  */

%MACRO PLOTHR(x=,time=,event=,data=_LAST_,out=_OUT_,timepts=,adj=,
      events=10,noprint=0,plot=2,sasgraph=0,haxis=,ties=EFRON);
%LOCAL nc nc1;
%LET x=%UPCASE(&x); %LET time=%UPCASE(&time); %LET event=%UPCASE(&event);
%LET timepts=%SCAN(&timepts,1,'"''');
%LET adj=%SCAN(&adj,1,'"''');
%LET haxis=%SCAN(&haxis,1,'"''');
%IF &sasgraph=1 %THEN %LET plot=3;
%LET nc=0;
%IF &timepts^=  %THEN %DO %WHILE(%SCAN(&timepts,&nc+1,%STR( ))^=  );
     %LET nc=%EVAL(&nc+1); %END;
%LET nc1=%EVAL(&nc+1);
RUN; OPTIONS NONOTES;
%LOCAL _lastds_;
%DSHIDE;
DATA &out;SET &data(KEEP=&x &time &event &adj);
IF &x + &time + &event >.; KEEP &x &time  &adj _low_ _d_;
%IF &adj^=  %THEN %DO;
 IF NMISS(OF &adj)=0; %END;
RETAIN
     %DO it=1 %TO &nc;
     _t_&it %SCAN(&timepts,&it,%STR( ))
     %END;
_t_&nc1 1E30;
ARRAY _cut_(_ic_) _t_1-_t_&nc1;
     DO _period_=1 TO &nc1;
     IF _period_=1 THEN _low_=0;
     ELSE DO;_ic_=_period_-1; _low_=_cut_; END;
     _ic_=_period_; _d_=&event; IF &time>=_cut_ THEN _d_=0;
     IF &time>=_low_ THEN OUTPUT;
     END;
PROC SORT DATA=&out;BY _low_ DESCENDING &time;
PROC MEANS DATA=&out NOPRINT;BY _low_;VAR _d_;
 OUTPUT OUT=_count_(KEEP=_low_ n nuc) N=n SUM=nuc;
PROC PHREG DATA=&out COVOUT OUTEST=&out NOPRINT;BY _low_;
 MODEL &time*_d_(0)=&x &adj/TIES=&ties;
DATA &out; SET &out; BY _low_;
     LENGTH wald pval lhr se cllow clhigh 8;
     RETAIN wald pval lhr se cllow clhigh;
     IF FIRST._low_ THEN DO;
       wald=.; pval=.; lhr=.; se=.; cllow=.; clhigh=.;
       END;
     IF _NAME_="ESTIMATE" & _TYPE_="PARMS" THEN lhr=&x;
     IF _NAME_="&x" & _TYPE_="COV" THEN se=SQRT(&x);
     IF LAST._low_ THEN DO;
       wald=(lhr/se)**2; pval=1-PROBCHI(wald, 1);
       cllow=lhr-1.96*se; clhigh=lhr+1.96*se;
       OUTPUT;
       END;
LABEL lhr="Log Hazard Ratio" _low_="Left Time Endpoint";
DATA &out; MERGE &out _count_; BY _low_;
TITLE2 H=1.6 F=TRIPLEX "Log Hazard Ratio for Covariate &x Over Time with 95%
C.
L.";
TITLE3 H=1.3 F=TITALIC "Event Variable:&event  Minimum no. events in
interval:
&events";
%IF &noprint=0 %THEN %DO;
     PROC PRINT SPLIT="/";ID _low_;VAR n nuc lhr se cllow clhigh wald pval;
      LABEL _low_="Left Time/Endpoint"
            n="Observations" nuc=" Uncensored/Observations"
            wald=" Wald/CHI-SQ" pval="Prob>|beta|"
            lhr="Log Hazard/  Ratio"  se="S.E."
            cllow=" Lower/95% C.L."   clhigh=" Upper/95% C.L.";
     %END;
DATA &out;SET &out END=_eof_;
IF nuc < &events THEN DO;lhr=.;cllow=.;clhigh=.;END;
FOOTNOTE "Dashed Lines Indicate 95% Confidence Limits";
 %IF &adj^=  %THEN %DO;
    FOOTNOTE2 "Estimates Adjusted for &adj"; %END;
%IF &plot>1 %THEN %DO;
 DROP y;y=cllow;%AXISSPEC(VAR=_low_ y);y=clhigh;%AXISSPEC(END=_eof_);
 %END;
%IF &plot^=2 %THEN %DO;
PROC PLOT;
 PLOT lhr*_low_='*' cllow*_low_='.' clhigh*_low_='.' / OVERLAY
 %IF %QUOTE(&haxis)^=  %THEN HAXIS=&haxis; ;
%END;
%IF &plot^=1 %THEN %DO;
     PROC GPLOT;
      PLOT lhr*_low_ cllow*_low_ clhigh*_low_/
      OVERLAY HAXIS=AXIS1 VAXIS=AXIS2;
      AXIS1 VALUE=(H=1.2 F=duplex) LABEL=(H=1.3 F=complex) ORDER=
      %IF %QUOTE(&haxis)=  %THEN &spec1; %ELSE &haxis; ;
      AXIS2 VALUE=(H=1.2 F=duplex) LABEL=(H=1.3 F=complex A=90 R=0)
       ORDER=&spec2;
      SYMBOL1 I=JOIN L=1; SYMBOL2 I=JOIN L=2; SYMBOL3 I=JOIN L=2;

     RUN;
     %END;
RUN;OPTIONS NOTES;FOOTNOTE ;TITLE ;
OPTIONS _LAST_=&_lastds_;
%MEND;
 /*MACRO PROCEDURE PSPLINET - Plot Spline Transformation

Requires: Macro DASPLINE,
          Macro EMPTREND,
          Macro AXISSPEC  (if PLOT =2 or 3)
          Macro DSHIDE.

   For a given continuous independent variable X and a dependent variable
   Y, fits the Stone and Koo additive  spline  transformation  of  X  for
   either the logistic or Cox regression models, optionally adjusting for
   a  list  of  other independent variables.  Macro procedure DASPLINE is
   used to generate the spline  dummy  variables  used  for  fitting  and
   generating  predicted  values.   For  the  logistic  model  the output
   consists of a plot of the linearizing transformation between X and the
   log odds ratio.  For the Cox model, the log hazard  ratio  is  plotted
   instead.   By default, the binary logistic model for Y=0,1.  For Y=0,.
   ...,K, specify the K parameter to fit an ordinal model.
   Knot points can be specified or DASPLINE can
   use percentiles to  automatically  generate  knot  points.   When  the
   logistic  model  is  being used and there are no adjustment variables,
   probability estimates are plotted in addition to logits if PLOTPROB is
   given.  For the ordinal logistic model, the middle intercept  term  is
   used.   In  other words, Prob(Y>=int((k+1)/2)) is being estimated.  On
   the plots, vertical reference lines are drawn at knot points.  If KNOT
   is not given, the user may specify  OUTER
   in  addition  to NK.  OUTER and SECOND are used by DASPLINE - see that
   macro procedure for documentation.  If MODEL=LOGISTIC and ADJ  is  not
   used,  GROUPS=g  may be specified.  This will cause the EMPTREND macro
   procedure to be invoked to compute proportions and  logit  proportions
   by  g  quantile groups of X.  These points will be added to the graphs
   with a plotting symbol of X for PROC PLOT and a dotted circle for PROC
   GPLOT.

   Usage:

   %PSPLINET(X,Y,MODEL=LOGISTIC(default) or COX (default if EVENT given),
            RANGE= low TO high BY increment  range for evaluating X
                 (default=range in data, default increment=1 if RANGE
                  given without increment),
            EVENT=event indicator for PROC PHGLM if COX model used,
            K=max Y value for PROC LOGIST if ordinal logistic model used,
            NK=number of knots to use if KNOT omitted (3,4,5, default=4),
            OUTER=outer percentile for 1st knot if omit KNOT (DASPLINE),
            SECOND=percentile for 2nd knot if omit KNOT      (DASPLINE),
            KNOT= knot points  (computed by DASPLINE by default),
            PLOT=1 (PROC PLOT) 2 (PROC GPLOT, default)
                 3 (PROC PLOT and PROC GPLOT),
                 4 (no graphics but produce text file with coordinates
                    suitable for Harvard Graphics or similar software.
                    Uses ^ as field delimiter.)                        ,
            PLOTPROB to plot probability est. for logistic if ADJ omitted ,
            TESTLIN=1 to fit linear and non-linear logistic model to allow
                computation or LR statistic for linearity (for Cox, always
                computes Wald test of linearity)                        ,
            GROUPS= number of quantile groups (e.g. 10 for deciles),
            PRINT to print estimates from EMPTREND if GROUPS is used,
            ADJ=list of adjustment variables
            DATA=input dataset (default=_LAST_),
            SAXIS=low to high by inc y-axis specification for plotting
                 spline transformation,
            PAXIS=low to high by inc y-axis spec. for plotting
                 probabilities if PLOTPROB is used,
            XAXIS=x-axis specification,
            SHORT=to suppress confidence intervals and knots on
                 SAS/GRAPH for PLOTPROB output if PLOT>1,
            NOPST=to suppress plotting of spline transformation on    ,
                 graphics device if PLOTPROB is given and PLOT>1
            PLOTDATA=file name for PLOT=4.  Default is PUNCH.         ,
            FILEMODE=output mode for PLOTDATA file.  Default is MOD.
                    May also be NEW - a new file is started.          ,
            COMMTYPE=type of software being used to download PLOTDATA
                 1=standard text file (default)
                 2=Barr/Hasp var. length records with | as rec. delim.);

   Note:

See DASPLINE for a list of references.   Invokes
AXISSPEC  macro  if  PLOT>1  and  XAXIS  and  SAXIS are both omitted.  If
PLOT=2-3,references global macro variable TLEVEL  (not  an  argument)  to
determine  extent  of titling (beyond TITLE1) and footnoting.  The values
of TLEVEL are defined as follows:

       0 : No titles or footnotes
       1 : Stick titles, no footnotes
       2 : Stick titles with footnotes
       3 : Nice titles, no footnotes
       4 : Nice titles and footnotes (default if TLEVEL undefined)

   Author  : Frank E. Harrell, Jr.
             Takima West Corporation
             Clinical Biostatistics, Duke University Medical Center
   Date    : 22 July 86
   Modified: 26 Aug 86 - included logistic intercept term in est+C.I.
                         and SAXIS option
             23 Sep 86 - added %QUOTE for range+saxis,TESTLIN,PLOTPROB
             24 Sep 86 - added OUTER
             29 Sep 86 - implemented PROC GPLOT output options and GROUPS
             04 Oct 86 - added SECOND parm
             20 Oct 86 - fixed %EVAL that was &EVAL
             20 Nov 86 - changed NK default to 5
             21 Dec 86 - added more %QUOTE for saxis, fixed AXISSPEC call
             24 Mar 87 - added XAXIS parameter
             30 Mar 87 - added PAXIS parameter, SHORT option
             31 Mar 87 - added NOPST option, removed =1 from y-axis label
             19 May 87 - changed NK default to 4
             14 Nov 87 - added PRINT option
             19 Nov 87 - fixed MATRIX subscripting bug for K>1
             06 Apr 88 - communicated K parameter to EMPTREND
             05 Aug 88 - added DSHIDE
             15 Aug 89 - added PLOT=4 and assoc. parms,bug EMPTREND invoc
             02 May 91 - changed for SAS 6.07 to use LOGISTIC and PHREG,
                         TESTLIN parameter handled differently for PHREG
             09 Sep 91 - removed %INC for axisspec
                         changed plot default to 2
             03 Dec 91 - fixed problem with emptrend using reversed y
             27 Apr 92 - Added QUIT after GPLOT
             30 Apr 92 - QUIT position fixed
             14 Nov 94 - fixed RANGE in data _m_ step
                                                                       */
*** Version 8: Write out spline data for plotting in R. This is just
*** a simple hack building upon Version 7.
*** Version 15 (2/5/2014): Define flag for macro PSPLINET that turns on / off TIES=DISCRETE.;
%MACRO PSPLINET(x,y,model=LOGISTIC,range=,event=,k=1,nk=4,knot=,plot=2,
 outer=,second=,adj=,saxis=,xaxis=,testlin=1,plotprob=0,groups=,
 paxis=,short=0,nopst=0,print=0,PLOTDATA=PUNCH,COMMTYPE=1,FILEMODE=MOD,
 data=_LAST_,outcsv=,TIESDISCRETE=NO);
%LOCAL _lastds_ x7 ninclude k2 kmid nameint;
%GLOBAL tlevel; %IF &tlevel=  %THEN %LET tlevel=4;
%GLOBAL _knot1_; %*Created by DASPLINE if needed;
RUN; OPTIONS NONOTES;
%LET adj=%SCAN(&adj,1,'"'''); %LET range=%SCAN(&range,1,'"''');
%LET model=%UPCASE(&model);   %LET knot=%SCAN(&knot,1,'"''');
%LET saxis=%SCAN(%QUOTE(&saxis),1,'"''');
%LET xaxis=%SCAN(%QUOTE(&xaxis),1,'"''');
%LET paxis=%SCAN(%QUOTE(&paxis),1,'"''');
%LET x=%UPCASE(&x); %LET y=%UPCASE(&y);
%IF &event^=  %THEN %LET model=COX;
%IF &model=COX %THEN %LET k=0;
%IF &model=COX | &adj^=  %THEN %LET groups=;
%DSHIDE;
%IF %LENGTH(&x)=8 %THEN %LET x7=%SUBSTR(&x,1,7); %ELSE %LET x7=&x;
%*Find # knots if KNOT specified;
%IF &knot^=  %THEN %DO;
  %DO nk=1 %TO 99;
  %IF %QUOTE(%SCAN(&knot,&nk,%STR( )))=  %THEN %GOTO nomorek;
  %END;
 %nomorek:%LET nk=%EVAL(&nk-1);
 %END;
%LET k2=%EVAL(&nk-2);
DATA _m_;SET &data(KEEP=&x &y &event &adj nummths); IF NMISS(OF _NUMERIC_)=0;
DATA _m_;
  SET _m_ END=_eof_;
%IF &model=LOGISTIC %THEN %DO;
        %IF &groups^=  %THEN %DO; _yorig_=&y; %END;
        &y=&k - &y; LABEL &y="&k - &y";
        %END;   *Handle bug in LOGISTIC;
%IF %QUOTE(&range)=  %THEN %DO;
        DROP _xmin_ _xmax_ _xinc_;
        RETAIN _xmin_ 1e20 _xmax_ -1e20;
        _xmin_=min(_xmin_,&x); _xmax_=max(_xmax_,&x);
        IF _eof_ THEN DO;
                _xinc_=(_xmax_-_xmin_)/
         %IF &plot=1 %THEN 100; %ELSE %IF &plot=4 %THEN 150; %ELSE 500; ;
                CALL SYMPUT("range",trim(left(_xmin_))||" TO "
                        ||trim(left(_xmax_))||" BY "
                        ||trim(left(_xinc_)));
                END;
        %END;
%put ***************** GOT THIS FAR # 1 *****************;
%put x = &x;
%put nk = &nk;
%put outer = &outer;
%put second = &second;
%put knot = &knot;
%DASPLINE(&x,NK=&nk
%IF &outer^=  %THEN ,OUTER=&outer;
%IF &second^=  %THEN ,SECOND=&second;
%IF %QUOTE(&knot)^=  %THEN ,knot1="&knot";
 );   RUN;OPTIONS NONOTES;
%put ***************** GOT THIS FAR # 2 *****************;
%IF %QUOTE(&knot)=  %THEN %LET knot=&_knot1_; %*_knot1_ from DASPLINE;
%IF &adj^=  %THEN %DO;
%put ***************** GOT THIS FAR # 3 *****************;
        PROC MEANS DATA=_m_ NOPRINT;VAR &adj;OUTPUT OUT=_est_ MEAN=&adj;
        DATA _est_; SET _est_;
        PUT "&adj set to mean values:" &adj;
        %END;
%ELSE %DO;
%put ***************** GOT THIS FAR # 4 *****************;
        DATA _est_;
        %END;
%IF &model=COX %THEN %DO;   RETAIN &y 0; %END;

DO &x=&range; OUTPUT; END;

%IF &model=LOGISTIC %THEN DATA _tmp_; %ELSE DATA _tmp_ _est_; ;
 SET _m_ _est_(IN=_inest_);KEEP &x &x7.1-&&x7.&k2 &y &event &adj nummths;
%*The next statement computes spline dummy variables defined by DASPLINE;
&&_&x7
%IF &model=COX %THEN %DO;
        IF _inest_ THEN OUTPUT _est_; ELSE OUTPUT _tmp_;
        %END;
%IF &model=LOGISTIC %THEN %DO;
 %IF &testlin=1 %THEN %DO;
 PROC LOGISTIC DATA=_tmp_;
  MODEL &y=&adj &x;
  %END;
 PROC LOGISTIC DATA=_tmp_;
  MODEL &y=&adj &x &x7.1-&&x7.&k2;
 %LET kmid=%EVAL((&k+1)/2); %*Use middle intercept for ordinal logistic;
 OUTPUT OUT=_tmp_(KEEP=&x &y _LEVEL_ lowerprb upperprb prob splntran _se_)
        L=lowerprb U=upperprb PROB=prob STDXBETA=_se_ XBETA=splntran;
 DATA _tmp_;SET _tmp_; IF &y=.
 %IF &k^=1 %THEN & _level_=&kmid; ;
 %END;
%ELSE %DO;
*** Version 3 (6/3/2013):Suppress output to Results Viewer.
*** Version 4 (6/7/2013): Light hack: In invocation of PROC PHREG in macro PSPLINET,
*** insert left truncation. This hack ASSUMES left truncation variables
*** as defined in the LIFE study (nttp and nummths) and will not work
*** outside that context.;
ods select all; *** Version 11 (9/9/2013): Temporarily allow output to Results Viewer.;
 PROC PHREG DATA=_tmp_;
  MODEL &y*&event(0)=&adj &x &x7.1-&&x7.&k2/ entry=nummths
  %if ( &TIESDISCRETE = YES ) %then %do;
  ties=discrete
  %end;
  ;
  Linear:TEST &x7.1
  %IF &k2>1 %THEN ,&x7.2;
  %IF &k2>2 %THEN ,&x7.3;
  %IF &k2>3 %THEN ,&x7.4;
  %IF &k2>4 %THEN ,&x7.5;
  %IF &k2>5 %THEN ,&x7.6;
  %IF &k2>6 %THEN ,&x7.7;
  %IF &k2>7 %THEN ,&x7.8;
  %IF &k2>8 %THEN ,&x7.9;
  %IF &k2>9 %THEN ,&x7.10;    ;
 BASELINE OUT=_tmp_(KEEP=&x &y splntran _se_) COVARIATES=_est_
        XBETA=splntran STDXBETA=_se_ / NOMEAN;
*** Turn output to Results Viewer back on.;
run;
ods select all;
 %END;

DATA _tmp_; SET _tmp_;
 %IF &model=COX %THEN %DO; IF &y=0; %END;
 lower=splntran-1.96*_se_; upper=splntran+1.96*_se_; DROP _se_;
*** Version 5: Do plot in terms of Hazard Ratio rather than Log(Hazard Ratio).;
 *** Version 6: Draw a line at Hazard Ratio = 1.0;
 splntran = exp(splntran);
 lower    = exp(lower);
 upper    = exp(upper);
 ones     = 1;

%IF &groups^=  %THEN %DO;
 RUN;
 %EMPTREND(&x,_yorig_,DATA=_m_,GROUPS=&groups,LOGIT=1,PLOT=0,K=&k
 %IF &print=1 %THEN ,PRINT=1;); %*Creates _stats_;
 RUN;
 %IF &plot^=4 %THEN %DO; DATA _tmp_;SET _tmp_ %END;
 %ELSE %DO; DATA _stats_;SET %END;
  _stats_(KEEP=&x
 %IF &k=1 %THEN _yorig_ logit RENAME=(_yorig_=&y);
 %ELSE _y_&kmid logit&kmid RENAME=(_y_&kmid=&y logit&kmid=logit);
  );
 %END;
%IF &plot=1 | &plot=3 %THEN %DO;
 PROC PLOT;
  PLOT splntran*&x="." lower*&x="-" upper*&x="-"
  %IF &groups^=  %THEN logit*&x="X";
  /OVERLAY HREF=&knot
  %IF %QUOTE(&saxis)^=  %THEN %DO;
    VAXIS=&saxis
    %END;
  %IF %QUOTE(&xaxis)^=  %THEN %DO;
    HAXIS=&xaxis
    %END;
 ;
  LABEL splntran="Spline Transformation";
  %IF &model=LOGISTIC & &plotprob=1 & &adj=  %THEN %DO;
   PLOT prob*&x="." lowerprb*&x="-" upperprb*&x="-"
   %IF &groups^=  %THEN &y*&x="X";
   /OVERLAY HREF=&knot
   %IF %QUOTE(&paxis)^=  %THEN VAXIS=&paxis;
   %IF %QUOTE(&xaxis)^=  %THEN HAXIS=&xaxis; ;
   LABEL prob=
   %IF &k=1 %THEN "Prob(&y)"; %ELSE "Prob(&y>=&kmid)"; ;
   %END;
 %END;
%IF &plot=2 | &plot=3 %THEN %DO;
  %IF %QUOTE(&saxis)=  | %QUOTE(&xaxis)=  %THEN %DO;
   DATA _tmp_;SET _tmp_ END=_eof_;
   DROP _y_;_y_=lower;%AXISSPEC(VAR="&x _y_");_y_=upper; %AXISSPEC;
   %IF &groups^=  %THEN %DO;
    IF logit>. THEN DO;_y_=logit;%AXISSPEC;END;

    %END;
   %AXISSPEC(END=_eof_);
   RUN;  %*Creates mac. var. SPEC1 and SPEC2;
   %END;
  %IF %QUOTE(&saxis)^=  %THEN %LET spec2=&saxis;
  %IF %QUOTE(&xaxis)^=  %THEN %LET spec1=&xaxis;
 %IF &tlevel>0 %THEN %DO;
  %LOCAL font;%IF &tlevel>2 %THEN %LET font=TRIPLEX;
  %ELSE %LET font=SIMPLEX;
  %IF &plotprob=0 %THEN %DO;
  TITLE2 H=1.6 F=&font "Estimated Spline Transformation and 95% C.I.";
   %END;
  %IF &adj^=  & (&tlevel=2 | &tlevel=4) %THEN %DO;
   FOOTNOTE H=1.1 F=DUPLEX "Estimates Adjusted for:&adj"; %END;
  %END;

*** Version 7: Draw the horizontal line at 1.0 with black dashed line rather than a solid blue line.
*** Reference: http://support.sas.com/kb/00/578.html
*** Possibly relevant: http://support.sas.com/kb/17/037.html and http://support.sas.com/kb/00/577.html;
*** Version 8: Write out spline data for plotting in R. This is just
*** a simple hack building upon Version 7.
*** Version 9: Similar to Version 8, but write out spline data to
*** SAS data sets. Will attempt plotting in SAS outside of the
*** Vanderbilt macros.
*** Version 15 (2/5/2014): Based on Version 11. Write out spline data to CSV file
*** for plotting in R, as was done in Version 8. (But this version retains
*** the convention that the censoring variable has a value of 0
*** rather than 1 for censoring.);
    proc export data=_tmp_ replace
        outfile="&outcsv"
        dbms=csv;
    run;
 PROC GPLOT;
  %IF &nopst=0 %THEN %DO;
   PLOT splntran*&x=1 lower*&x=2 upper*&x=2 ones*&x=4
   %IF &groups^=  %THEN logit*&x=3;
   /OVERLAY HREF=&knot
        HAXIS=AXIS1 VAXIS=AXIS2;
  %END;
  AXIS1 VALUE=(H=1.2 F=duplex) LABEL=(H=1.3 F=complex) ORDER=&spec1;
  AXIS2 VALUE=(H=1.2 F=duplex) LABEL=(H=1.3 F=complex A=90 R=0)
   ORDER=&spec2;
  SYMBOL1 I=JOIN L=1; SYMBOL2 I=JOIN L=2;
  %IF &groups^=  %THEN %DO; SYMBOL3 I=NONE V=-; %END;
*** Version 5: Do plot in terms of Hazard Ratio rather than Log(Hazard Ratio).;
*** Version 7: Draw the horizontal line at 1.0 with black dashed line rather than a solid blue line.;
  SYMBOL4 COLOR=black I=JOIN L=3 WIDTH=1;
  LABEL splntran=
  %IF &model=LOGISTIC %THEN %DO;
   %IF &k=1 %THEN %DO;
    %IF &adj=  %THEN "logit Prob{&y}"; %ELSE "log Odds Ratio";
    %END;
   %ELSE %DO;
    %IF &adj=  %THEN "logit Prob{&y>=&kmid}";
    %ELSE "log Odds Ratio for &y>=&kmid";
    %END;
   %END;
  %ELSE "Hazard Ratio"; ;
  %IF &model=LOGISTIC & &plotprob=1 & &adj=  %THEN %DO;
   PLOT prob*&x=1
   %IF &short=0 %THEN lowerprb*&x=2 upperprb*&x=2;
   %IF &groups^=  %THEN &y*&x=3;
   /OVERLAY
   %IF &short=0 %THEN HREF=&knot;
        HAXIS=AXIS1 VAXIS=AXIS3;
   AXIS3 VALUE=(H=1.2 F=duplex) LABEL=(H=1.3 F=complex A=90 R=0)
        %IF %QUOTE(&paxis)^=  %THEN ORDER=&paxis; ;
   LABEL prob=
   %IF &k=1 %THEN "Prob{&y}"; %ELSE "Prob{&y>=&kmid}"; ;
   %END;
  RUN;QUIT;
  %IF &tlevel>0 %THEN %DO;
   RUN;TITLE2;FOOTNOTE;
   %END;
 %END;
%IF &plot=4 %THEN %DO;
 DATA _NULL_;FILE &plotdata &filemode;SET _tmp_(IN=_in1_)
 %IF &groups^=  %THEN _stats_(IN=_in2_) ; ;
 IF _N_=1 THEN
 PUT "&x" "^Spline Transformation^Lower C.L.^Upper C.L.^"
   "Logit Grouped^Probability of &y^Lower C.L. Prob.^Upper C.L. Prob.^"
   "Prob. Grouped^"
 %IF &commtype=2 %THEN "|"; ;
 IF _in1_ THEN
 PUT &x "^" splntran "^" lower "^" upper "^^"
 %IF &model=LOGISTIC & &plotprob=1 & &adj=  %THEN %DO;
  prob "^" lowerprb "^" upperprb "^^"
  %END;
 %ELSE "^^^^" ;
 %IF &commtype=2 %THEN "|"; ;
 %IF &groups^=  %THEN %DO;
  IF _in2_ THEN PUT &x "^^^^" logit "^"
  %IF &model=LOGISTIC & &plotprob=1 & &adj=  %THEN  "^^^" &y "^" ;
  %ELSE "^^^^" ;
  %IF &commtype=2 %THEN "|"; ;
  %END;
 %END;

RUN;OPTIONS NOTES _LAST_=&_lastds_;
%MEND;
 /* SAS Macro QUANTREP

Requires:  Macro DSHIDE.

Macro procedure to add a new variable Y to a dataset. Y is the mean value of
X when X is grouped according to quantiles. Unless  the  NOPRINT  option  is
given,  QUANTREP  prints  a  description  of the range and mean of X in each
quantile group, along with the number of observations in  the  group.  If  a
CLASS  variable  is  given,  X  will be grouped independently for each class
group. Output dataset will be sorted by CLASS and X. When GROUPS is omitted,
X is grouped into deciles. Y may be the same as X.

Usage:

%QUANTREP(X,Y,DATA=name of input dataset (default=_LAST_),CLASS=,
         GROUPS=,OUT=output dataset (default=input dataset),NOPRINT);

Author         : Frank Harrell
Date           : 01 Sep 84
Modified       : 09 Jun 86
                 24 Jun 91 - removed spurious Requires DHIDE at end

                                                                   */
%MACRO QUANTREP(X,Y,DATA=_LAST_,GROUPS=10,CLASS=,OUT=,NOPRINT=0);
RUN;  OPTIONS NONOTES;
%LOCAL _lastds_;
%DSHIDE;
%IF &OUT=  %THEN %LET OUT=&DATA;
%IF &OUT=_LAST_ %THEN %LET OUT=%SCAN(&SYSDSN,1).%SCAN(&SYSDSN,2);
PROC SORT DATA=&DATA OUT=&OUT;BY &CLASS &X;
PROC RANK DATA=&OUT OUT=&OUT GROUPS=&GROUPS;VAR &X;RANKS _GX_;
%IF &CLASS^=  %THEN %DO;BY &CLASS;%END;
PROC MEANS NOPRINT;VAR &X;
BY &CLASS _GX_;OUTPUT OUT=_STATS_ N=_NN_ MEAN=&Y MIN=_MINX_ MAX=_MAXX_;
%IF &NOPRINT=0 %THEN %DO;
TITLE2 "Description of &GROUPS-tile groups of &X";
PROC PRINT LABEL SPLIT='/';ID _NN_;
%IF &CLASS=   %THEN %DO;VAR _MINX_ _MAXX_ &Y; %END;
%ELSE %DO; BY &CLASS;VAR _MINX_ _MAXX_ &Y; %END;
LABEL _NN_="n" &Y="Mean/&X"   _MINX_="Minimum/&X"  _MAXX_="Maximum/&X"
%IF &CLASS^=   %THEN %DO; &CLASS="&CLASS"  %END;
     ;
%END;
DATA &OUT;MERGE &OUT _STATS_(DROP=_NN_ _MINX_ _MAXX_
%IF &X=&Y %THEN RENAME=(&X=_MEANX_);  );
BY &CLASS _GX_;DROP _GX_;
%IF &X=&Y %THEN %DO; &X=_MEANX_; DROP _MEANX_; %END;
RUN;TITLE2;OPTIONS NOTES;
%MEND QUANTREP;
 /*MACRO RCSPLINE

   For a given variable named X and from 3-10 knot locations,
   generates SAS assignment statements to compute k-2 components
   of cubic spline function restricted to be linear before the
   first knot and after the last knot, where k is the number of
   knots given.  These component variables are named c1, c2, ...
   ck-2, where c is the first 7 letters of X.

   Usage:

   DATA; ....
   %RCSPLINE(x,knot1,knot2,...,norm=)   e.g. %RCSPLINE(x,-1.4,0,2,8)

        norm=0 : no normalization of constructed variables
        norm=1 : divide by cube of difference in last 2 knots
                 makes all variables unitless
        norm=2 : (default) divide by square of difference in outer knots
                 makes all variables in original units of x

   Reference:

   Devlin TF, Weeks BJ (1986): Spline functions for logistic regression
   modeling. Proc Eleventh Annual SAS Users Group International.
   Cary NC: SAS Institute, Inc., pp. 646-51.

   Author  : Frank E. Harrell Jr.
             Clinical Biostatistics, Duke University Medical Center
   Date    : 10 Apr 88
   Mod     : 22 Feb 91 - normalized as in S function rcspline.eval
             06 May 91 - added norm, with default= 22 Feb 91
             10 May 91 - fixed bug re precedence of <>

                                                                      */
%MACRO RCSPLINE(x,knot1,knot2,knot3,knot4,knot5,knot6,knot7,
                  knot8,knot9,knot10, norm=2);
%LOCAL j v7 k tk tk1 t k1 k2;
%LET v7=&x; %IF %LENGTH(&v7)=8 %THEN %LET v7=%SUBSTR(&v7,1,7);
  %*Get no. knots, last knot, next to last knot;
    %DO k=1 %TO 10;
    %IF %QUOTE(&&knot&k)=  %THEN %GOTO nomorek;
    %END;
%LET k=11;
%nomorek: %LET k=%EVAL(&k-1); %LET k1=%EVAL(&k-1); %LET k2=%EVAL(&k-2);
%IF &k<3 %THEN %PUT ERROR: <3 KNOTS GIVEN.  NO SPLINE VARIABLES CREATED.;
%ELSE %DO;
 %LET tk=&&knot&k;
 %LET tk1=&&knot&k1;
 DROP _kd_; _kd_=
 %IF &norm=0 %THEN 1;
 %ELSE %IF &norm=1 %THEN &tk - &tk1;
 %ELSE (&tk - &knot1)**.666666666666; ;
    %DO j=1 %TO &k2;
    %LET t=&&knot&j;
    &v7&j=max((&x-&t)/_kd_,0)**3+((&tk1-&t)*max((&x-&tk)/_kd_,0)**3
        -(&tk-&t)*max((&x-&tk1)/_kd_,0)**3)/(&tk-&tk1)%STR(;);
    %END;
 %END;
%MEND;
 
 /* SAS Macro SECSOLVE

    Macro to solve f(x)=c for x, given an initial interval guess for x,
    [a,b] (which doesn't have to be right if f(.) is monotonic in x)
    and possible bounds for x [xmin,xmax]. The secant method with
    step halving is used, with convergence assumed when |f(x)-c| <=
    epsilon. Maxiter is the maximum number of iterations allowed
    before divergence is declared and execution is routed to the
    label "diverge". If convergence is obtained, the solution will
    be stored in the variable x and the final function value in
    funcval.

    Usage:

      DATA ;
       %secsolve(x,funclink,funcval,c,a,b,xmin,xmax,epsilon,
                 maxiter,diverge)
       DROP _x1_--_f_; *To get rid of temporary variables if
                        creating a SAS dataset              ;
       RETURN;
       funclink:funcval=f(x); ... RETURN;       *Evaluate f(x)    ;
       diverge :PUT "ERROR: divergence"; ABORT; *Handle divergence;

   Author   : Frank E. Harrell, Jr.
   Date     : 28 July 87
   Modified :

                                                                      */
%MACRO secsolve(xx,funclink,funcval,cval,x1,x2,xmin,xmax,
                epsilon,maxiter,diverge);
_x1_=&x1; _x2_=&x2;
&xx=&x1; LINK &funclink; _f1_=&funcval;
&xx=&x2; LINK &funclink; _f2_=&funcval;
_obj_=abs(_f1_-&cval);   _lastx_=&x1;   _lobj_=1E20;   _iter_=0;

   DO UNTIL (_obj_<= &epsilon);
   _iter_=_iter_+1;
   IF _iter_>&maxiter THEN GO TO &diverge;
   &xx=_x1_+(_x2_-_x1_)*(&cval-_f1_)/(_f2_-_f1_);
   &xx=MIN(MAX(&xmin,&xx),&xmax);
   LINK &funclink; _f_=&funcval;
   _obj_=abs(_f_-&cval);
      DO WHILE (_obj_>_lobj_);
      _iter_=_iter_+1;
      IF _iter_>&maxiter THEN GO TO &diverge;
      &xx=.5*(&xx+_lastx_);
      LINK &funclink; _f_=&funcval; _obj_=abs(_f_-&cval);
      END;
   _lastx_=&xx; _lobj_=_obj_;
   IF abs(&xx-_x1_) <= abs(&xx-_x2_) THEN DO;
      _x2_=&xx; _f2_=_f_;
      END;
   ELSE DO;
      _x1_=&xx; _f1_=_f_;
      END;
   END;
%MEND;
 /* Macro SOMER2

Requires:  Macro DSHIDE.

    Calculates concordance probability and Somer  Dyx  rank  correlation
    between  a  variable  X  (for  which  ties are counted) and a binary
    variable Y (having values 0 and 1, for which ties are not  counted).
    Uses short cut method based on average ranks in two groups.

    Usage:

         %SOMER2(X,Y,SAS dataset name);

                                                                      */
%MACRO SOMER2(X,Y,DATA);
%LOCAL _lastds_;
%DSHIDE;
DATA _SOMER2_;SET &DATA(KEEP=&X &Y);
IF &x + &y >.; IF ^(&y=0 | &y=1) THEN DO;
   PUT "ERROR: &y not 0 or 1 " &y=;
   ABORT;
   END;
PROC RANK OUT=_SOMER2_;VAR &X;
PROC MEANS NOPRINT NWAY;CLASS &Y;VAR &X;
OUTPUT OUT=_SOMER2_ N=N MEAN=MEANRANK;
DATA _somer2_;SET _SOMER2_ END=_EOF_;
RETAIN N0 N1 MEAN1;
IF &Y=1 THEN DO;N1=N;MEAN1=MEANRANK;END;
IF &Y=0 THEN N0=N;
IF _EOF_ THEN DO;
CONCORD=(MEAN1-(N1+1)/2)/N0; SOMERD=2*(CONCORD-.5); OUTPUT;
END;
KEEP CONCORD SOMERD;
LABEL CONCORD="c" SOMERD="Somer Dyx";
PROC PRINT LABEL DATA=_somer2_;VAR CONCORD SOMERD;
TITLE2 "Concordance Probability and Somer Rank Correlation For &X vs. &Y";
RUN;TITLE2 ;
OPTIONS _LAST_ = &_lastds_;
%MEND;
 /* SRVTREND SAS MACRO PROCEDURE : Survival Trend Plots

   ***********************************************************

NOTE: SRVTREND IS NOT PRESENTLY HANDLING STRATA BY COVARIABLE INTERACTIONS

Carlos Alzola, 24JAN92

********************************************************************************

Requires: Macro DASPLINE,
          Macro QUANTREP,
          Macro DSHIDE.

     SAS program that computes survival estimates with respect to 1,2, or
     3 factors and displays the survival trends.  For  each  factor,  the
     user may specify one of 3 levels of assumption to make regarding how
     that factor affects the survival probability.

        Assumption level      Meaning
        ----------------      -------
               1              No assumption. Round the variable if
                              necessary or group it  into  quantiles  and
                              subgroup  on  its  levels  (default value)
                              Uses blocking facility of PHGLM.
               2              Proportional hazards without assuming
                              linearity.  Fits Stone and Koo's restricted
                              spline function for the covariate. Knots
                              are selected (at percentiles 5,25,75,95
                              of the variable with default NK=4, and at
                              percentiles 5,25,50,75,95 if NK=5)
                              and dummy variables are
                              generated by the DASPLINE macro (see it for
                              documentation and references).
               3              Proportional hazards with linearity.

    Usage:

    %SRVTREND(TIME=time variable,EVENT=event indicator                 ,
             DATA=input dataset (default=last created)                 ,
             P=variable describing different plots (def=none)          ,
             PASSUME=assumption level for P (def=1)                    ,
             PRANGE= settings for P  - may be one of the following forms
                  PRANGE= 0 to 20  (default increment is 1)
                  PRANGE= 0 to 15 by 5
                  PRANGE= 4,5,8
                  PRANGE is mandatory for assumption level >1 and is
                  not used for assumption level 1.                     ,
             PGROUPS=number of quantile groups to create (applicable
                  only if PASSUME=1)                                   ,
             PROUND=r round P to the nearest r (only for PASSUME=1)    ,
             CLASS=var describing different curves on one plot (def=none),
             CASSUME= CRANGE= CGROUPS= CROUND= as with P               ,
             X=var on X-axis (if T specified)                          ,
             XASSUME= XRANGE= XGROUPS= XROUND= as with P               ,
             NK=  number of knots to use if any assumption level 2
                  variables are present (default=4)                    ,
             NMIN=minimum stratum size to use in computing estimates if
                  there are any assumption level 1 variables (def=10)  ,
                  NOTE: NMIN DOES NOT WORK WITH SAS 6.06+
             T= settings for TIME  for computing survival probabilities
                  if X is specified. Omit T and X to plot the entire
                  survival curve over the followup period.
                  T may have one of the following forms:
                  T=2               plot 2-UNIT survival only
                  T= 2,5            plot 2 and 5-UNIT survival
                  T= 1 to 7 by 2    plot 1,3,5,7-UNIT survival
                  T= 2 to 4         plot 2,3,4-UNIT survival           ,
             UNIT=unit of measurement for TIME (default=Year)          ,
             ADJ=optional list of numeric vars. to adjust for. The variables
                  not listed in ADJTO will be adjusted to the grand mean.
                  Proportional  hazards with linearity is assumed for the
                  adjustment variables.                                ,
             ADJTO=optional settings for ADJ variables if you do not
                  wish to use the grand mean, e.g. ADJTO= age=50;sex=1;
                  May contain formulas -  ADJTO= age=50;agesex=age*sex;
                  Note:ADJTO variables must appear in the ADJ, P, X, or
                  CLASS parameters, and ADJTO variables assigned to
                  constants must preceed their use in formulas as
                  illustrated above. To adjust to stratum-specific means
                  or medians, first compute the means and then use e.g.:
                  CLASS=sex ADJ=weight
                  ADJTO= weight=125*(sex='F')+180*(sex='M');           ,
             DERIVED=list of derived variables (such as interactions)
                  that are to be computed and included in the model
                  The DERIVED variables need not be included in the
                  input dataset                                        ,
             FORMULAS=formulas for derived variables, e.g.
                  FORMULAS=sexage=sex*age;sexage1=sex*age1;
                            sexage2=sex*age2;   to use interactions
                            with spline variables                      ,
             LOGLOG to obtain a plot for -log-log survival also        ,
             LOGLOG=2 to plot -log-log axis is reverse order           ,
             HAXIS= optional x-axis specs for PLOT statement           ,
                  e.g. HAXIS= 0 to 100 BY 10                           ,
             VAXIS= optional y-axis specs for PLOT statement (survival),
                  default setting is  0 to 1 BY .1                     ,
             LAXIS= optional y-axis specs for log-log survival         ,
             YLABEL=y-axis label for survival plots
                  Default is  Survival Probability                     ,
             LLABEL=legend label if CLASS used and PLOT>1
                  omit to use variable  name,  NONE  to  suppress  legend
                  label,   any label  to specify your own label.  Applies
                  only to log-log plots since  class  labels  are  placed
                  besides regular survival curves.                     ,
             CFMT=format for CLASS variable for drawing legends
                  if the variable has no SAS format and
                  PLOT>1 (default is format for variable in dataset or
                  6.2 if CGROUPS is specified).  Must contain a .      ,
             PLOT=plotting option
                  1=line printer
                  2=graphics device using SAS/GRAPH PROC GPLOT (default)
                  3=both line printer and graphics device
                  4=no graphs but produce text file with coordinates
                    suitable for Harvard Graphics or similar software
                    ^ is used as field delimiter                       ,
             PNFOL=u to print on the graph the number of persons
                  followed at least 0,u,2u,3u,4u,...  time units if  time
                  is on the x-axis (X not specified).  Specify PNFOL=0 to
                  suppress printing.  Default is PNFOL=1.
             PLOTDATA=file name for PLOT=4.  Default is PUNCH          ,
             FILEMODE=output mode PLOTDATA file.  Default is MOD -
                  output will be added to existing PLOTDATA file.  May
                  also be NEW - a new file will be started.           ,
             COMMTYPE=type of software being used to download PLOTDATA
                  1=standard text file (default)
                  2=Barr/Hasp (var.-length records with | as rec. delim.,
             TIES=method for PROC PHREG to use in handling ties (def=EFRON))
                                                                      );

     Note:

     The GROUPS and ROUND parameters  are  mutually  exclusive.   If  the
     assumption  level  for a variable is 1 and the variable is discrete,
     round and groups may be omitted and the variable is also allowed  to
     be a character variable.  This macro invokes the QUANTREP macro if a
     GROUPS  parameter  is  used.   When  quantile grouping is used, each
     quantile is identified by the mean value  of  the  variable  in  the
     quantile  group.   When time is on the x-axis, specifying HAXIS= low
     TO high BY inc  will ensure that step curves are carried all the way
     to  high  if followup  permits.   Otherwise,  the  I=STEPLJ  on  the
     SYMBOL  statement  will  not  carry  the last step to the end of the
     graph.  When a CLASS variable is present, CLASS labels  are  limited
     to 12 characters in length.  P, CLASS, and more than one T point may
     not  be  specified  simultaneously.  If T is given, X must be given,
     and vice-versa.  If CLASS and more than one T point are given but  P
     is  omitted,  a separate graph will be produced for each time point.
     If more than one time is given but CLASS is not,  a  separate  curve
     will appear on each graph for each value of time.

     If PLOT=4, HAXIS may be used to control which follow-up times are
     output in the PLOTDATA file.  When there is a page or class variable
     this will result in a more efficient file - multiple class or
     page survival estimates can be placed in one output record for
     the same follow-up time (since in this case predictions are
     requested explicitly for PHGLM).

    Example 1: Make one plot for males (sex=0) and one for females
               (sex=1).  For each plot, make one survival curve for  each
               quartile  of  bp.  Followup time is on the x-axis.  Adjust
               all estimates for age.  Age is the only variable for which
               the Cox model assumptions are assumed to hold.

    %SRVTREND(TIME=t,EVENT=death,P=sex,CLASS=bp,CGROUPS=4,ADJ=age);

    Example 2: Make one graph for each value of  bp  (rounded to the
               nearest 20) with each graph having  two  curves  (one  for
               each  value  of sex).  Plot age on the x-axis ranging from
               30 to 70 by increments of 2 years.  Two-year survival will
               be plotted on the  y-axis.   Assume  proportional  hazards
               with linearity for age.  Give the sex var value labels for
               use with GPLOT.

    PROC FORMAT;VALUE mf 0="male" 1="female";
    DATA ...;SET ...;FORMAT sex mf.;
    %SRVTREND(TIME=t,EVENT=d,P=bp,PROUND=20,CLASS=sex,
             X=age,XASSUME=3,XRANGE= 30 to 70 by 2 ,T=2,
             PLOT=2);

    Authors : Frank E. Harrell, Jr.
              Barbara G. Pollock
              Takima West Corporation
              Chapel Hill, NC
              Clinical Biostatistics
              Box 3363, Duke University Medical Center
              Durham NC 27710
    Requires: Macros DASPLINE, QUANTREP
    Date    : 1982 - first version (SAS DATA step language, no grouping,
              spline fits, or SAS/GRAPH)
    Modified: 16 Jul 86 - fixed delim for %SCAN
              21 Jul 86 - improved deletion of missing data,fix delim
              30 Jul 86 - restore H=1.3 in LEGEND LABEL (SAS bug fixed)
              30 Jul 86 - remove code to get around ANNOTATE's inability
                          to handle by-variables with PROC GPLOT (fixed)
              31 Jul 86 - added YLABEL parameter
              04 Sep 86 - comment out connecting curve to legend,
                          change footnote for adjustment,
                          move # followed in second time period to right
                          class label too low moved up
              17 Sep 86 - corrected passume^=1 to passume>1
              22 Sep 86 - added %QUOTE for haxis refs
              02 Oct 86 - corrected documentation re:X
              04 Oct 86 - corrected y-axis label when t and class given
              06 Oct 86 - added LOGLOG=2
              13 Oct 86 - incorporated version that doesn't assume that
                          ANNO in PROC GPLOT handles BY-variables,
                          added cubic spline fit for ASSUME=2
              21 Oct 86 - corrected %F typo
              27 Oct 86 - corrected ADJTO documentation
              11 Nov 86 - improved ADJTO documentation
              15 Dec 86 - added LAXIS parameter, removed "Adjusted Est."
                          footnote, placed "Adj" in y-axis label
               4 Aug 88 - fixed bug resulting from change in default #
                          knots in DASPLINE by adding parameter NK,
                          added CFMT parameter
               5 aug 88 - added DSHIDE
               5 Dec 88 - added PLOT=4, PLOTDATA, COMMTYPE
                        - removed logic to handle SAS error in
                          ANNOTATE with BY
              23 Aug 89 - removed _page_ var
              04 Sep 89 - added DERIVED, FORMULAS, loglog for PLOT=4
              14 Mar 90 - increased NTIED parameter for PHGLM
              23 Jun 91 - converted to Version 6.04 using PROC PHREG
                          Note:PHREG does not allod est of S(t) for a single
t
                          Always outputs for all event times - had to pick
off
                          appropriate t from much too large dataset.
                          Also changed -log-logS(t) to log-logS(t).
              09 Sep 91 - changed plot default to 2
              04 Nov 91 - changed last FOOTNOTE to FOOTNOTE2
              12 Nov 91 - took out NMIN logic because PROC PHREG does not
                          allow you to request which strata to estimate for
              27 Apr 92 - Added QUIT after GPLOT
              30 Apr 92 - fixed position of QUIT
              24 Mar 95 - removed formats from numeric variables in _dat_
                          dataset so that formats would not carry through
                          PROC PHREG

*/
%MACRO SRVTREND(time=,event=,p=,passume=1,prange=,pgroups=,
 pround=,class=,cassume=1,crange=,cgroups=,cround=,
 x=,xassume=1,xrange=,xgroups=,xround=,nk=4,nmin=,
 t=,haxis=,vaxis=0 TO 1 BY .1,laxis=,plot=2,loglog=0,
 cfmt=,ylabel="Survival Probability",unit=Year,llabel=,
 adj=,adjto=,pnfol=1,data=_last_,plotdata=PUNCH,commtype=1,
 filemode=MOD,derived=,formulas=,ties=efron);
%LOCAL _s_ _e_ _cvar_ _pvar_ _xvar_ tmin tmax _g_ spl _z_
       _clab_ _pfmt_ _plab_ _xlab_;
%IF &nmin!=  %THEN %PUT Warning: NMIN parameter no longer supported.;
%LET adj=%SCAN(&adj,1,'"'''); %LET haxis=%SCAN(&haxis,1,'"''');
%LET vaxis=%SCAN(&vaxis,1,'"'''); %LET adjto=%SCAN(&adjto,1,'"''');
%LET laxis=%SCAN(&laxis,1,'"''');
%LET prange=%SCAN(&prange,1,'"'''); %LET crange=%SCAN(&crange,1,'"''');
%LET xrange=%SCAN(&xrange,1,'"'''); %LET t=%SCAN(%QUOTE(&t),1,'"''');
%LET ylabel=%SCAN(&ylabel,1,'"''');
%LET derived=%SCAN(&derived,1,'"''');%LET formulas=%SCAN(&formulas,1,'"''');
%LET adj=%UPCASE(&adj); %LET time=%UPCASE(&time); %LET
event=%UPCASE(&event);
%LET class=%UPCASE(&class); %LET p=%UPCASE(&p); %LET x=%UPCASE(&x);
%IF %UPCASE(&filemode)=NEW %THEN %LET filemode= ;
%*SAS FILE statement assumes NEW if MOD not specified;
%IF &p=  %THEN %LET passume=0; %IF &class=  %THEN %LET cassume=0;
%IF &x=  %THEN %LET xassume=0;
%IF &x^=  %THEN %LET pnfol=0;
%IF &plot=1 %THEN %LET pnfol=0;
%LOCAL strata lasts lastvar;
%LET strata= ;  %*List of strata factors;
%LET lasts= ;   %*Last strata factor;
%LET lastvar=;  %*Last of P CLASS X;
%LET modeled=&adj &derived;   %*List of modeled covariables;
%IF &p^=  %THEN %DO;
 %LET lastvar=&p;
 %IF &passume=1 %THEN %DO;
  %LET _g_=None;
  %IF &pgroups^=  %THEN %LET _g_=&pgroups quantile groups;
  %IF &pround^=   %THEN %LET _g_=Rounded to nearest &pround;
  %PUT Variable forming plots :&p  Assumptions:None  Grouping:&_g_;
  %LET strata=&p; %LET lasts=&p;
  %END;
 %ELSE %DO; %LET spl=; %IF &passume=3 %THEN %LET spl=,linearity;
  %PUT Variable forming plots :&p  Assumptions:P.H.&spl  Range:&prange;
  %LET modeled=&modeled &p;
  %END;
 %END;
%IF &class^=  %THEN %DO;
 %LET lastvar=&class;
 %IF &cassume=1 %THEN %DO;
  %LET _g_=None;
  %IF &cgroups^=  %THEN %LET _g_=&cgroups quantile groups;
  %IF &cround^=   %THEN %LET _g_=Rounded to nearest &cround;
  %PUT Variable forming curves:&class  Assumptions:None  Grouping:&_g_;
  %LET strata=&strata &class;  %LET lasts=&class;
  %END;
 %ELSE %DO; %LET spl=; %IF &cassume=3 %THEN %LET spl=,linearity;
  %PUT Variable forming curves:&class  Assumptions:P.H.&spl  Range:&crange;
  %LET modeled=&modeled &class;
  %END;
 %END;
%IF &x^=  %THEN %DO;
 %LET lastvar=&x;
 %IF &xassume=1 %THEN %DO;
  %LET _g_=None;
  %IF &xgroups^=  %THEN %LET _g_=&xgroups quantile groups;
  %IF &xround^=   %THEN %LET _g_=Rounded to nearest &xround;
  %PUT Variable on X-axis:&x  Assumptions:None  Grouping:&_g_;
  %LET strata=&strata &x;  %LET lasts=&x;
  %END;
 %ELSE %DO;%LET spl=;%IF &xassume=3 %THEN %LET spl=,linearity;
  %PUT Variable on X-axis:&x  Assumptions:P.H.&spl  Range:&xrange;
  %LET  modeled=&modeled &x;
  %END;
 %END;
RUN;OPTIONS NOTES; *temp;
%LOCAL _lastds_;
%DSHIDE;
%*The QUOTE function solves problem with comma in parm value;
%LET tmin=%SCAN(%QUOTE(&t),1,%STR( ,)); %LET tmax=  ;
%IF %UPCASE(%SCAN(%QUOTE(&t),2,%STR( ,)))=TO %THEN
 %LET tmax=%SCAN(%QUOTE(&t),3,%STR( ,));
%ELSE %LET tmax=%SCAN(%QUOTE(&t),2,%STR( ,));
%IF &class^=  & &tmax^=  & &p^=  %THEN %DO;
 %PUT ERROR:PVAR, CLASS, and more than one T point may not be specified
 simultaneously;
 %GOTO thatsall; %END;
%IF %QUOTE(&t)^=  & &x=  %THEN %DO;
 %PUT ERROR:T is specified but no X= is given; %GOTO thatsall; %END;
%IF &x^=  & %QUOTE(&t)=  %THEN %DO;
 %PUT ERROR:X is specified but T was omitted; %GOTO thatsall; %END;
%*Decide on the actual page, class, and x-axis vars used;
%LET _cvar_=  ; %LET _pvar_=  ; %LET _xvar_=  ;
%IF &class^=  %THEN %LET _cvar_=&class;
%ELSE %IF &tmax^=  %THEN %LET _cvar_=&time;
%IF &p^=  %THEN %LET _pvar_=&p;
%ELSE %IF &class^=  & &tmax^=  %THEN %LET _pvar_=&time;
%IF &x^=  %THEN %LET _xvar_=&x; %ELSE %LET _xvar_=&time;
DATA _DAT_;SET &data(KEEP=&time &event &adj &p &class &x);
format _numeric_;
LABEL &time="&unit.s of Followup";
IF NMISS(OF _NUMERIC_)=0;
%IF (&passume=2 | &cassume=2 | &xassume=2) %THEN %DO;
 %LET spl=;
 %IF &passume=2 %THEN %DO;
  %LET spl=&p; %LOCAL p7; %LET p7=&p;
  %IF %LENGTH(&p)=8 %THEN %LET p7=%SUBSTR(&p,1,7);
  %END;
 %IF &cassume=2 %THEN %DO;
  %LET spl=&spl &class; %LOCAL c7; %LET c7=&class;
  %IF %LENGTH(&class)=8 %THEN %LET c7=%SUBSTR(&class,1,7);
  %END;
 %IF &xassume=2 %THEN %DO;
  %LET spl=&spl &x; %LOCAL x7; %LET x7=&x;
  %IF %LENGTH(&x)=8 %THEN %LET x7=%SUBSTR(&x,1,7);
  %END;
 %DASPLINE(&spl,NK=&nk); RUN; OPTIONS NOTES; *temp;
 DATA _dat_;SET _dat_;
 %END;
%IF &pnfol^=0 %THEN %DO;
 LENGTH _tfloor_ 4; _tfloor_=-FLOOR(&time/&pnfol)*&pnfol; %END;
%IF &pround^=  %THEN %DO;&p=ROUND(&p,&pround); %END;
%IF &passume=2 %THEN &&_&p7;
%IF &cround^=  %THEN %DO;&class=ROUND(&class,&cround); %END;
%IF &cassume=2 %THEN &&_&c7;
%IF &xround^=  %THEN %DO;&x=ROUND(&x,&xround); %END;
%IF &xassume=2 %THEN &&_&x7;
&formulas
%IF &passume=1 & &pgroups^=  %THEN %DO;
    %QUANTREP(&p,&p,DATA=_dat_,GROUPS=&pgroups); %END;
%IF &cassume=1 & &cgroups^=  %THEN %DO;
    %QUANTREP(&class,&class,DATA=_dat_,GROUPS=&cgroups); %END;
%IF &xassume=1 & &xgroups^=  %THEN %DO;
     %QUANTREP(&x,&x,DATA=_dat_,GROUPS=&xgroups); %END;
OPTIONS NOTES; *temp;
/*%IF &strata^=  %THEN %DO;
     PROC FREQ;TABLE
     %IF &passume=1 %THEN %DO; &p %IF (&cassume=1 | &xassume=1) %THEN *;
      %END;
     %IF &cassume=1 %THEN %DO; &class
               %IF &xassume=1 %THEN *; %END;
     %IF &xassume=1 %THEN &x;
     /LIST OUT=_est_;
     %END;*/
%IF &adj^=  %THEN %DO;
        PROC MEANS DATA=_dat_ NOPRINT;VAR &adj;OUTPUT OUT=_m_ MEAN=&adj;
        DATA _m_; SET _m_;
        PUT "&adj set to mean values:" &adj;
        %LET _mm_=_m_;
        %END;
%ELSE %LET _mm_=;

DATA _est_;
/*%IF &strata^=  %THEN %DO;
     MERGE _est_(DROP=PERCENT) &_mm_;IF COUNT>&nmin;DROP COUNT; %END;*/
/*%ELSE */ %IF &adj^=  %THEN %DO;
     SET _m_;
     %END;
%IF &passume>1 %THEN %DO;
     DO &p=&prange;
     %IF &passume=2 %THEN &&_&p7;
     %END;
%IF &cassume>1 %THEN %DO;
     DO &class=&crange;
     %IF &cassume=2 %THEN &&_&c7;
     %END;
%IF &xassume>1 %THEN %DO;
     DO &X=&xrange;
     %IF &xassume=2 %THEN &&_&x7;
     %END;
&adjto  &formulas
OUTPUT;
%IF &xassume>1 %THEN %DO;END; %END;
%IF &cassume>1 %THEN %DO; END; %END; %IF &passume>1 %THEN %DO; END; %END;
%IF &plot^=1 %THEN %DO;
 %*Get formats and labels for x, class or page vars;
 PROC CONTENTS DATA=_DAT_ NOPRINT OUT=_abase_(KEEP=name format type
            label);
 DATA _NULL_;SET _abase_;
 IF label=" " THEN label=name;
 IF name="&_xvar_" THEN CALL SYMPUT("_xlab_",TRIM(label));
 %IF &_cvar_^=  %THEN %DO;
 IF name="&_cvar_" THEN DO;
  CALL SYMPUT("_clab_",TRIM(label));
  %IF &cfmt=  %THEN %DO;
   IF format^=" " & SUBSTR(format,1,4)^="BEST" THEN DO;
    IF type=1 THEN CALL SYMPUT("_cfmt_",trim(format)||".");
    ELSE CALL SYMPUT("_cfmt_","$"||trim(format)||".");
    END;
   ELSE CALL SYMPUT("_cfmt_"," ");
   %END;
   END;
   %END;
 %IF &_pvar_^=  %THEN %DO;
 IF name="&_pvar_" THEN DO;
  CALL SYMPUT("_plab_",TRIM(label));
  IF format^=" " & SUBSTR(format,1,4)^="BEST" THEN DO;
    IF type=1 THEN CALL SYMPUT("_pfmt_",trim(format)||".");
    ELSE CALL SYMPUT("_pfmt_","$"||trim(format)||".");
    END;
   ELSE CALL SYMPUT("_pfmt_"," ");
   END;
   %END;
  RUN;
 %IF &class^=  %THEN %DO;
 %IF &cfmt=  %THEN %LET cfmt=&_cfmt_;
 %IF &cfmt=  & &cgroups^=  %THEN %LET cfmt=6.2;    %END;
 %IF &p^=  %THEN %DO;
 %IF &_pfmt_=  & &pgroups^=  %THEN %LET _pfmt_=6.2;   %END;
 %*Leave extra space to right of graph;
 %IF &_cvar_^=  & &plot^=4 %THEN %DO;
    FOOTNOTE2 A=90 F=SIMPLEX H=5 " "; %END;
 %*Generate ANNOTATE dataset if PNFOL used. A separate set of no. at risk
   is generated for each variable used as a stratification factor. ;
 %IF &pnfol^=0 %THEN %DO;
  %LOCAL _lastv_; %LET _lastv_= ;
  %IF &passume=1 %THEN %LET _lastv_=&p;
  %IF &cassume=1 %THEN %LET _lastv_=&class;
 %IF &plot=4 %THEN %DO;
  %*Print # followed since annotation not available here;
  %IF &_lastv_^=  %THEN %DO;
   PROC SORT DATA=_dat_; BY
   %if &passume=1 %THEN &p; %IF &cassume=1 %THEN &class; ;
   %END;
  PROC FREQ DATA=_dat_;
  %IF &_lastv_^=  %THEN %DO;   BY
   %IF &passume=1 %THEN &p;
   %IF &cassume=1 %THEN &class; ;
   %END;
  TABLES _tfloor_;
  TITLE2 "Number of Subjects Followed in Each Interval";
  TITLE3 "(Ignore Minus Signs)";
  RUN; TITLE2;
  %END;
 %ELSE %DO;
  PROC FREQ DATA=_DAT_;TABLES
  %IF &passume=1 %THEN &p *;
  %IF &cassume=1 %THEN &class *;
  _tfloor_/OUT=_abase_ NOPRINT;
  DATA _abase_;SET _abase_;
  %IF &_lastv_^=  %THEN %DO; BY
   %IF &passume=1 %THEN &p; %IF &cassume=1 %THEN &class; ; %END;
  LENGTH y 4; RETAIN _nfol_ 0 y 1;
  %IF &_lastv_^=  %THEN %DO; IF FIRST.&_lastv_ THEN _nfol_=0; %END;
  _nfol_=_nfol_+count;
  %IF &passume=1 %THEN %DO;
   %IF &cassume=1 %THEN %DO; IF FIRST.&p THEN y=0; %END; %END;
  %IF &cassume=1 %THEN %DO; IF FIRST.&class THEN y=y+3*size; %END;
  %ELSE %DO; y=4; %END;
  KEEP xsys ysys function x y text position size
  %IF &passume=1 %THEN &p; ;
  LENGTH xsys ysys $ 1 function $ 5 text $ 18 x 4 position $ 1 size 3;
  RETAIN function "LABEL" size 1.175;  x=-_tfloor_;
  IF _nfol_>0
  %IF %QUOTE(&haxis)^=  %THEN & x<= %SCAN(%QUOTE(&haxis),3,%STR( ));
   THEN DO; text=put(_nfol_,5.); position="5";
   IF x=0 THEN x=.16; ELSE IF x=&pnfol THEN x=x-.035*size;ELSE x=x-.14*size;
   xsys="2"; ysys="1"; OUTPUT; END;
  %IF &cassume=1 %THEN %DO;
   IF LAST.&class THEN DO;
    xsys="1"; ysys="1"; x=100;
    %IF &cfmt^=  %THEN text="  "||LEFT(PUT(&class,&cfmt));
    %ELSE text="  "||LEFT(&class); ;   position="6";
    OUTPUT;
    END;
   %END;
  %END;
  %END;
 %END;
%IF &_pvar_=&time | &_cvar_=&time | %QUOTE(&t)^=  %THEN %DO;
 PROC FORMAT;PICTURE _tfmt_ LOW-HIGH=
%IF %INDEX(%QUOTE(&t),.)^=0 %THEN "00.9-&unit Survival";
%ELSE "00-&unit Survival"; ; %END;
%*PHREG wont work if no covariables in model;
%IF &modeled=  %THEN %DO;
   %KMPL(TIME=&time,EVENT=&event,DATA=_dat_,CLASS=&p &class &x,OUT=_est_,
        PLOT=0)
   OPTIONS NONOTES;
   %END;
%ELSE %DO;
 PROC PHREG DATA=_dat_;
 %IF &strata^=  %THEN %DO; STRATA &strata; %END;
 MODEL &time * &event(0) =
 %LET _z_=%EVAL(&nk-2);
 %IF &passume>1 %THEN &p;     %IF &passume=2 %THEN &p7.1-&p7&_z_;
 %IF &cassume>1 %THEN &class; %IF &cassume=2 %THEN &c7.1-&c7&_z_;
 %IF &xassume>1 %THEN &x;     %IF &xassume=2 %THEN &x7.1-&x7&_z_;
 &adj &derived/ TIES=&ties;
 BASELINE COVARIATES=_est_ OUT=_est_ SURVIVAL=survival XBETA=xbeta
     STDXBETA=sexbeta LOGLOGS=loglog_s / NOMEAN;
%END;
PROC SORT DATA=_est_; BY &p &class &x;
LABEL loglog_s="log(-log(Survival))";
%IF %QUOTE(&t)^=  & (&_pvar_^=&time) %THEN %LET ylabel=&t-&unit &ylabel;
%IF &adj^=  %THEN %DO;
   %IF %LENGTH(&ylabel) < 29 %THEN %LET ylabel=&ylabel (adjusted);
   %ELSE %IF %LENGTH(&ylabel) < 33 %THEN %LET ylabel=&ylabel (adj.);
   %END;
LABEL survival="&ylabel";
%LET _e_=Kaplan-Meier;
%IF &derived^=  |
    &adj^= | &passume>1 | &cassume>1 | &xassume>1 %THEN %LET _e_=Cox;
%IF &adj=  %THEN %DO;TITLE2 "&_e_ Survival Estimates"; %END;
%ELSE %DO;TITLE2 "&_e_ Adjusted Survival Estimates"; %END;
*If t variable present, pick off proper time pts from survival curves;
%IF %QUOTE(&t)^=  %THEN %DO;
    DATA _est_; SET _est_; BY &p &class &x;
*PHREG does not output a predicted value if last obs is uncensored.
 This logic needs to be fixed to more manually compute last time in each
 STRATA;
    RETAIN _tmax_ _s1-_s100; ARRAY _s_{*} _s1-_s100;
    IF FIRST.&lastvar THEN DO;
      _tmax_=0;
      DO _i_=1 TO 100; _s_{_i_}=1; END;
      END;
    _i_=0; _tmax_=&time;
      DO _t_=&t;
      _i_=_i_+1;
      IF _i_>100 THEN DO;
        PUT "ERROR:SRVTREND requires <=100 t points";
        ABORT;
        END;
      IF &time<=_t_ THEN _s_{_i_}=survival;
     *Hold onto last point <= t - this is step function estimate;
      END;
    IF LAST.&lastvar THEN DO;
      _i_=0;
        DO _t_=&t;
        _i_=_i_+1;
        survival=_s_{_i_}; loglog_s=log(-log(survival));
        IF _t_>_tmax_ THEN DO;
          survival=.; loglog_s=.;
          END;
        &time=_t_;
        OUTPUT;
        END;
      END;
    KEEP &p &class &x &time survival loglog_s
    %IF &modeled^=  %THEN xbeta sexbeta;  ;
    %END;
%IF &x^=  & &plot^=4 %THEN %DO;
     PROC SORT;BY &time &p &class &x ;
     PROC PRINT UNIFORM;BY &time &p; ID &class &x;
     VAR SURVIVAL LOGLOG_S;
     %END;
PROC SORT;BY &_pvar_ &_cvar_ &_xvar_;
%IF &plot=4 %THEN %DO;
   %LOCAL _cv_ _pv_ _cmax_ _cf_ _cl_ _pf_ _pl_; %LET _cv_= ; %LET _pv_= ;
   %LET _cf_= ; %LET _cl_= ; %LET _pf_= ; %LET _pl_= ;
   %IF &_cvar_=  & &_pvar_^=  %THEN %DO; %LET _cv_=&_pvar_;
        %LET _cf_=&_pfmt_; %LET _cl_=&_plab_; %END;
   %IF &_cvar_^=  & &_pvar_=  %THEN %DO; %LET _cv_=&_cvar_;
        %LET _cf_=&cfmt; %LET _cl_=&_clab_; %END;
   %IF &_cvar_^=  & &_pvar_^=  %THEN %DO;
      %LET _cv_=&_cvar_; %LET _pv_=&_pvar_;
      %LET _cf_=&cfmt; %LET _cl_=&_clab_; %LET _pf_=&_pfmt_;
      %LET _pl_=&_plab_; %END;
   %IF &_pv_=&time %THEN %DO; %LET _pl_= ;%LET _pf_=_tfmt_.; %END;
   %IF &_cv_=&time %THEN %DO; %LET _cl_= ;%LET _cf_=_tfmt_.; %END;
   %IF &_cv_^=  %THEN %DO;
     %*Make list of all columns for plot (values of curve vars);
     %*Associate a column number with each class;
     %IF &_pv_^=  %THEN %DO;
        PROC SORT DATA=_est_; BY &_cv_ &_pv_ &_xvar_;    %END;
     PROC FREQ DATA=_est_;
     TABLES &_cv_/NOPRINT OUT=_cno_;
     DATA _est_;MERGE _est_ _cno_ END=_eof_;BY &_cv_;
     FILE &plotdata &filemode; IF _n_=1 THEN PUT "&_xlab_^" @;
     IF FIRST.&_cv_ THEN DO;
      _cno_+1; PUT "&_cl_ " &_cv_ &_cf_ "^"
      %IF &loglog>0 %THEN "log-log^";   @;
      END;
     IF _eof_ THEN CALL SYMPUT("_cmax_",TRIM(LEFT(_cno_)));
     %IF &commtype=2 %THEN %DO; IF _eof_ THEN PUT "|"; %END;
     %END;
   %ELSE %DO;
     DATA _NULL_; FILE &plotdata &filemode; PUT "&_xlab_" "^&ylabel"
     %IF &commtype=2 %THEN "|"; ;
   %END;
 %IF &_cv_^=  %THEN %DO;
    PROC SORT DATA=_est_;BY &_pv_ &_xvar_ &_cv_;     %END;
 DATA _NULL_; RETAIN _bk_ -1; FILE &plotdata MOD; SET _est_;
 %IF &_cv_^=  | &_pv_^=  %THEN %DO; BY &_pv_ &_xvar_ &_cv_; %END;
 %IF &_pv_^=  %THEN %DO;
    IF FIRST.&_pv_ THEN PUT "*** &_pl_ " &_pv_ &_pf_;
    %END;
 %IF &_cv_=  %THEN %DO;
    PUT &_xvar_ +_bk_ "^" survival
    %IF &loglog>0 %THEN  "^" LOGLOG_S;
    %IF &commtype=2 %THEN +_bk_ "|";  ;
    %END;
 %ELSE %DO;
      IF FIRST.&_xvar_ THEN DO;
       PUT &_xvar_ +_bk_ "^" @;
       ARRAY _cc_{*} _cc_1-_cc_&_cmax_; RETAIN _cc_1-_cc_&_cmax_;
       DO _i_=1 TO &_cmax_;  _cc_{_i_}=.; END;
       END;
      _cc_{_cno_}=survival;
      IF LAST.&_xvar_ THEN DO;  DO _i_=1 TO &_cmax_;
            IF _cc_{_i_}=. THEN PUT "^"
            %IF &loglog>0 %THEN "^"; @;
            ELSE DO; %IF &loglog>0 %THEN %DO;
              sloglog=log(-log(_cc_{_i_})); %END;
            PUT _cc_{_i_} +_bk_ "^"
            %IF &loglog>0 %THEN sloglog "^";   @;
            END;
         END;
         %IF &commtype=2 %THEN PUT +_bk_ "|"; ;
         END;
      %END;
 %END;
%IF &plot=1 | &plot=3 %THEN %DO;
 PROC PLOT; %IF &_pvar_^=  %THEN %DO; BY &_pvar_; %END;
 PLOT survival*&_xvar_
 %IF &_cvar_^=  %THEN =&_cvar_;
 %IF %QUOTE(&haxis)^= | &vaxis^=  %THEN /;
 %IF %QUOTE(&haxis)^=  %THEN HAXIS=&haxis;
 %IF &vaxis^=  %THEN VAXIS=&vaxis; ;
 %IF &loglog>0 %THEN %DO;
      PLOT loglog_s*&_xvar_
      %IF &_cvar_^=  %THEN =&_cvar_;
      /
      %IF &laxis^=  %THEN VAXIS=&laxis;
      %IF &loglog=2 %THEN VREVERSE;
      %IF %QUOTE(&haxis)^=  %THEN HAXIS=&haxis;
      ;
      %END;
 %END;
%IF &plot=2 | &plot=3 %THEN %DO;
     TITLE2 H=1.5 F=COMPLEX
     %IF &adj=  %THEN "&_e_ Survival Estimates";
     %ELSE "&_e_ Adjusted Survival Estimates";  ;
     TITLE2 ; *temp?;
     %IF &x^=  %THEN %LET _s_=JOIN; %ELSE %LET _s_=STEPLJ;
     SYMBOL1 L=1 I=&_s_ V=NONE;
     SYMBOL2 L=2 I=&_s_ V=NONE;
     SYMBOL3 L=3 I=&_s_ V=NONE;
     SYMBOL4 L=4 I=&_s_ V=NONE;
     SYMBOL5 L=5 I=&_s_ V=NONE;
     SYMBOL6 L=6 I=&_s_ V=NONE;
     SYMBOL7 L=7 I=&_s_ V=NONE;
     SYMBOL8 L=8 I=&_s_ V=NONE;
     SYMBOL9 L=9 I=&_s_ V=NONE;
     SYMBOL10 L=10 I=&_s_ V=NONE;
     %*If class var present, whether CLASS  or  TIME,  create  annotation
     dataset for placing class legend to right of end of each curve.  Use
     estimate  at  last  abscissa  for  each  class  in  each  plot (last
     abscissa<=that specified in HAXIS if HAXIS is given);
     %IF &_cvar_^=  %THEN %DO;
      DATA _legend_;SET _est_;BY &_pvar_ &_cvar_;
      LENGTH x y 4 xsys ysys $ 1 function $ 5 text $ 18 position $ 1
        style $ 7 size 3  /* line 2 */;
      KEEP x y xsys ysys function text position style size line
      &_pvar_ ;
  /*  %IF &_pvar_^=  %THEN _page_; ;    del 8/89 */
      RETAIN ysys "2" position "6" style "COMPLEX" size 1.3 line 20;
      %IF &vaxis^=  %THEN
       delta=(%SCAN(&vaxis,3,%STR( ))-%SCAN(&vaxis,1,%STR( )))/10;
      %ELSE RETAIN delta .1;  ;
      RETAIN x y text lasty;
      IF FIRST.&_cvar_ THEN DO; x=.; y=.; text=""; END;
      %IF %QUOTE(&haxis)=  %THEN IF survival>.;
      %ELSE IF survival>. & (&_xvar_ <= %SCAN(%QUOTE(&haxis),3,%STR( )));
      THEN DO; x=&_xvar_; y=survival; END;
      IF LAST.&_cvar_ & (x+y>.) THEN DO;
       %*Set up to draw line from last point on curve to label;
    /* function="MOVE"; xsys="2"; OUTPUT; */
       %*IF label low enough to hit # followed, move up;
       %IF &vaxis^=  & &pnfol^=0 %THEN %DO;
        y=max(y,%SCAN(&vaxis,1,%STR( ))+2*delta);  %END;
       %*If last two labels too close together, move farther apart;
       IF lasty>. & abs(y-lasty)<delta THEN DO;
        IF y<lasty THEN y=y-(delta-abs(y-lasty));
        ELSE y=y+(delta-abs(y-lasty));
        %IF &vaxis=  %THEN y=min(max(y,0),1);
        %ELSE y=min(max(y,%SCAN(&vaxis,1,%STR( ))),%SCAN(&vaxis,3,%STR( )))
         ; ;
        END;
     /*function="DRAW";*/  xsys="1"; x=100; /* OUTPUT; */
       function="LABEL";
      %IF &_cvar_=&class %THEN %DO;
       %IF &cfmt=  %THEN text=LEFT(&class);
       %ELSE text=LEFT(PUT(&class,&cfmt));
       %END;
      %ELSE text=TRIM(LEFT(&time))||" &unit"; ;
       OUTPUT; lasty=y;
       END;
      %*Add these annotations to any existing ones;
      DATA _abase_;SET _legend_
      %IF &pnfol^=0 %THEN _abase_; ;
      %IF  &_pvar_^=  %THEN %DO;BY &_pvar_;%END;
      %END;
     PROC GPLOT DATA=_est_;
     %IF &_pvar_^=  %THEN %DO; BY &_pvar_; %END;
     %IF &_pvar_=&time %THEN %DO;
      LABEL &time="_"; FORMAT &time _tfmt_.; %END;
     %*The FORMAT statement handles bug in PHGLM;
     PLOT survival*&_xvar_
     %IF &_cvar_^=  %THEN =&_cvar_;
     /HAXIS=AXIS1 VAXIS=AXIS2 NOLEGEND
     %IF &pnfol^=0 | &_cvar_^=  %THEN ANNO=_abase_; ;
     AXIS1 VALUE=(H=1.2 F=duplex) LABEL=(H=1.3 F=COMPLEX)
     %IF %QUOTE(&haxis)^=  %THEN ORDER=&haxis;
     ;
     AXIS2 VALUE=(H=1.2 F=duplex) LABEL=(H=1.3 F=complex A=90 R=0)
     %IF &vaxis^=  %THEN ORDER=&vaxis;
     ;
     %IF &loglog>0 %THEN %DO;
          PLOT loglog_s*&_xvar_
          %IF &_cvar_^=  %THEN =&_cvar_;
          /HAXIS=AXIS1 VAXIS=AXIS3 LEGEND=LEGEND
          %IF &loglog=2 %THEN VREVERSE; ;
          LEGEND VALUE=(H=1.3 F=complex) FRAME LABEL=
          %IF %UPCASE(&llabel)=NONE %THEN NONE;
          %ELSE (H=1.3 F=complex &llabel);  ;
          AXIS3 VALUE=(H=1.2 F=duplex) LABEL=(H=1.3 F=complex A=90 R=0)
          %IF &laxis^=  %THEN ORDER=&laxis; ;
          %END;
     %END;
     RUN;QUIT;
%thatsall:RUN;TITLE2;FOOTNOTE2;OPTIONS NOTES _LAST_=&_lastds_;
%PUT AUTHOR: FRANK HARRELL  11/12/91;
%MEND;


