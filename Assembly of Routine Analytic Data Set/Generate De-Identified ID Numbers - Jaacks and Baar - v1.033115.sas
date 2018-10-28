******************************************************************************;
******************************************************************************;
*** SAS Script to generate de-identified ID numbers for the 501 couples,
*** for the data to be distributed to Jaacks and Baar.
*** Use a random ordering for the de-identified ID numbers.
***
*** Version 1: Very heavily adapted from the SAS program
*** Generate De-Identified ID Numbers - v1.111914.sas
*** from the Medications, Supplements, and Reproductive Outcomes study
*** of Christina Chambers and Kristen Palmer.
*** See email Germaine sent on 11/19/2014 at 10:51 AM.
*** Output linking information in both CSV and SAS data file formats.
******************************************************************************;
******************************************************************************;

%let VERSION          = v1;
%let DATESTR          = 033115;
%let OUTPUT_FOLDER    = Output-03-31-15;
%let MAIN_FOLDER      = C:/Documents and Settings/maisogjm/My Documents/LIFE/Data Distributions;
%let TTL_FOLDER       = C:/Users/maisogjm/Documents/LIFE/Data Quality/Time To Loss;
%let JOURNAL_FOLDER   = N:/DIPHRData/LIFE/EmmesData/Journals_01272010;
%let RAND_SEED        = 3849766;
%let UPDATED_SAF      = saf_cutoffnofilter_022713; * Version used in the GDM paper.;
%let UPDATED_LIVEWIDE = life_wide_022713;          * Version used in the GDM paper.;

libname raji     "C:/Documents and Settings/maisogjm/My Documents/LIFE/PHREG";
libname journals "&JOURNAL_FOLDER";
libname ttllib   "&TTL_FOLDER";
libname out      "&MAIN_FOLDER/&OUTPUT_FOLDER";

******************************************************************************;
******************************************************************************;
*** Load utility macros.
*** Change the macro variable MACRO_FOLDER to point to the folder on your
*** computer where the macro definitions are stored.
******************************************************************************;
******************************************************************************;

%let MACRO_FOLDER = C:/Users/maisogjm/Documents/GLOTECH/SAS Utility Macros;
filename macdef "&MACRO_FOLDER/Utility Macros - v47.011515.sas";
%include macdef;

******************************************************************************;
******************************************************************************;
*** Define formats.
******************************************************************************;
******************************************************************************;

proc format;
    value VITAMBPJLFMT
        0 = 'None'
        1 = 'Yes, prescription prenatal vitamins'
        2 = 'Yes, over-the-counter multivitamins';
    value NOYES2PJLFMT
        0 = '0-No'
        1 = '1-Yes'
        9 = '9-Did not see a health care provider';
    value CIGSPJLFMT
        0 = 'None'
        1 = 'Less than 10'
        2 = '10 to 20'
        3 = 'More than 20';
    value SUGARPJLFMT
        0 = '0-No'
        1 = '1-Yes, high blood sugar associated with pregnancy'
        2 = '2-Yes, already known to have diabetes'
        3 = '9-Did not see a health care provider';
run;

******************************************************************************;
******************************************************************************;
*** Obtain pregnancy dates from the updated SAF data.
*** Code adapted from 
*** Make Analytic Data Set - v12.011614.sas
*** where it was in turn adapated from the SAS program
*** ClassifyPJLDataByAttempt123.v2.110912.sas.
*** Pregancy dates will be used to partition PJL data into Attempts 1, 2, and 3.
******************************************************************************;
******************************************************************************;

***************************************;
***************************************;
*** Load updated SAF data.;
*** 9/17/2012: no need to convert SPID to numeric.
*** SAS Data Set fixedSafCutoffNoFilter
*** Number of observations              = 1556
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 11;
***************************************;
***************************************;
*** Load updated SAF data.;
*** 9/17/2012: no need to convert SPID to numeric.;

data fixedSafCutoffNoFilter;
    set raji.&UPDATED_SAF(keep=spid method5 date event Decision);
    if ( ( Decision ^= " " ) OR ( event ^= " " ) );
run;
%CountUniqueVals(inputData=fixedSafCutoffNoFilter,vrbl=spid);

***************************************;
***************************************;
*** Obtain dates of pregnancies.
*** Need these to assign BIRTH events to ATTEMPT1, ATTEMPT2, or ATTEMPT3.;

