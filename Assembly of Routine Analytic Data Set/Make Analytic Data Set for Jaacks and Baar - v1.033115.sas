******************************************************************************;
******************************************************************************;
*** SAS program to create an analytic data set for Jaacks and Baar.
*** See MS Word document named 
*** Dataset Request_Jaacks & Barr_19mar2015.docx
*** attached to email Raji sent on 3/29/2015 at 5:56PM.
***
*** Version 1: Heavily based on the SAS program
*** Make Analytic Data Set - v12.011614.sas
*** from Cuilins GDM study. Here we will use a TTL threshold explicitly for
*** 24 weeks (168 days). It gives the same final N of 258 as a 29-week
*** threshold. See email I sent on 7/20/2014 at 3:12 PM. ("Regarding the question
*** of filtering at 24 vs. 29 weeks: it turns out that whether I exclude
*** pregnancies that ended before 24 weeks (=168 days) or 29 weeks (=203 days),
*** the final N in the data set is N=258.")
******************************************************************************;
******************************************************************************;

%let VERSION       = v1;
%let DATESTR       = 033115;
%let OUTPUT_FOLDER = Output-03-31-15;

%let UPDATED_SAF      = saf_cutoffnofilter_022713; * Version used in the GDM paper.;
%let UPDATED_LIVEWIDE = life_wide_022713;          * Version used in the GDM paper.;
%let JOURNAL_FOLDER   = N:/DIPHRData/LIFE/EmmesData/Journals_01272010;
%let BASELINE_FOLDER  = N:/DIPHRData/LIFE/EmmesData/Baseline_01192010;
%let MAIN_FOLDER      = C:/Documents and Settings/maisogjm/My Documents/LIFE/Data Distributions;
%let TTL_FOLDER       = C:/Users/maisogjm/Documents/LIFE/Data Quality/Time To Loss;
%let CHEM_FOLDER      = C:/Users/maisogjm/Documents/LIFE/Semen Quality and TTP-Informatics;

*** Linking file to de-identify the data.;
%let LINK_FOLDER = Output-03-31-15;
%let LINK_FILE   = link_file_v1_033115;

*** Source of the pregnancy outcome variable.;
%let PREGOUTCOME_FILE   = preg_outcomes_tall_v24_112014; * V19 address zero-cycle pregnancies.;
%let PREGOUTCOME_FOLDER = Output-11-20-14;

libname stress    "C:/Documents and Settings/maisogjm/My Documents/LIFE/Stress";
libname raji       "C:/Documents and Settings/maisogjm/My Documents/LIFE/PHREG";
libname st092311   "C:/Documents and Settings/maisogjm/My Documents/LIFE/Stress/Output-09-23-11";
libname baseline   "&BASELINE_FOLDER";
libname journals   "&JOURNAL_FOLDER";
libname pops       "C:/Users/maisogjm/Documents/LIFE/ChemsTTP(8-7-11)/Sensitivity(CorrectedTTP)";
libname ttllib     "&TTL_FOLDER";
libname outlib     "&MAIN_FOLDER/&OUTPUT_FOLDER";
libname proutlib   "&TTL_FOLDER/&PREGOUTCOME_FOLDER";
libname linklib    "&MAIN_FOLDER/&LINK_FOLDER";

******************************************************************************;
******************************************************************************;
*** Load utility macros.
*** Change the macro variable MACRO_FOLDER to point to the folder on your
*** computer where the macro definitions are stored.;
******************************************************************************;
******************************************************************************;

%let MACRO_FOLDER = C:/Users/maisogjm/Documents/GLOTECH/SAS Utility Macros;
filename macdef "&MACRO_FOLDER/Utility Macros - v47.011515.sas";
%include macdef;

*** Define utility macro to merge a temporary data set into the
*** growing analytic data set, then delete the temporary data set.
*** Macro adapted from the SAS program
*** Make Analytic Data Set for Birth Size and Fecundity Study - v1.120114.sas;
%macro MergeIntoAnalyticDataThenDelete(inputData=);
proc sort data=nonrepeated_dat; by spid; run;
proc sort data=&inputData;      by spid; run;
data nonrepeated_dat;
    merge nonrepeated_dat(in=in1) &inputData;
    by spid;
    if ( in1 );
run;

*** Delete temporary data set(s).;
proc datasets nolist;
    delete &inputData;
run;
quit;
%mend MergeIntoAnalyticDataThenDelete;

*** Define utility macro to load label information from an MS Excel file codebook.
*** Heavily based on code from the SAS program
*** Extract Baseline and Journal Data Sets - v1.120314.sas
*** from the Semen Quality and TTP-Informatics project.;
%macro LoadLabelData(inputFile=,sheet=,skiplines=,droplines=,varCol=,labelCol=,chemClassCol=,unitsCol=);

%let outputData = &sheet._labels;

*** Load MS Excel file that has labels for variables.;
PROC IMPORT OUT=&outputData DATAFILE= "&CHEM_FOLDER/&inputFile" 
            DBMS=xlsx REPLACE;
     SHEET="&sheet"; 
     GETNAMES=YES;
RUN;

*** Remove the first few lines.;
data &outputData;
    set &outputData;
    if ( ( _N_ > &skiplines )
     AND ( _N_ < &droplines ) );
run;

*** Keep only the Variable and Label columns.;
data &outputData;
    set &outputData(keep=&varCol &labelCol &chemClassCol &unitsCol);
    rename &varCol       = Variable
           &labelCol     = Label
           &chemClassCol = ChemicalClass
           &unitsCol     = Units;
    label &varCol       = ' '
          &labelCol     = ' '
          &chemClassCol = ' '
          &unitsCol     = ' ';
run;

%mend LoadLabelData;

*** Define utility macro to apply labels.
*** Macro definition is based on the macro of the same name in the SAS program
*** Extract Baseline and Journal Data Sets - v1.120314.sas
*** where it was in turn based on code from the SAS program
*** Make NON-IMPUTED PFC Analytic Data Set for Kirsten - v4.082814.sas;
%macro ApplyLabels(inputData=,labelData=,maleFemale=);

options nomprint nonotes;

*** Obtain a list of variable names in the input data set.;
ods select none;
proc contents data=&inputData varnum;
    ods output Position = vartab;
run;
ods select all;
proc sql noprint;
    select Variable into :varLIST separated by " " from vartab;
quit;
proc datasets nolist;
    delete vartab;
run;
quit;

%let i = 1;
%let vrbl = %scan(&varLIST,&i);
%do %until( NOT %length(&vrbl));

    *** Obtain the label, insert into a macro variable.;
    %let theLabel =;
    data _NULL_;
        set &labelData;
        if ( lowcase(Variable) = lowcase("&vrbl") ) then call symput("theLabel",strip(Label));
        if ( lowcase(Variable) = lowcase("&vrbl") ) then call symput("theUnits",strip(Units));
    run;

    *** If a label for this variable was found, apply the label.
    *** Also, add the corresponding Variable-Label pair to the code book.;
    %if ( %length(&theLabel) ) %then %do;
        *** Apply label.;
        data &inputData;
            set &inputData;
            label &vrbl = "&theLabel (&theUnits, &maleFemale)";
        run;

        *** Insert the variable-label pair into the code book.;
        data variable_label;
            length Variable $ 32.;
            length Label    $ 256.;
            Variable = "&vrbl";
            Label    = "&theLabel";
        run;
    %end;
    %else %do;
        *** Enter a blank label for this variable.;
        data variable_label;
            length Variable $ 32.;
            length Label    $ 256.;
            Variable = "&vrbl";
            Label    = " ";
        run;
    %end;

    *** Delete temporary data set(s).;
    proc datasets nolist;
        delete variable_label;
    run;
    quit;

    *** Obtain next variable.;
    %let i = %eval( &i + 1 );
    %let vrbl = %scan(&varLIST,&i);
%end;

options notes;

%mend ApplyLabels;

*** Define macro to rename male/female variables to avoid name collisions.
*** Based on the macro RENAMEPFCS from the SAS program
*** Make NON-IMPUTED PFC Analytic Data Set for Kirsten - v4.082814.sas;
%macro RenameChemicalVariables(inputData=,MF=);

data &inputData;
    set &inputData;
    %let i = 1;
    %let vrbl = %scan(&chemLIST,&i);
    %do %until( NOT %length(&vrbl));
        rename &vrbl = &vrbl._&MF;
    %let i = %eval( &i + 1 );
    %let vrbl = %scan(&chemLIST,&i);
    %end;
run;
%mend RenameChemicalVariables;

******************************************************************************;
******************************************************************************;
*** Define formats.
******************************************************************************;
******************************************************************************;

proc format;
    value YESNONUM01FMT
        0 = '0-No'
        1 = '1-Yes';
    value $ YESNOCHAR01FMT
        '0' = '0-No'
        '1' = '1-Yes';
    value RACEFMT
        1 ='1-Non-Hispanic White'
        2 ='2-Non-Hispanic Black'
        3 ='3-Hispanic'
        4 ='4-Other';
    value $ EDU_FMT
        '1' ='1-Less than high school graduate'
        '2' ='2-High school graduate/GED'
        '3' ='3-Some college or technical school'
        '4' ='4-College graduate or higher';
    value $ INCOME_FMT
        'a' ='a - Less than $10,000 (less than $833 per month)'
        'b' ='b - $10,000-$19,999 ($833-$1,666 per month)'
        'c' ='c - $20,000-$29,999 ($1,667-$2,499 per month)'
        'd' ='d - $30,000-$39,999 ($2,500-$3,332 per month)'
        'e' ='e - $40,000-$49,999 ($3,333-$4,166 per month)'
        'f' ='f - $50,000-$59,999 ($4,167-$4,999 per month)'
        'g' ='g - $60,000-$69,999 ($5,000-$5,832 per month)'
        'h' ='h - $70,000-$79,999 ($5,833-$6,666 per month)'
        'i' ='i - $80,000-$89,999 ($6,667-$7,499 per month)'
        'j' ='j - $90,000-$99,999 ($7,500-$8,332 per month)'
        'k' ='k - $100,000 or over ($8,333 and over per month)';
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
    value PREGOUTCOME_FMT
        0 = '0-Loss'
        1 = '1-Birth'
        2 = '2-Lost To Follow-up';
    value PREGOUTCOMEFMT
        1 = '1-Live Birth'
        2 = '2-Miscarriage'
        3 = '3-Stillbirth'
        4 = '4-Abortion'
        5 = '5-Ectopic/tubal'
        6 = '6-Molar pregnancy';
    value $ ETOHBEV
        '1' = '1-Less than once a month'
        '2' = '2-Once a month'
        '3' = '3-Two or three days a month'
        '4' = '4-Once a week'
        '5' = '5-Two or three times a week'
        '6' = '6-Four to six times a week'
        '7' = '7-Every day';
    value $ ETOHTYP
        '1' = '1-One drink'
        '2' = '2-Two drinks'
        '3' = '3-Three drinks'
        '4' = '4-Four drinks'
        '5' = '5-Five drinks or more';
    value $ SMOKEFMT
        '0' = '0-No'
        '1' = '1-Yes, some days'
        '2' = '2-Yes, every day';
    value $ WEEKS_FMT
        '1' = '1-Weeks 9 to 12'
        '2' = '2-Weeks 13 to 16'
        '3' = '3-Weeks 17 to 20'
        '4' = '4-Weeks 21 to 24'
        '5' = '5-Weeks 25 to 28'
        '6' = '6-Weeks 29 to 32'
        '7' = '7-Weeks 33 to 36'
        '8' = '8-Weeks 37 to 40'
        '9' = '9-Weeks 41 to 44';
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
    label WEEKS    = "Indicate Weeks"
          PJBEGDAT = "Journal Start Date"
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
	format WEEKS  $ WEEKS_FMT.;
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
*** Obtain outcome of pregnancy observed during the study.
******************************************************************************;
******************************************************************************;

*** SAS Data Set loss_dat
*** Number of observations              = 347
*** Number of unique occurences of spid = 347
*** Maximum number of repeats of spid   = 1;
data loss_dat;
    set proutlib.&PREGOUTCOME_FILE(keep=spid Attempt PregOutcome);
    label spid = "Site Preferred Participant ID";
run;
%CountUniqueVals(inputData=loss_dat,vrbl=spid);

*** Merge.
*** SAS Data Set pjl
*** Number of observations              = 1898
*** Number of unique occurences of spid = 272
*** Maximum number of repeats of spid   = 9;
proc sort data=pjl;      by spid Attempt; run;
proc sort data=loss_dat; by spid Attempt; run;
data pjl;
    merge pjl(in=in1) loss_dat;
    by spid Attempt;
    if ( in1 );
run;
%CountUniqueVals(inputData=pjl,vrbl=spid);

*** Delete temporary data set(s).;
proc datasets nolist;
    delete loss_dat;
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
*** Start building the non-repeated measures data set, starting with the
*** date of the positive pregnancy test and the pregnancy outcome.
******************************************************************************;
******************************************************************************;

*** SAS Data Set nonrepeated_dat
*** Number of observations              = 258
*** Number of unique occurences of spid = 258
*** Maximum number of repeats of spid   = 1;
proc sort data=pjl(keep=spid preg_date PregOutcome) out=nonrepeated_dat NODUPKEY; by spid; run;
%CountUniqueVals(inputData=nonrepeated_dat,vrbl=spid);

******************************************************************************;
******************************************************************************;
*** Add FEMALE date of birth.
******************************************************************************;
******************************************************************************;

*** SAS Data Set dmf
*** Number of observations              = 501
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 1;
data dmf;
    set baseline.dmf(keep=spid DFDOB);
    label DFDOB = "What is your date of birth? (Females)";
run;
%CountUniqueVals(inputData=dmf,vrbl=spid);

*** Merge data into analytic data set, then delete.;
%MergeIntoAnalyticDataThenDelete(inputData=dmf);

*** Compute age at conception.;
data nonrepeated_dat;
    length spid $ 15.;
    length DFDOB 8.;
    set nonrepeated_dat;
    age_conception = round((preg_date-DFDOB)/365,1);
    label age_conception = "Age at conception (years)";
run;

******************************************************************************;
******************************************************************************;
*** Add FEMALE age at baseline.
******************************************************************************;
******************************************************************************;

*** Obtain FEMALE age from fmc data set.
***
*** Code adapted from the SAS program
*** Make Analytic Data Set For Kate - Dissertation - v10.110514.sas
*** where it was in turn adapted from the SAS program
*** Investigate Computed Age  - v1.121313.sas
*** SAS Data Set fmc
*** Number of observations              = 501
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 1;
data fmc;
    retain spid;
    set baseline.fmc(keep=spid MFCRAGE);
    rename MFCRAGE = Age_f;
run;
%CountUniqueVals(inputData=fmc,vrbl=spid);

*** Insert value of 33 for SPID 3137021.
*** This is the value computed from DOB and enrollment date.
*** Cf. Investigate Computed Age  - v1.121313.sas;
data fmc;
    set fmc;
    if ( spid = "3137021" ) then Age_f = 33;
    label Age_f = "Age at Baseline (years, Females)";
run;

*** Merge data into analytic data set, then delete.;
%MergeIntoAnalyticDataThenDelete(inputData=fmc);

*** Re-arrange variables for convenience,
*** compute age at conception.;
data nonrepeated_dat;
    length spid $ 15.;
    length DFDOB Age_f preg_date age_conception 8.;
    set nonrepeated_dat;
    age_conception = round((preg_date-DFDOB)/365,1);
    label age_conception = "Age at conception (years)";
run;

******************************************************************************;
******************************************************************************;
*** Obtain date of delivery, then compute age at delivery and estimated
*** gestational age at delivery.
******************************************************************************;
******************************************************************************;

*** SAS Data Set bir
*** Number of observations              = 241
*** Number of unique occurences of spid = 239
*** Maximum number of repeats of spid   = 2;
data bir;
    set journals.bir(keep=spid BRBRTHDT BIRTNUM);
    label BRBRTHDT = "Delivery Date";
run;
%CountUniqueVals(inputData=bir,vrbl=spid);

*** Find twin cases.;
data twin_bir;
    set bir;
    if ( BIRTNUM = 2 );
run;
proc sort data=twin_bir; by spid; run;
proc sort data=bir;      by spid; run;
data twin_bir;
    merge twin_bir(keep=spid in=in1) bir;
    by spid;
    if ( in1 );
run;
*** Note that in both twin cases, the delivery date was fortunatley the same for both twins.
*** (It is possible for twins to be delivered on separate days!).
*** This means that we can eliminate one of the twin observations in the BIR
*** data because the date of delivery is redundant.
*** SAS Data Set bir
*** Number of observations              = 239
*** Number of unique occurences of spid = 239
*** Maximum number of repeats of spid   = 1;
data bir;
    set bir;
    if ( BIRTNUM = 2 ) then delete;
    drop BIRTNUM;
run;
%CountUniqueVals(inputData=bir,vrbl=spid);

*** Merge data into analytic data set, then delete.;
%MergeIntoAnalyticDataThenDelete(inputData=bir);

*** Compute age at delivery and estimated gestational age at delivery.;
data nonrepeated_dat;
    set nonrepeated_dat;

    *** Age at delivery.;
    age_delivery = round((BRBRTHDT-DFDOB)/365,1);
    label age_delivery = "Age at delivery (years, Females)";

    *** Gestational age at delivery.;
    ga_delivery = BRBRTHDT-preg_date;
    label ga_delivery = "Estimated gestational age at delivery (days)";
run;

*** Delete temporary data set(s).;
proc datasets nolist;
    delete twin_bir;
run;
quit;

******************************************************************************;
******************************************************************************;
*** Add gravidity and parity
***
*** Adapting code from the SAS program
*** Make IMPUTED Analytic Data Set for PFC-Loss Study - v7.031315.sas
*** where it was in turn adapted from the SAS program
*** Make Imputed Data Set For Rajis Pregnancy Loss Study in R - v24.120514.sas
******************************************************************************;
******************************************************************************;

*** Obtain gravidity and parity data from Sung Duk's SAS data set.
*** These quantities have NOT been truncated yet,
*** so nParity is in [0,5] while nGravidity is in [0,7].
*** SAS Data Set Parity_Gravity
*** Number of observations              = 501
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 1;
data Parity_Gravity;
    set stress.Parity_Gravity;
    nspid = ( id * 10 ) + 1;
    spid  = put(nspid,BEST12.-L); * Do not need the STRIP function with the -L alignment specification!;
    drop id nspid;

    label nGravidity   = "Gravidity"
          nParity      = "Parity";
run;
%CountUniqueVals(inputData=Parity_Gravity,vrbl=spid);

*** Merge into analytic data set.;
%MergeIntoAnalyticDataThenDelete(inputData=Parity_Gravity);

******************************************************************************;
******************************************************************************;
*** Add race/ethnicity, education, health insurance, and income for females
*** and for males.
******************************************************************************;
******************************************************************************;

******************************************************************************;
*** FEMALES.
*** Add race/ethnicity, DFEDU, EducationCat_f, DFHLTHIN, DFHSINCO, IncomeCat_f.
*** Adapting code from the SAS program
*** Make Non-Imputed N501 Pregnancy Loss Analytic Data Set For Descriptive Table - v5.031915.sas
*** where it was in turn adapted from the SAS program
*** Create Subject- And Cycle-Level Data Sets From Day-Level Data Set - v9.022814.sas
******************************************************************************;

*** Preliminary race categorization.;
*** Code borrowed from Phytoestrogens - Table 1.v7.102612.sas.;
*** Preliminary race categorization.;
*** Code borrowed from Phytoestrogens - Table 1.v7.102612.sas.;
data dmf;
    set baseline.dmf;

    *** Female SPID 2970871 answered '1' to DFRCBAA , and all other race/ethnicity variables including DFETHNCT were missing. 
    *** Obviously, this subject counts as Black/African American.  Handle this case as follows.
    *** If DFETHNCT but any of the other race/ethnicity variables is set to 1, set DFETHNCT to 2, and set all other
    *** missing race/ethnicity variables to 0 (except for DFRCOTHS, which is left alone).;
    if ( ( DFETHNCT = " " ) AND ( ( DFRCINDI = "1" ) OR ( DFRCASAN = "1" ) OR ( DFRCBAA  = "1" )
                               OR ( DFRCHAWA = "1" ) OR ( DFRCWHTE = "1" ) OR ( DFRCRCEO = "1" ) ) ) then do;
        if ( DFETHNCT = " " ) then DFETHNCT = "2";
        if ( DFRCINDI = " " ) then DFRCINDI = "0";
        if ( DFRCASAN = " " ) then DFRCASAN = "0";
        if ( DFRCBAA  = " " ) then DFRCBAA  = "0";
        if ( DFRCHAWA = " " ) then DFRCHAWA = "0";
        if ( DFRCWHTE = " " ) then DFRCWHTE = "0";
        if ( DFRCRCEO = " " ) then DFRCRCEO = "0";
    end;

    *** Initialize four output variables.;
    DFRCHISP_FINAL  = 0;
    DFRCWHITE_FINAL = INPUT(DFRCWHTE,8.);
    DFRCBAA_FINAL   = INPUT(DFRCBAA,8.);
    DFRCOTHER_FINAL = 0;

    *** If subject answered '1' to DFRCINDI, DFRCASAN, or DFRCHAWA, immediately classify  this subject as OTHER.;
    if ( ( DFRCINDI = "1" ) OR ( DFRCASAN = "1" ) OR ( DFRCHAWA = "1" ) ) then do;
        DFRCHISP_FINAL  = 0;
        DFRCBAA_FINAL   = 0;
        DFRCWHITE_FINAL = 0;
        DFRCOTHER_FINAL = 1;
    end;
    else do;
        *** If subject answered '1' to DFETHNCT, immediately classify this subject as Hispanic;
        if ( DFETHNCT = "1" ) then do;
            DFRCHISP_FINAL  = 1;
            DFRCWHITE_FINAL = 0;
            DFRCBAA_FINAL   = 0;
            DFRCOTHER_FINAL = 0;
        end;
        if ( DFETHNCT = "2" ) then do;
            DFRCHISP_FINAL  = 0;
            DFRCOTHER_FINAL = 0;

            *** Female SPID 2605901 answered '2' to DFETHNCT and '0' to all other race/ethnicity
            *** variables except for DFRCOTHS, which was missing.;
            *** In this situation, delete the observation.;
            if  ( ( DFRCINDI = "0" ) AND ( DFRCASAN = "0" ) AND ( DFRCBAA  = "0" )
              AND ( DFRCHAWA = "0" ) AND ( DFRCWHTE = "0" ) AND ( DFRCRCEO = "0" ) AND ( DFRCOTHS = " " ) ) then delete;

            *** Female SPID 2657181 answered '2' to DFETHNCT, '1' to both DFRCBAA_FINAL and DFRCWHITE_FINAL,
            *** and '0' all other race/ethnicity variables except for DFRCOTHS, which was missing.;
            *** Count this situation as BLACK.;
            if  ( ( DFRCINDI = "0" ) AND ( DFRCASAN = "0" ) AND ( DFRCBAA  = "1" )
              AND ( DFRCHAWA = "0" ) AND ( DFRCWHTE = "1" ) AND ( DFRCRCEO = "0" ) AND ( DFRCOTHS = " " ) ) then do;
                DFRCHISP_FINAL  = 0;
                DFRCWHITE_FINAL = 0;
                DFRCBAA_FINAL   = 1;
                DFRCOTHER_FINAL = 0;
            end;

            *** SPID 3060541 answered '2' to DFETHNCT, '0' to DFRCHTE, and all other race/ethnicity variables 
            *** were missing.  Handle this case as follows.
            *** If DFETHNCT is set to '2' but all of the other race/ethnicity variables are either set to 0 or missing, delete this subject.;
            if ( ( ( DFRCINDI = "0" ) OR ( DFRCINDI = " " ) )
             AND ( ( DFRCBAA  = "0" ) OR ( DFRCBAA  = " " ) )
             AND ( ( DFRCHAWA = "0" ) OR ( DFRCHAWA = " " ) )
             AND ( ( DFRCWHTE = "0" ) OR ( DFRCWHTE = " " ) )
             AND ( ( DFRCRCEO = "0" ) OR ( DFRCRCEO = " " ) )
             AND ( ( DFRCOTHS = "0" ) OR ( DFRCOTHS = " " ) ) ) then delete;

            *** SPID 3120901 answered '2' to DFETHNCT, '1' to DFRCRCEO, "Hispanic/Black" to DFRCOTHS, and '0' 
            *** to all other race/ethnicity variables. Count this case as Hispanic.;
            if ( indexw(lowcase(DFRCOTHS),"hispanic/black") > 0 ) then do;
                DFRCHISP_FINAL  = 1;
                DFRCWHITE_FINAL = 0;
                DFRCBAA_FINAL   = 0;
                DFRCOTHER_FINAL = 0;
            end;

            *** SPID 3222141 answered '2' to DFETHNCT, '1' to DFRCRCEO, "Russian" to DFRCOTHS, and '0' to all 
            *** other race/ethnicity variables.
            *** Similarly, SPID 3237551 answered '2' to DFETHNCT, '1' to DFRCRCEO, "Greek" to DFRCOTHS, and '0' to all 
            *** other race/ethnicity variables. Count these cases as White.;
            if ( ( indexw(lowcase(DFRCOTHS),"russian") > 0 )
              OR ( indexw(lowcase(DFRCOTHS),"greek")   > 0 ) ) then do;
                DFRCHISP_FINAL  = 0;
                DFRCWHITE_FINAL = 1;
                DFRCBAA_FINAL   = 0;
                DFRCOTHER_FINAL = 0;
            end;

            *** SPID 3331771 answered '2' to DFETHNCT, '1' to DFRCRCEO, "Egyptian" to DFRCOTHS, and '0' 
            *** to all other race/ethnicity variables.
            *** Similarly, SPID 3358171 answered '2' to DFETHNCT, '1' to DFRCRCEO, "east indian" to DFRCOTHS, and '0' to 
            *** all other race/ethnicity variables.  Count these cases as Other.;
            if ( ( indexw(lowcase(DFRCOTHS),"egyptian")    > 0 )
              OR ( indexw(lowcase(DFRCOTHS),"east indian") > 0 ) ) then do;
                DFRCHISP_FINAL  = 0;
                DFRCWHITE_FINAL = 0;
                DFRCBAA_FINAL   = 0;
                DFRCOTHER_FINAL = 1;
            end;

            *** If we get this far, if DFRCWHITE_FINAL is missing set it to 0. Similarly for DFRCBAA_FINAL;
            if ( DFRCWHITE_FINAL = . ) then DFRCWHITE_FINAL = 0;
            if ( DFRCBAA_FINAL   = . ) then DFRCBAA_FINAL  = 0;
        end;
    end;

    *** Check for exclusive classification -- DFRCCHECK should always equal 1.;
    *** Subjects should belong to exactly one of the four racial/ethnicity classes;
    DFRCCHECK = DFRCWHITE_FINAL + DFRCBAA_FINAL + DFRCHISP_FINAL + DFRCOTHER_FINAL;

    label DFEDU    = "Education (Females)"
          DFHSINCO = "Income (Females)"
          DFHLTHIN = "Health Insurance (Females)";

    keep spid DFRCWHITE_FINAL DFRCBAA_FINAL DFRCHISP_FINAL DFRCOTHER_FINAL DFRCCHECK DFEDU DFHSINCO DFHLTHIN;
run;

*** Re-code categorical variables for race/ethnicity, education, health insurance, and income.;
data dmf;
    retain spid RaceEthnicity_f DFEDU DFHLTHIN DFHSINCO;

    set dmf;
    format DFEDU    $ EDU_FMT.
           DFHLTHIN $ YESNOCHAR01FMT.
           DFHSINCO $ INCOME_FMT.;

    *** Race/ethnicity.;
    if ( ( DFRCWHITE_FINAL = . ) AND ( DFRCBAA_FINAL = . ) AND ( DFRCHISP_FINAL = . ) AND ( DFRCOTHER_FINAL = . ) ) then RaceEthnicity_f = .;
    else if ( DFRCWHITE_FINAL = 1 ) then RaceEthnicity_f = 1;
    else if ( DFRCBAA_FINAL   = 1 ) then RaceEthnicity_f = 2;
    else if ( DFRCHISP_FINAL  = 1 ) then RaceEthnicity_f = 3;
    else if ( DFRCOTHER_FINAL = 1 ) then RaceEthnicity_f = 4;
    format RaceEthnicity_f RACEFMT.;

    label DFEDU           = "Education (Females)"
          DFHSINCO        = "Income (Females)"
          DFHLTHIN        = "Health Insurance (Females)"
          RaceEthnicity_f = "Race/Ethnicity (Females)";

    keep spid RaceEthnicity_f DFEDU DFHLTHIN DFHSINCO;
run;

*** Merge into analytic data set.;
%MergeIntoAnalyticDataThenDelete(inputData=dmf);

******************************************************************************;
******************************************************************************;
*** Add medical history.
*** Adapting code from the SAS program
*** Make Analytic Data Set for Paulines Air Pollution Study - v3.012315.sas
******************************************************************************;
******************************************************************************;

data fma;
    retain spid;
    set baseline.fma(keep=spid MFHYPODS MFHYPOTX
                               MFHYPRDS MFHYPRTX
                               MFHIGHBP MFHGBPTX
                               MFDIABTS MFDIABTX MFDTXDIT MFDTXPIL MFDTXINS
                               MFGSTDIB
                               MFEATDIS MFETDSTX
                               MFPVRSYN MFPVRSTX);
    label MFHYPODS = "Previous History of Hypothyroid Disease (Females)"
          MFHYPOTX = "Currently Receiving Medical Treatment for Hypothyroid Disease (Females)"
          MFHYPRDS = "Previous History of Hyperthyroid Disease (Females)"
          MFHYPRTX = "Currently Receiving Medical Treatment for Hyperthyroid Disease (Females)"
          MFHIGHBP = "Previous History of High Blood Pressure When You Were Not Pregnant (Females)"
          MFHGBPTX = "Currently Receiving Medical Treatment for High Blood Pressure When Not Pregnant (Females)"
          MFDIABTS = "Previous History of Diabetes (Females)"
          MFDIABTX = "Currently Receiving Medical Treatment for Diabetes (Females)"
          MFDTXDIT = "Medical Treatment for Diabetes Includes Diet (Females)"
          MFDTXPIL = "Medical Treatment for Diabetes Includes Pills (Females)"
          MFDTXINS = "Medical Treatment for Diabetes Includes Insulin (Females)"
          MFGSTDIB = "Previous History of Gestational Diabetes (Females)"
          MFEATDIS = "Previous History of Eating Disorder (Females)"
          MFETDSTX = "Currently Receiving Medical Treatment for Eating Disorder (Females)"
          MFPVRSYN = "Previous History of Polycystic Ovarian Syndrome (Females)"
          MFPVRSTX = "Currently Receiving Medical Treatment for Polycystic Ovarian Syndrome (Females)";
    format MFHYPODS MFHYPOTX
           MFHYPRDS MFHYPRTX
           MFHIGHBP MFHGBPTX
           MFDIABTS MFDIABTX MFDTXDIT MFDTXPIL MFDTXINS
           MFGSTDIB
           MFEATDIS MFETDSTX
           MFPVRSYN MFPVRSTX $ YESNOCHAR01FMT.;
run;

*** Merge data into analytic data set, then delete.;
%MergeIntoAnalyticDataThenDelete(inputData=fma);

******************************************************************************;
******************************************************************************;
*** Extract current prescription medications (yes/no and list).
*** Adapting code from the SAS program
*** Extract Medication Information from Baseline and Journal Data Sets - v4.121014.sas
******************************************************************************;
******************************************************************************;

*** SAS Data Set fmc
*** Number of observations              = 501
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = ;
data fmc;
    length spid $ 15.;
    set baseline.fmc(keep=spid
                          MFRXMDA MFMEDNUM MFRXMED1-MFRXMED9
                          MFRXMD1C MFRXMD2C MFRXMD3C MFRXMD4C MFRXMD5C MFRXMD6C MFRXMD7C MFRXMD8C MFRXMD9C
                          MFTETRCY MFTETRNM MFTETMD1-MFTETMD5
                          MFTTMT1 MFTETMT2-MFTETMT5 MFTETYR1-MFTETYR5);
    format MFRXMDA MFTETRCY $ YESNOCHAR01FMT.;
    label MFRXMDA  = 'Are you currently taking any prescription medications, including prescription vitamins? (Females)'
          MFMEDNUM = 'How many prescription medications? (Females)'
          MFTETRCY = 'Tetracycline intake (Interviewer: Is the woman taking any of the tetracyclines listed above that are contraindicated for the fertility monitor?) (Females)'
          MFTETRNM = 'Number of Tetracyclines (Females)'
          MFTTMT1  = 'Tetracycline month 1 (Females)';
    rename MFTTMT1 = MFTETMT1;
    %macro labelAndFormatFMC();
        %do i = 1 %to 9;
        label MFRXMD&i.C = "Prescription &i Bottle Available for Confirmation (Females)";
        label MFRXMED&i  = "Prescription medication &i (Females)";
        format MFRXMD&i.C $ YESNOCHAR01FMT.;
        %end;
        %do i = 1 %to 5;
        label MFTETMD&i = "Tetracycline Medication &i (Females)";
        label MFTETYR&i = "Tetracycline year &i (Females)";
        %end;
        %do i = 2 %to 5;
        label MFTETMT&i = "Tetracycline month &i (Females)";
        %end;
    %mend labelAndFormatFMC;
    %labelAndFormatFMC();
run;
%CountUniqueVals(inputData=fmc,vrbl=spid);

*** Merge data into analytic data set, then delete.;
%MergeIntoAnalyticDataThenDelete(inputData=fmc);

*** Obtain multivitamin and supplement use history from data set FMC.
*** Here, adapting code from the SAS program
*** Extract Nutrition Supplement Exposures - v2.111914.sas;
data fmc_mvi_suppl;
    set baseline.fmc(keep=spid
                          MFMLVITA MFSUPFSH MFSUPECH MFSUPGIN MFSUPKAV MFSUPSTJ MFSUPSHK MFSUPSTR MFSUPCRE MFSUPOTH
                          MFSUPSP MFSUPSP2-MFSUPSP7);
    format MFMLVITA MFSUPFSH MFSUPECH MFSUPGIN MFSUPKAV MFSUPSTJ MFSUPSHK MFSUPSTR MFSUPCRE MFSUPOTH $ YESNOCHAR01FMT.;
    label MFMLVITA = 'In the past 3 months, did you take a multivitamin such as One-a-Day, Theragran-M, Centrum (as pills, liquids, or packets) more than once a week? (Females)'
          MFSUPFSH = 'In the past 3 months, did you take Fish oil (omega-3 fatty acids) more than once a week (Females)'
          MFSUPECH = 'In the past 3 months, did you take Echinacea more than once a week (Females)'
          MFSUPGIN = 'In the past 3 months, did you take Ginko biloba more than once a week (Females)'
          MFSUPKAV = 'In the past 3 months, did you take Kava, Kava more than once a week (Females)'
          MFSUPSTJ = 'In the past 3 months, did you take St. Johns Wort more than once a week (Females)'
          MFSUPSHK = 'In the past 3 months, did you take Protein shakes more than once a week (Females)'
          MFSUPSTR = 'In the past 3 months, did you take Steroids more than once a week (Females)'
          MFSUPCRE = 'In the past 3 months, did you take Creatine more than once a week (Females)'
          MFSUPOTH = 'In the past 3 months, did you take Other supplements more than once a week (Females)'
          MFSUPSP  = 'Other supplement 1 (What supplements are you taking?) (Females)';
    rename MFSUPSP = MFSUPSP1;
    %macro labelAndFormatFMC2();
        %do i = 2 %to 7;
        label MFSUPSP&i  = "Other supplement &i (What supplements are you taking?) (Females)";
        %end;
    %mend labelAndFormatFMC2;
    %labelAndFormatFMC2();
run;

*** Merge data into analytic data set, then delete.;
%MergeIntoAnalyticDataThenDelete(inputData=fmc_mvi_suppl);

*** Obtain most and least weighed in the past 12 months.;
data fmc_weight;
    set baseline.fmc(keep=spid
                          MFWTMOST MFWTLEST
                          MFW15T19 MFW20T24 MFW25T29 MFW30T34 MFW35T40);
    label MFWTMOST = "What is the most you weighed in the past 12 months? (lbs, Females)"
          MFWTLEST = "What is the least you weighed in the past 12 months? (lbs, Females)"
          MFW15T19 = "Not including pregnancies, what was your average weight when you were 15 to 19 years old? (lbs, Females)"
          MFW20T24 = "Not including pregnancies, what was your average weight when you were 20 to 24 years old? (lbs, Females)"
          MFW25T29 = "Not including pregnancies, what was your average weight when you were 25 to 29 years old? (lbs, Females)"
          MFW30T34 = "Not including pregnancies, what was your average weight when you were 30 to 34 years old? (lbs, Females)"
          MFW35T40 = "Not including pregnancies, what was your average weight when you were 35 to 40 years old? (lbs, Females)";
run;

*** Merge data into analytic data set, then delete.;
%MergeIntoAnalyticDataThenDelete(inputData=fmc_weight);

******************************************************************************;
******************************************************************************;
*** Add Ever Been Pregnant.
******************************************************************************;
******************************************************************************;

*** Obtain history of any previous pregnancies.
*** SAS Data Set Rf2
*** Number of observations              = 501
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 1;
data Rf2;
    set baseline.rf2(keep=spid RFPRGHST);
    format RFPRGHST $ YESNOCHAR01FMT.;
    label RFPRGHST = "Have you ever been pregnant, regardless of the outcome of a particular pregnancy? (Females)";
run;
%CountUniqueVals(inputData=Rf2,vrbl=spid);

*** Merge data into analytic data set, then delete.;
%MergeIntoAnalyticDataThenDelete(inputData=Rf2);

******************************************************************************;
******************************************************************************;
*** Extract history of prior pregnancies.
*** This is repeated-measures data and will be saved separately at the end
*** of this SAS program.
******************************************************************************;
******************************************************************************;

*** Load PRF data.
*** SAS Data Set prf_wide
*** Number of observations              = 545
*** Number of unique occurences of spid = 289
*** Maximum number of repeats of spid   = 7;
data prf_wide;
    length SPID $ 15.;
    set baseline.prf(keep=spid PREGNUM PRWTGN
                          PRFOTCM1-PRFOTCM5
                          PRWKNUM1-PRWKNUM5
                          PRIBRW1L PRIBRW2L PRIBRW3L PRIBRW4L PRIBRW5L
                          PRIBRW1O PRIBRW2O PRIBRW3O PRIBRW4O PRIBRW5O);
    format PRFOTCM1-PRFOTCM5 PREGOUTCOMEFMT.;
    label PREGNUM = "Pregnancy Number (Females)"
          PRWTGN = "How much weight did you gain during the pregnancy (lbs)? (Females)";
    %macro LabelPrf();
    %let letterLIST = A B C D E;
    %do i = 1 %to 5;
        %let LETTER = %scan(&letterLIST,&i);
        label PRFOTCM&i  = "Outcome for Fetus &LETTER (Females)";
        label PRWKNUM&i  = "How many weeks did you carry this pregnancy? - Fetus &LETTER (Females)";
        label PRIBRW&i.L = "How much did this child weigh (lbs)? - Fetus &LETTER (Females)";
        label PRIBRW&i.O = "How much did this child weigh (oz)? - Fetus &LETTER (Females)";
    %end;
    %mend LabelPrf;
    %LabelPrf();
run;
%CountUniqueVals(inputData=prf_wide,vrbl=spid);

******************************************************************************;
******************************************************************************;
*** Add How Much Did You Weight When You Were Born.
******************************************************************************;
******************************************************************************;

data fhf;
    set baseline.fhf(keep=spid FFBRWTLB FFBRWTOZ);
    label FFBRWTLB = "How much did you weigh when you were born? (lbs, Females)"
          FFBRWTOZ = "How much did you weigh when you were born? (oz, Females)";
run;

*** Merge data into analytic data set, then delete.;
%MergeIntoAnalyticDataThenDelete(inputData=fhf);

******************************************************************************;
******************************************************************************;
*** Add lifestyle variables.
*** Adapting code from the SAS program
*** Make Non-Imputed Analytic Data Set for Iodine Study - v4.030315.sas
******************************************************************************;
******************************************************************************;

proc format;
    value $ FEELINGFMT
        '0' = '0-Never'
        '1' = '1-Almost never'
        '2' = '2-Sometimes'
        '3' = '3-Fairly often'
        '4' = '4-Very often';
    value $ EATFISHFMT
        '0' = '0-Never or almost never'
        '1' = '1-Less than once a month'
        '2' = '2-About once or twice a month'
        '3' = '3-About once a week'
        '4' = '4-Two or more times a week';
run;

***************************************;
*** FEMALES.
***************************************;

*** SAS Data Set LFF
*** Number of observations              = 501
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 1;
data LFF;
    set baseline.LFF(keep=spid LFEXERCS LFEXERDY
                               LFCIGNOD LFSMKCGD LFSMKPIP LFSMKCIG LFSMKSNF LFSMKCTO LFSMKPCK
                               LFSMK12M LFSMKNOW
                               LFTOBPIP LFTOBCGR LFTOBSNF LFTOBCHW
                               LFAL12DR LFETOHFR LFETOHTY LFFVEORM
                               LFNCONTR LFCONFDN LFTHNGOK LFDFFCLT
                               LFAGERSM LFASTPSM LFCAFFEI
                               LFFSHINM LFFSINTX
                               LFFSHTNA LFFSHUNK LFFSHSHL LFFSCTMI LFFSHCTX LFFSHLMI LFFSHLTX LFFSHMIY LFFSHTXY LFFISHTY LFFSHTY1-LFFSHTY3 LFFSHWT1-LFFSHWT3);
    label LFEXERCS = 'During the past 12 months, have you followed a regular vigorous exercise program? (Females)'
          LFEXERDY = 'How many days on average do you exercise per week? (Females)'
          LFSMK12M = 'Have you smoked in the last 12 months? (Females)'
          LFSMKNOW = 'Do you smoke now? (Females)'
          LFTOBPIP = 'Have you smoked a pipe at least 20 times in your entire life? (Females)'
          LFTOBCGR = 'Have you smoked cigars at least 20 times in your entire life? (Females)'
          LFTOBSNF = 'Have you used snuff such as Skoal, Skoal Bandit or Copenhagen at least 20 times in your entire life? (Females)'
          LFTOBCHW = 'Have you used chewing tobacco such as Redman, Levi Garrett or Beechnut at least 20 times in your entire life? (Females)'
          LFAL12DR = 'In the past 12 months, have you had at least 12 drinks of any kind of alcoholic beverage? (Females)'
          LFETOHFR = 'Approximately how often did you drink some kind of alcoholic beverage? (Females)'
          LFETOHTY = 'Approximately how many alcoholic drinks did you have on a typical occasion? (Females)'
          LFFVEORM = 'Was there ever a single occasion during which you drank five or more alcoholic drinks? (Females)'
          LFNCONTR = 'In the last month, how often have you felt that you were unable to control the important things in your life? (Females)'
          LFCONFDN = 'In the last month, how often have you felt confident in your ability to handle your personal problems? (Females)'
          LFTHNGOK = 'In the last month, how often have you felt that things were going your way? (Females)'
          LFDFFCLT = 'In the last month, how often have you felt difficulties were piling up so high that you could not overcome them? (Females)'
          LFCIGNOD = 'When you last smoked, approximately how many cigarettes did you smoke on a typical day? (Females)'
          LFSMKCGD = 'Approximately how many cigarettes do you smoke on a typical day? (Females)'
          LFSMKPIP = 'Do you currently smoke a pipe? (Females)'
          LFSMKCIG = 'Do you currently smoke cigars? (Females)'
          LFSMKSNF = 'Do you currently use snuff? (Females)'
          LFSMKCTO = 'Do you currently use chewing tobacco? (Females)'
          LFSMKPCK = 'Have you smoked more than 100 cigarettes (5 packs) during your lifetime? (Females)'
          LFAGERSM = 'How old were you when you first started smoking regularly, that is daily or nearly everyday? (Females)'
          LFASTPSM = 'How old were you when you quit smoking regularly? (Females)'
          LFCAFFEI = 'On average during the past 12 months, approximately how many caffeinated beverages did you drink in a typical day? (Females)'
          LFFSHINM = 'Do you or a member of your household catch fish or shellfish in local waters including lakes, rivers, streams, and the Great Lakes? (Females)'
          LFFSINTX = 'Do you or a member of your household catch fish or shellfish in local waters including lakes, rivers, bays, ship channels, local ocean waters and the Gulf of Mexico? (Females)'
          LFFSHTNA = 'On average, during the past 12 months, how often did you eat canned tuna fish? (Females)'
          LFFSHUNK = 'On average, during the past 12 months, how often did you eat fish caught in an unknown location (other than canned tuna fish) that was given to you or purchased from a vendor, grocery store or restaurant? (Females)'
          LFFSHSHL = 'On average, during the past 12 months, how often did you eat crabs, shrimp or other shellfish caught in an unknown location that was given to you or purchased from a vendor, grocery store or restaurant? (Females)'
          LFFSCTMI = 'On average, during the past 12 months, how often did you eat fish caught in this area including lakes, rivers, streams, and the Great Lakes? (Females)'
          LFFSHCTX = 'On average, during the past 12 months, how often did you eat fish caught in this area including lakes, rivers, bays, ship channels, local ocean waters and the Gulf of Mexico? (Females)'
          LFFSHLMI = 'On average, during the past 12 months, how often did you eat crabs, shrimp or other shellfish caught in this area including lakes, rivers, streams, and the Great Lakes? (Females)'
          LFFSHLTX = 'On average, during the past 12 months, how often did you eat crabs, shrimp or other shellfish caught in this area including lakes, rivers, bays, ship channels, local ocean waters and the Gulf of Mexico? (Females)'
          LFFSHMIY = 'Out of the past 10 years, how many years have you eaten fish or shellfish that were caught in local waters, including lakes, rivers, streams and the Great Lakes? (Females)'
          LFFSHTXY = 'Out of the past 10 years, how many years have you eaten fish or shellfish that were caught in local waters, including lakes, rivers, bays, ship channels, local ocean waters and the Gulf of Mexico? (Females)'
          LFFISHTY = 'How many types of fish or shellfish caught from this area did you eat most often over the past 12 months?  (Females)'
          LFFSHTY1 = 'Type of Fish or Shellfish #1 (Females)'
          LFFSHTY2 = 'Type of Fish or Shellfish #2 (Females)'
          LFFSHTY3 = 'Type of Fish or Shellfish #3 (Females)'
          LFFSHWT1 = 'Water Body Where Caught #1 (Females)'
          LFFSHWT2 = 'Water Body Where Caught #2 (Females)'
          LFFSHWT3 = 'Water Body Where Caught #3 (Females)';
    format LFEXERCS LFSMK12M LFSMKNOW LFTOBPIP LFTOBCGR LFTOBSNF LFTOBCHW LFAL12DR LFFVEORM LFSMKPCK LFFSHINM LFFSINTX $ YESNOCHAR01FMT.
           LFETOHFR $ ETOHBEV.
           LFETOHTY $ ETOHTYP.
           LFNCONTR LFCONFDN LFTHNGOK LFDFFCLT $ FEELINGFMT.
           LFSMKPIP LFSMKCIG LFSMKSNF LFSMKCTO $ SMOKEFMT.
           LFFSHTNA LFFSHUNK LFFSHSHL LFFSCTMI LFFSHCTX LFFSHLMI LFFSHLTX $ EATFISHFMT.;
    keep spid LFEXERCS LFSMK12M LFSMKNOW LFSMKPIP LFSMKCIG LFSMKSNF LFSMKCTO LFAL12DR LFETOHFR LFETOHTY LFFVEORM;
run;
%CountUniqueVals(inputData=LFF,vrbl=spid);

*** Missing values of LFSMKNOW are negative responses.;
data LFF;
    set LFF;
    if ( LFSMKNOW = . ) then LFSMKNOW = 0;
run;

*** Merge into analytic data set.;
%MergeIntoAnalyticDataThenDelete(inputData=LFF);

******************************************************************************;
******************************************************************************;
*** Add measured weight and height, waist, and hip circumference.
******************************************************************************;
******************************************************************************;

data dmf;
    set baseline.DMF(keep=spid DFWEGHT1 DFWEGHT2 DFWEGHT3 DFSLFWGT
                               DFHEGHT1 DFHEGHT2 DFHEGHT3
                               DFWAIST1 DFWAIST2 DFWAIST3
                               DFHIPME1 DFHIPME2 DFHIPME3);
    label DFWEGHT1 = "Weight, First Measurement (kg, Females)"
          DFWEGHT2 = "Weight, Second Measurement (kg, Females)"
          DFWEGHT3 = "Weight, Third Measurement (kg, Females)"
          DFHEGHT1 = "Height, Third Measurement (cm, Females)"
          DFHEGHT2 = "Height, Second Measurement (cm, Females)"
          DFHEGHT3 = "Height, Third Measurement (cm, Females)"
          DFWAIST1 = "Waist, Third Measurement (cm, Females)"
          DFWAIST2 = "Waist, Second Measurement (cm, Females)"
          DFWAIST3 = "Waist, Third Measurement (cm, Females)"
          DFHIPME1 = "Hip, Third Measurement (cm, Females)"
          DFHIPME2 = "Hip, Second Measurement (cm, Females)"
          DFHIPME3 = "Hip, Third Measurement (cm, Females)";
    drop DFSLFWGT;
run;

*** Merge into analytic data set.;
%MergeIntoAnalyticDataThenDelete(inputData=dmf);

******************************************************************************;
******************************************************************************;
*** Here, obtain BIRTH WEIGHT information from the BIR data set.
*** We again need to access BIR, but here do not remove the repeat twin
*** observations, because we want to preserve the birth weight for both twins.
*** This is repeated-measures data but will be widened so that it is
*** non-repeated measures. Then it will be merged into the N=258 non-repeated
*** measures data set.
******************************************************************************;
******************************************************************************;

*** SAS Data Set bir
*** Number of observations              = 241
*** Number of unique occurences of spid = 239
*** Maximum number of repeats of spid   = 2;
data bir;
    set journals.bir(keep=spid BRBRTHDT BIRTNUM BRWGHTLB BRWGHTOZ);
    label spid     = "Site Preferred Participant ID"
          BRBRTHDT = "Delivery Date"
          BIRTNUM  = "Birth Number"
          BRWGHTLB = "Birth weight (lbs.)"
          BRWGHTOZ = "Birth weight (oz.)";
run;
%CountUniqueVals(inputData=bir,vrbl=spid);

*** Keep only the N=258 cases. (It just so happens that all BIR subjects are in NONREPEATED_DAT.)
*** SAS Data Set bir
*** Number of observations              = 241
*** Number of unique occurences of spid = 239
*** Maximum number of repeats of spid   = 2;
proc sort data=bir;             by spid; run;
proc sort data=nonrepeated_dat; by spid; run;
data bir;
    merge bir(in=in1) nonrepeated_dat(keep=spid);
    by spid;
    if ( in1 );
run;
%CountUniqueVals(inputData=bir,vrbl=spid);

*** Widen the BIR data set.
*** SAS Data Set bir_wide
*** Number of observations              = 239
*** Number of unique occurences of spid = 239
*** Maximum number of repeats of spid   = 1;
proc sort data=bir; by spid BIRTNUM; run;
data bir_wide;
    retain BRWGHTLB1 BRWGHTOZ1 BRWGHTLB2 BRWGHTOZ2;
    set bir(drop=BRBRTHDT);
    by spid BIRTNUM;

    *** Initialize.;
    if ( first.spid ) then do;
        BRWGHTLB1 = .;
        BRWGHTLB2 = .;
        BRWGHTOZ1 = .;
        BRWGHTOZ2 = .;
    end;

    *** Set values.;
    if ( BIRTNUM = 1 ) then BRWGHTLB1 = BRWGHTLB;
    if ( BIRTNUM = 1 ) then BRWGHTOZ1 = BRWGHTOZ;
    if ( BIRTNUM = 2 ) then BRWGHTLB2 = BRWGHTLB;
    if ( BIRTNUM = 2 ) then BRWGHTOZ2 = BRWGHTOZ;
    label BRWGHTLB1 = "Birth weight (lbs), infant #1"
          BRWGHTOZ1 = "Birth weight (oz), infant #1"
          BRWGHTLB2 = "Birth weight (lbs), infant #2 (in case of twin pregnancy)"
          BRWGHTOZ2 = "Birth weight (oz), infant #2 (in case of twin pregnancy)";

    *** Output line.;
    if ( last.spid ) then output;

    keep spid BRWGHTLB1 BRWGHTLB2 BRWGHTOZ1 BRWGHTOZ2;
run;
%CountUniqueVals(inputData=bir_wide,vrbl=spid);

*** Merge into analytic data set.;
%MergeIntoAnalyticDataThenDelete(inputData=bir_wide);

*** Delete temporary data set(s).;
proc datasets nolist;
    delete bir;
run;
quit;

******************************************************************************;
******************************************************************************;
*** Add POPs.
*** Adapting code from the SAS program
*** Make Analytic Data Set for Tobacco and TTP Study - v6.010815.sas
*** where it was in turn adapted from the SAS program
*** Make Analytic Data Set for Sunnis UV Filter and Semen Study - v1.121014.sas
*** where it was in turn adapted from the SAS program
*** Make Analytic Data Set for Paulines Air Pollution Study - v1.120914.sas
*** where it was in turn adapted from the SAS program
*** UV Filters - Make Table of Geometric Means Stratified By Seasonality - v2.080414.sas
******************************************************************************;
******************************************************************************;

*** Obtain label information.;
%LoadLabelData(inputFile=Lab_DD.xlsx,sheet=DAD,skiplines=27,droplines=116,varCol=E,labelCol=F,chemClassCol=G,unitsCol=H);

*** Edit variable names to conform to actual variable names in the legacy analytic data set.;
data DAD_labels;
    length Variable $ 32.;
    set DAD_labels;
    if ( Variable = 'BB1' ) then Variable = 'popbb1amt';
    else if ( ChemicalClass = 'polybrominated diphenyl ethers' ) then Variable = lowcase(cat('PBDE',strip(Variable),'AMT'));
    else if ( ChemicalClass = 'perfluorochemicals' )             then Variable = lowcase(cat('PFC',strip(Variable),'AMT'));
    else if ( ChemicalClass = 'organochlorine pesticides' )      then Variable = lowcase(cat('POP',strip(Variable),'AMT'));
    else if ( ChemicalClass = 'polychlorinated biphenyls' )      then Variable = lowcase(cat('PCB',strip(Variable),'AMT'));
    else if ( ChemicalClass = 'organochlorine pesticides' )      then Variable = lowcase(cat('POP',strip(Variable),'AMT'));
    else if ( ChemicalClass = 'metals' )                         then Variable = lowcase(cat('MET',strip(Variable),'AMT'));
    else if ( ChemicalClass = 'creatinine' )                     then Variable = lowcase(cat(strip(Variable),'AMOUNT'));
    else if ( ChemicalClass = 'phytoestrogens' )                 then Variable = upcase(cat(strip(Variable),'AMOUNT'));
    else                                                              Variable = upcase(cat(strip(Variable),'AMT'));
run;

%let chemLIST = pcb028amt pcb044amt pcb049amt pcb052amt pcb066amt pcb074amt
                pcb087amt pcb099amt pcb101amt pcb105amt pcb110amt pcb114amt
                pcb118amt pcb128amt pcb138amt pcb146amt pcb149amt pcb151amt
                pcb153amt pcb156amt pcb157amt pcb167amt pcb170amt pcb172amt
                pcb177amt pcb178amt pcb180amt pcb183amt pcb187amt pcb189amt
                pcb194amt pcb195amt pcb196amt pcb201amt pcb206amt pcb209amt
                pfcepahamt pfcmpahamt pfcpfdeamt pfcpfnaamt pfcpfsaamt pfcpfosamt pfcpfoaamt
                pophcbamt popmiramt popbhcamt popghcamt popodtamt popoxyamt poppdeamt poppdtamt poptnaamt
                popbb1amt
                pbdebr1amt pbdebr2amt pbdebr3amt pbdebr4amt pbdebr5amt pbdebr6amt pbdebr7amt pbdebr8amt pbdebr9amt pbdebr66amt
                cotamt
                cholamt fcholamt phosamt trigamt CREAMOUNT
                metbcdamt metbpbamt metthgamt;

***************************************;
*** FEMALES.
***************************************;

*** Load female chemicals, convert SPID to text, compute lipids.;
data femchems;
    length spidChar $ 15.;
    set pops.LabData_Female_Baseline(keep=spid &chemLIST);

    *** Convert SPID to text.;
    spidChar = put(spid,BEST12.-L); * Do not need the STRIP function with the -L alignment specification!;

    * Phillips formula;
    Lipids_f = 1.677*(cholamt - fcholamt) + fcholamt + phosamt + trigamt; * Phillips formula;
    label Lipids_f = "Lipids (mg/dl, Females, computed using Phillips formula, Arch Environ Contam Toxicol. 1989 Jul-Aug. 18(4):495-500)";
    drop spid;
run;
data femchems;
    set femchems;
    rename spidChar = spid;
run;

*** Apply labels.;
%ApplyLabels(inputData=femchems,labelData=DAD_labels,maleFemale=Females);

*** Rename chemical variables before MERGE to avoid name collision.;
%RenameChemicalVariables(inputData=femchems,MF=f);

*** Drop chemicals that were not requested.;
data femchems;
    set femchems(drop=pfcepahamt_f pfcmpahamt_f pfcpfdeamt_f pfcpfnaamt_f pfcpfsaamt_f pfcpfosamt_f pfcpfoaamt_f
                      pophcbamt_f popmiramt_f popbhcamt_f popghcamt_f popodtamt_f popoxyamt_f poppdeamt_f poppdtamt_f poptnaamt_f
                      pbdebr1amt_f pbdebr2amt_f pbdebr3amt_f pbdebr4amt_f pbdebr5amt_f pbdebr6amt_f pbdebr7amt_f pbdebr8amt_f pbdebr9amt_f pbdebr66amt_f
                      cotamt_f CREAMOUNT_f
                      metbcdamt_f metbpbamt_f metthgamt_f);
run;

*** Merge into analytic data set.;
%MergeIntoAnalyticDataThenDelete(inputData=femchems);

*** Delete temporary data set(s).;
proc datasets nolist;
    delete DAD_labels;
run;
quit;

******************************************************************************;
******************************************************************************;
*** Load the linking information to de-identify the data.
*** Then de-identify the three output data sets.
******************************************************************************;
******************************************************************************;

*** SAS Data Set link_dat
*** Number of observations            = 258
*** Number of unique occurences of ID = 258
*** Maximum number of repeats of ID   = 1;
data link_dat;
    set linklib.&LINK_FILE(drop=spidMale);
    rename spidFemale = spid;
run;
%CountUniqueVals(inputData=link_dat,vrbl=ID);

%macro DeidentifyData(inputData=);

proc sort data=&inputData; by spid; run;
proc sort data=link_dat;   by spid; run;
data &inputData;
    merge link_dat(in=in1) &inputData(in=in2);
    by spid;
    if ( in1 AND in2 );
    drop spid;
run;

proc sort data=&inputData; by ID; run;

%mend DeidentifyData;

%DeidentifyData(inputData=nonrepeated_dat);
%DeidentifyData(inputData=pjl);
%DeidentifyData(inputData=prf_wide);

******************************************************************************;
******************************************************************************;
*** Save the non-repeated measures data set to disk.
******************************************************************************;
******************************************************************************;

data outlib.nonrepeated_data_&VERSION._&DATESTR;
    set nonrepeated_dat;
run;

******************************************************************************;
******************************************************************************;
*** Save the PJL data set to disk, dropping variables that were not
*** specifically requested.
******************************************************************************;
******************************************************************************;

data pjl;
    set pjl(drop=ATTEMPT ttp status GA_EST preg_date more_than_1_attempt more_than_1_attempt2 PregOutcome);
run;

data outlib.pjl_&VERSION._&DATESTR;
    set pjl;
run;

******************************************************************************;
******************************************************************************;
*** Save the PRF data set to disk.
******************************************************************************;
******************************************************************************;

data outlib.prf_&VERSION._&DATESTR;
    set prf_wide;
run;

******************************************************************************;
******************************************************************************;
*** Make a code book for each of the three output data sets, save them to disk.
*** Adapting code from the SAS program
*** Make Analytic Data Set for Paulines Air Pollution Study - v3.012315.sas
******************************************************************************;
******************************************************************************;

%macro MakeCodeBook(inputData=,outFileNameRoot=);

ods select none;
proc contents data=&inputData varnum;
    ods output Position = codebook;
run;
ods select all;

*** Clean up codebook.;
data codebook;
    set codebook(keep=Variable Label);
    rename Label = Description;
run;

*** Save codebook to CSV file.;
proc export data=codebook replace
    outfile="&MAIN_FOLDER/&OUTPUT_FOLDER/Codebook - &outFileNameRoot - &VERSION..&DATESTR..csv"
    dbms=csv;
run;

%mend MakeCodeBook;

%MakeCodeBook(inputData=nonrepeated_dat,outFileNameRoot=Non-Repeated Measures Data);
%MakeCodeBook(inputData=pjl,            outFileNameRoot=Pregnancy Journal PJL);
%MakeCodeBook(inputData=prf_wide,       outFileNameRoot=History of Previous Pregnancies PRF);