*** This macro is heavily based on the macro COMPUTE_TTLX,
*** defined in Version 1 of this script,
*** which in turn was heavily based on the macro CHECK_PREG_LOSS
*** defined in the SAS script CheckTimeToLoss.v3.093011.sas.
*** Given X=(1,2,3), it creates a data set NEW_TTL_X, containing
*** dates for PREG_X and LOSS_X, as well as TTL_X.;
%macro obtain_preg_and_loss_dates(type=,x=);

*** Generate preg(x)_dat data set, then sort it.;
%let theDate     = &type&x._date;
%let theVar      = &type&x;
%let theDataSet  = &type&x._dat;
%let theDecision = &type&x._Decision;
data &theDataSet;
    set fixedSafCutoffNoFilter;
    &theDecision = decision;
    &theDate     = date;
    format &theDate mmddyy10.;
    if ( index(decision,"&theVar") > 0 );
    drop decision;
run;

proc sort data=&theDataSet; by spid; run;

%mend obtain_preg_and_loss_dates;

*** Invoke the OBTAIN_PREG_AND_LOSS_DATES macro, compute preg1_date, preg2_date, preg3_date.;
%obtain_preg_and_loss_dates(type=Preg,x=1); * NumObs = 346, N = 346;
%obtain_preg_and_loss_dates(type=Preg,x=2); * NumObs = 48,  N = 48;
%obtain_preg_and_loss_dates(type=Preg,x=3); * NumObs = 5,   N = 5;

*** Invoke the OBTAIN_PREG_AND_LOSS_DATES macro, compute loss1_date, loss2_date, loss3_date.;
%obtain_preg_and_loss_dates(type=Loss,x=1); * NumObs = 100, N = 100;
%obtain_preg_and_loss_dates(type=Loss,x=2); * NumObs = 14,  N = 14;
%obtain_preg_and_loss_dates(type=Loss,x=3); * NumObs = 2,   N = 2;

*** Merge dates of PREG1, PREG2, and PREG3.;
*** SAS Data Set preg_dates
*** Number of observations              = 346
*** Number of unique occurences of spid = 346
*** Maximum number of repeats of spid   = 1;
data preg_dates;
    retain spid preg1_date loss1_date preg2_date loss2_date preg3_date loss3_date;
    merge preg1_dat loss1_dat preg2_dat loss2_dat preg3_dat loss3_dat;
    by spid;
    keep spid preg1_date loss1_date preg2_date loss2_date preg3_date loss3_date;
run;
%CountUniqueVals(inputData=preg_dates,vrbl=spid);

*** 3/4/2013: Compute time to loss in DAYS.;
data preg_dates;
    retain spid preg1_date loss1_date ttl1 preg2_date loss2_date ttl2 preg3_date loss3_date ttl3;
    set preg_dates;
    ttl1 = loss1_date - preg1_date;
    ttl2 = loss2_date - preg2_date;
    ttl3 = loss3_date - preg3_date;
    format ttl1 ttl2 ttl3 BEST12.;
run;

*** Delete temporary data set(s).;
proc datasets nolist;
    delete fixedsafcutoffnofilter preg1_dat loss1_dat preg2_dat loss2_dat preg3_dat loss3_dat;
run;
quit;

******************************************************************************;
******************************************************************************;
*** Load PJL data.
*** For each observation, determine ATTEMPT (i.e., ATTEMPT1, ATTEMPT2, or
*** ATTEMPT3), based on the pregnancy dates obtained from the SAF data.
*** Code adapted from ClassifyPJLDataByAttempt123.v2.110912.sas.
******************************************************************************;
******************************************************************************;

*** SAS Data Set pjl
*** Number of observations              = 1899
*** Number of unique occurences of spid = 273
*** Maximum number of repeats of spid   = 9;
data pjl;
    set journals.pjl(keep=spid WEEKS PJBEGDAT PJENDDAT PJWEIGHT PJWTCOM PJREGMUV PJREGMVC PJHBP PJHBPCOM PJAVGCIG PJHGLUC PJHGLCOM);
    label spid = "Site Preferred Participant ID";
    label PJBEGDAT = "Journal Start Date"
          PJENDDAT = "Journal End Date"
          PJWEIGHT = "Weight with clothes (lbs, PJL)"
          PJWTCOM  = "Weight with clothes comment (PJL)"
          PJREGMUV = "Regular multivitamin use (PJL)"
          PJREGMVC = "Regular multivitamin use comment (PJL)"
          PJHBP    = "High Blood Pressure (PJL)"
          PJHBPCOM = "High Blood Pressure comment (PJL)"
          PJAVGCIG = "Average cigarettes daily (PJL)"
          PJCIGCOM = "Average cigarettes daily comment (PJL)"
          PJHGLUC = "High blood sugar (PJL)"
          PJHGLCOM = "High blood sugar comment (PJL)";
    format PJREGMUV VITAMBPJLFMT.;
    format PJHBP    NOYES2PJLFMT.;
    format PJAVGCIG CIGSPJLFMT.;
    format PJHGLUC  SUGARPJLFMT.;
run;
%CountUniqueVals(inputData=pjl,vrbl=spid);

*** Merge PREGDATES into the PJL data set.;
*** SAS Data Set pjl
*** Number of observations              = 1899
*** Number of unique occurences of spid = 273
*** Maximum number of repeats of spid   = 9;
proc sort data=pjl;        by spid WEEKS; run;
proc sort data=preg_dates; by spid;       run;
data pjl;
    merge pjl(in=in1) preg_dates;
    by spid;

    *** Keep only observations that were originally in PJL.;
    if ( in1 );

    *** If PJBEGDAT is not missing, then set TEST_DATE to PJBEGDAT.
    *** Else set TEST_DATE to PJENDDAT.
    *** TEST_DATE will be used to assign observations to ATTEMPT1, ATTEMPT2, or ATTEMPT3,
    *** and to estimate the gestational age.;
    if ( PJBEGDAT ^= . ) then TEST_DATE = PJBEGDAT;
    else TEST_DATE = PJENDDAT;

    *** Use the pregnancy dates to assign each observation to ATTEMPT1, ATTEMPT2, or ATTEMPT3.
    *** Compute estimated gestational age along the way.;
    if ( PJBEGDAT ^= . ) then TEST_DATE = PJBEGDAT;
    else TEST_DATE = PJENDDAT;
    if      ( ( preg3_date ^= . ) AND ( TEST_DATE >= preg3_date ) ) then do;
        ATTEMPT = 3;
        GA_EST = TEST_DATE - preg3_date;
    end;
    else if ( ( preg2_date ^= . ) AND ( TEST_DATE >= preg2_date ) ) then do;
        ATTEMPT = 2;
        GA_EST = TEST_DATE - preg2_date;
    end;
    else if ( ( preg1_date ^= . ) AND ( TEST_DATE >= preg1_date ) ) then do;
        ATTEMPT = 1;
        GA_EST = TEST_DATE - preg1_date;
    end;
    drop TEST_DATE;
 run;
%CountUniqueVals(inputData=pjl,vrbl=spid);

*** WITHIN subject, check whether more than one attempt (ATTEMPT1, ATTEMPT2, or ATTEMPT3)
*** is represented in the PJL.;
data check_attempt;
    retain spid base_attempt more_than_1_attempt;
    set pjl;
    by spid;
    if ( first.spid ) then do;
        base_attempt        = ATTEMPT;
        more_than_1_attempt = 0;
    end;
    else do;
        if ( ATTEMPT ^= base_attempt ) then more_than_1_attempt = 1;
    end;

    if ( last.spid ) then output;
    keep spid more_than_1_attempt;
run;

*** Merge the check on number of ATTEMPTs into the PJL data.;
data pjl;
    retain SPID WEEKS GA_EST PJBEGDAT PJENDDAT
           PJWEIGHT PJWTCOM PJREGMUV PJREGMVC PJHBP PJHBPCOM
           preg1_date preg2_date preg3_date ATTEMPT more_than_1_attempt;
    merge pjl check_attempt;
    by spid;
run;

*** Find all subjects for whom there are apparently more than one ATTEMPTs.;
*** SAS Data Set more_than_one_attempt
*** Number of observations              = 84
*** Number of unique occurences of spid = 11
*** Maximum number of repeats of spid   = 9;
data more_than_one_attempt;
    set pjl;
    if ( more_than_1_attempt > 0 );
run;
%CountUniqueVals(inputData=more_than_one_attempt,vrbl=spid);

*** By manual inspection:
2508851 -- appears to have only one attempt, ATTEMPT1
2656691 -- appears to have only one attempt, ATTEMPT1
2963001 -- appears to have only one attempt, ATTEMPT1
3067541 -- appears to have only one attempt, ATTEMPT1
3067611 -- has 9 observations, 8 are ATTEMPT3, one is ATTEMPT1
3331951 -- appears to have only one attempt, ATTEMPT1
3334361 -- appears to have only one attempt, ATTEMPT1
3340601 -- appears to have only one attempt, ATTEMPT1
3483451 -- has 8 observations, 7 are ATTEMPT2, one is ATTEMPT1
3510461 -- has 9 observations, 8 are ATTEMPT2, one is ATTEMPT1
3553881 -- has 6 observations, 5 are ATTEMPT2, one is ATTEMPT1
***;

*** Based on the manual inspection, set the missing ATTEMPTS for SEVEN subjects.;
data pjl;
    set pjl;
    if ( ( spid = "2508851" )
      OR ( spid = "2656691" ) 
      OR ( spid = "2963001" ) 
      OR ( spid = "3067541" ) 
      OR ( spid = "3331951" ) 
      OR ( spid = "3334361" ) 
      OR ( spid = "3340601" ) ) then ATTEMPT = 1;
run;

*** Recheck multiplicity of attempts.;
data check_attempt2;
    retain spid base_attempt more_than_1_attempt2;
    set pjl;
    by spid;
    if ( first.spid ) then do;
        base_attempt         = ATTEMPT;
        more_than_1_attempt2 = 0;
    end;
    else do;
        if ( ATTEMPT ^= base_attempt ) then more_than_1_attempt2 = 1;
    end;

    if ( last.spid ) then output;
    keep spid more_than_1_attempt2;
run;

*** Merge the check on number of ATTEMPTs into the PJL data.
*** SAS Data Set pjl
*** Number of observations              = 1899
*** Number of unique occurences of spid = 273
*** Maximum number of repeats of spid   = 9;
data pjl;
    retain SPID WEEKS GA_EST PJBEGDAT PJENDDAT
           PJWEIGHT PJWTCOM PJREGMUV PJREGMVC PJHBP PJHBPCOM
           preg1_date loss1_date ttl1 preg2_date loss2_date ttl2 preg3_date loss3_date ttl3
           ATTEMPT more_than_1_attempt more_than_1_attempt2;
    merge pjl check_attempt2;
    by spid;
run;
%CountUniqueVals(inputData=pjl,vrbl=spid);

*** Find all subjects for whom there are apparently more than one ATTEMPTs.;
*** SAS Data Set more_than_one_attempt2
*** Number of observations              = 32
*** Number of unique occurences of spid = 4
*** Maximum number of repeats of spid   = 9;
data more_than_one_attempt2;
    set pjl;
    if ( more_than_1_attempt2 > 0 );
run;
%CountUniqueVals(inputData=more_than_one_attempt2,vrbl=spid);

proc datasets nolist;
    delete preg_dates check_attempt more_than_one_attempt check_attempt2 more_than_one_attempt2;
run;
quit;

******************************************************************************;
******************************************************************************;
*** Load same version of LIFE_WIDE data that was used in the GDM paper.
*** Filter it to include only the subjects who got pregnant in the first attempt.
*** Need to convert SPID from numeric to character.
*** Code adapted from Chem_females (accounting for left truncation)-v49.071812.sas.
******************************************************************************;
******************************************************************************;

*** Load LIFEWIDE data set.;
data life_wide;
    length spid15 $ 15;
    set ttllib.&UPDATED_LIVEWIDE(keep=spid TTP1 status1 TTP2 status2 TTP3 status3);
    if ( status1 = 1 );
    spid15 = input(spid,$15.);
    drop spid;
run;

*** Convert to tall format.;
data life_tall;
    set life_wide;
    array XX[3] TTP1-TTP3;
    array YY[3] status1-status3;

    do ATTEMPT=1 to 3;
        ttp    = XX[ATTEMPT];
        status = YY[ATTEMPT];
        if ( ( ttp ^= . ) AND ( status ^= . ) ) then output;
    end;

    drop TTP1-TTP3 status1-status3;
run;

*** Set SPID to character.;
data life_tall;
    retain spid;
    set life_tall;
    spid = spid15;

    label ttp    = "Time to pregnancy (WITHOUT Left Truncation)";
    label status = "Pregnant (censor variable) (0=no,1=yes)";
    label spid   = "Site Preferred Participant ID";
    drop spid15;
run;

proc datasets nolist;
    delete life_wide;
run;
quit;

*** Merge the PJL and LIFE_WIDE data sets.
*** SAS Data Set pjl
*** Number of observations              = 1898
*** Number of unique occurences of spid = 272
*** Maximum number of repeats of spid   = 9;
proc sort data=pjl;       by spid attempt; run;
proc sort data=life_tall; by spid attempt; run;
data pjl;
    merge life_tall(in=in1) pjl(in=in2);
    by spid ATTEMPT;
    if ( in1 AND in2 );
    if ( ATTEMPT = 1 ) then preg_date = preg1_date;
    if ( ATTEMPT = 1 ) then loss_date = loss1_date;
    if ( ATTEMPT = 1 ) then ttl       = ttl1;
    if ( ATTEMPT = 2 ) then preg_date = preg2_date;
    if ( ATTEMPT = 2 ) then loss_date = loss2_date;
    if ( ATTEMPT = 2 ) then ttl       = ttl2;
    if ( ATTEMPT = 3 ) then preg_date = preg3_date;
    if ( ATTEMPT = 3 ) then loss_date = loss3_date;
    if ( ATTEMPT = 3 ) then ttl       = ttl3;
    format preg_date loss_date MMDDYY8.;
    label preg_date = "Date of positive pregnancy test"
          ATTEMPT   = "Pregnancy Attempt #";
    drop preg1_date loss1_date ttl1 preg2_date loss2_date ttl2 preg3_date loss3_date ttl3;
run;
%CountUniqueVals(inputData=pjl,vrbl=spid);

*** Delete temporary data set(s).;
proc datasets nolist;
    delete life_tall;
run;
quit;

******************************************************************************;
******************************************************************************;
*** EXCLUDE pregnancies that ended before 24 weeks = 24*7 = 168 days.
*** This is repeated-measures data and will be saved separately at the end
*** of this SAS program. In the next section, we use this data set just to
*** start creating the non-repeated measures data set, constrained to the
*** N=258 subjects.
******************************************************************************;
******************************************************************************;

*** SAS Data Set pjl
*** Number of observations              = 1868
*** Number of unique occurences of spid = 258
*** Maximum number of repeats of spid   = 9;
data pjl;
    set pjl;
    if ( ( ttl ^= . ) AND ( ttl < 168 ) ) then delete;
    drop loss_date ttl;
run;
%CountUniqueVals(inputData=pjl,vrbl=spid);

******************************************************************************;
******************************************************************************;
*** Randomize the order of the N=258 female IDs, and use the randomized
*** order to generate a de-identified ID number.
******************************************************************************;
******************************************************************************;

proc sort data=pjl(keep=spid) NODUPKEY; by spid; run;

*** Add a column containing a pseudorandom number.
*** SAS Data Set fmc
*** Number of observations              = 258
*** Number of unique occurences of spid = 258
*** Maximum number of repeats of spid   = 1;
data fmc;
    length spid $ 15.;
    set pjl(keep=spid);
    call streaminit(&RAND_SEED); * RANDOM SEED.;
    randNum = rand("Uniform"); *** Add a column of random numbers to the data.;
run;
%CountUniqueVals(inputData=fmc,vrbl=spid);

*** Randomize the order of observations.;
proc sort data=fmc; by randNum; run;

*** Use the randomized order to generate a de-identified ID number.
*** At this point we can remove the temporary variable RANDNUM.
*** For convenience, also compute the male SPID.;
data fmc;
    set fmc;
    ID = _N_;
    length spidMale $ 15.;
    nspid    = input(spid,BEST12.) + 1;
    spidMale = put(nspid,BEST12.-L); * Do not need the STRIP function with the -L alignment specification!;
    rename spid = spidFemale;
	label spid     = 'SPID (Female)'
          spidMale = 'SPID (Male)'
          ID       = 'De-identified Couple ID';
    drop randNum nspid;
run;

******************************************************************************;
******************************************************************************;
*** Output linking information in both CSV and SAS data file formats.
******************************************************************************;
******************************************************************************;

proc export data=fmc replace label
    outfile="&MAIN_FOLDER/&OUTPUT_FOLDER/Link File - &VERSION..&DATESTR..csv"
    dbms=csv;
run;

data out.Link_File_&VERSION._&DATESTR;
    set fmc;
run;


