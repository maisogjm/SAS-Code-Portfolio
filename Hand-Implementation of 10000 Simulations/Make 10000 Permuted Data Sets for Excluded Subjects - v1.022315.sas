******************************************************************************;
******************************************************************************;
*** SAS program to created 10000 permuted data sets for the subjects who
*** up to now have not been included in the intercourse pattern models.
*** Also impute any missing covariates as necessary, so that all 83 will be
*** included in the modeling.
*** The resulting data set has 23,480,000 observations. Therefore, it will
*** not be stored on the local C drive, but rather on the N drive.
***
*** Version 1: Very loosely adapting code from the SAS program
*** Identify the 83 Subjects Who Up To Now Have Not Been Included in Modeling - v1.022015.sas
******************************************************************************;
******************************************************************************;

%let VERSION         = v1;
%let DATESTR         = 022315;
%let OUTPUT_FOLDER   = N:/DIPHRData/LIFE/Fertile Window and Pattern of Intercourse/Data/Intercourse Pattern Study For Enrique;
%let DAY_LEVEL_DAT   = intrcrs_pattrn_day_lvl_v4_022015; * Fixed SPID 3155251.;
%let CYCLE_LEVEL_DAT = intrcrs_pattrn_cyc_lvl_v6_022015;
%let UPDATED_SAF     = saf_cutoffnofilter_v24_110314; * Most current version;
%let UPDATED_DATES   = dates_attempts123_v16_110414;  * FIRST-LAST-DATES-123 data;
%let MACRO_FOLDER    = C:/Users/maisogjm/Documents/GLOTECH/SAS Utility Macros;
%let PATTERN_FOLDER  = C:/Documents and Settings/maisogjm/My Documents/LIFE/Data Quality/Time To Loss/Intercourse Pattern Study For Enrique;
%let LOSS_FOLDER     = C:/Users/maisogjm/Documents/LIFE/Pregnancy Loss;
%let TTL_FOLDER      = C:/Documents and Settings/maisogjm/My Documents/LIFE/Data Quality/Time To Loss;
%let NUMMTHS_FOLDER  = Output-04-17-14;
%let NUMMTHS_FILE    = nummths123_N501_dat_v2_041714; *Using only NUMMTHS for ATTEMPT 1.;

*** Parameters for permutation tests.;
%let NUMPERMUTATIONS = 10000;
%let RANDOMSEED1     = 37849626;
%let RANDOMSEED2     = 20447219;

libname phreg   "C:/Documents and Settings/maisogjm/My Documents/LIFE/PHREG";
libname ttllib  "&TTL_FOLDER";
libname inlib   "&PATTERN_FOLDER";
libname outlib  "&OUTPUT_FOLDER";
libname nummths "&LOSS_FOLDER/&NUMMTHS_FOLDER";

******************************************************************************;
******************************************************************************;
*** Load utility macros.
******************************************************************************;
******************************************************************************;

%let MACRO_FOLDER = C:/Users/maisogjm/Documents/GLOTECH/SAS Utility Macros;
filename macdef "&MACRO_FOLDER/Utility Macros - v47.011515.sas";
%include macdef;

******************************************************************************;
******************************************************************************;
*** Load day-level data WITHOUT constraining  the data to the [-9,+2] window.
*** We will use this data to make a list of the 501 SPIDs, as well as obtain
*** covariates for the adjusted models.
******************************************************************************;
******************************************************************************;

proc format;
    value $ MENSRGFMT
        "1" = "1 - Regular"
        "2" = "2 - NotRegular"
        "3" = "3 - ItVaries";
    value $ NOYES
        "0" = "0 - No"
        "1" = "1 - Yes";
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
    value $ EDU_FMT
        '1' ='1-Less than high school graduate'
        '2' ='2-High school graduate/GED'
        '3' ='3-Some college or technical school'
        '4' ='4-College graduate or higher';
    value AGECATFMT
        1 = '<=29'
        2 = '30-34'
        3 = '35-39'
        4 = '>=40';
    value $ BMIFMT
        '1' = 'Under/healthy <= 24.9'
        '2' = 'Overweight 25.0 – 29.9'
        '3' = 'Obese >= 30';
    value RACEFMT
        1 ='1-Non-Hispanic White'
        2 ='2-Non-Hispanic Black'
        3 ='3-Hispanic'
        4 ='4-Other';
    value EDU2FMT
        1 ='1- High school or below'
        2 ='2-Some college or above'
        3 ='3-Some college or above';
    value INCOFMT
        1 ='1- < 50K'
        2 ='2- 50K - 99999'
        3 ='3- 100K and above';
    value CONDPARFMT
        0 = '0 - Gravidity = 0, Parity = 0'
        1 = '1 - Gravidity > 0, Parity = 0'
        2 = '2 - Gravidity > 0, Parity > 0';
    value NOYESNUMFMT
        0 = '0-No'
        1 = '1-Yes';
    value $ NUMACTSINTERCOURSEF
        '0' = '0-# Acts of Intercourse = 0'
        '1' = '1-# Acts of Intercourse = 1'
        '2' = '2-# Acts of Intercourse = 2-4'
        '3' = '3-# Acts of Intercourse > 4 ';
run;

*** SAS Data Set fertwin_daylevel
*** Number of observations              = 126057
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 606;
data fertwin_daylevel;
    set inlib.&DAY_LEVEL_DAT(keep=spid TTP1 status1 EducationCat_m bmiCat_f bmiCat_m Age_f Age_m);
run;
%CountUniqueVals(inputData=fertwin_daylevel,vrbl=spid);

*** Make uniquified list of the N=501 SPIDs.;
proc sort data=fertwin_daylevel(keep=spid) out=N501_LIST NODUPKEY; by spid; run;

*** Uniquify the data set to obtain non-repeated measures data set.
*** SAS Data Set NonrepeatedMeasures
*** Number of observations              = 501
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 1;
proc sort data=fertwin_daylevel out=NonrepeatedMeasures NODUPKEY; by spid; run;
%CountUniqueVals(inputData=NonrepeatedMeasures,vrbl=spid);

/*
*** Check missingness in categorical variables. They will need to be imputed
*** (Simply using the most common value. See the SAS program
*** Impute Trace Elements-Metals, Male-Female Income and Race - v2.080613.sas);
proc freq data=NonrepeatedMeasures;
    tables status1 EducationCat_m bmiCat_f bmiCat_m;
run;
*** There is a little missingness in the variables EducationCat_m (5),
*** bmiCat_f (5), and  bmiCat_m (16).;

*** Check missingness in Age_f and Age_m.;
proc means data=NonrepeatedMeasures N NMISS;
    var Age_f Age_m;
run;
*** There is no missingness.;
*/

*** Delete temporary data set(s).;
proc datasets nolist;
    delete fertwin_daylevel;
run;
quit;

******************************************************************************;
******************************************************************************;
*** Add ZEROCYC variable to the NONREPEATEDMEASURES data set.
******************************************************************************;
******************************************************************************;

*** Adapting code from the SAS program
*** Make Cycle-Level Analytic Data Set for Intercourse Pattern Study - v6.022015.sas;
*** Load SAF data.
*** SAS Data Set saf
*** Number of observations              = 155103
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 864;
data saf;
    set phreg.&UPDATED_SAF(keep=spid date method5 event Decision PEAK_KL123);
run;
%CountUniqueVals(inputData=saf,vrbl=spid);

*** Load start and end dates of Attempts 1, 2, and 3.
*** SAS Data Set first_last_dates_Attempts123
*** Number of observations              = 501
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 1;    
data first_last_dates_Attempts123;
    set ttllib.&UPDATED_DATES;
run;
%CountUniqueVals(inputData=first_last_dates_Attempts123,vrbl=spid);

*** Merge.
*** Keep only observations in Attempt #1.
*** SAS Data Set saf
*** Number of observations              = 155103
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 864;
proc sort data=saf;                          by spid date; run;
proc sort data=first_last_dates_Attempts123; by spid;      run;
data saf;
    merge saf first_last_dates_Attempts123;
    by spid;
run;
%CountUniqueVals(inputData=saf,vrbl=spid);

*** Assign observations to each of the three Attempts.
*** Define the pregnancy Attempt variable.
*** SAS Data Set saf
*** Number of observations              = 155103
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 864;
data saf;
   retain spid Attempt date event Decision firstDate1-firstDate3 lastDate1-lastDate3;
   set saf;
   if      ( ( firstDate1 ^= . ) AND ( lastDate1 ^= . ) AND ( firstDate1 <= date <= lastDate1 ) ) then Attempt = 1;
   else if ( ( firstDate2 ^= . ) AND ( lastDate2 ^= . ) AND ( firstDate2 <= date <= lastDate2 ) ) then Attempt = 2;
   else if ( ( firstDate3 ^= . ) AND ( lastDate3 ^= . ) AND ( firstDate3 <= date <= lastDate3 ) ) then Attempt = 3;
   drop firstDate1-firstDate3 lastDate1-lastDate3;
run;
%CountUniqueVals(inputData=saf,vrbl=spid);

*** Keep only observations in Attempt #1.
*** SAS Data Set saf
*** Number of observations              = 137929
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 823;
data saf;
    set saf;
    if ( Attempt = 1 );
run;
%CountUniqueVals(inputData=saf,vrbl=spid);

*** Reduce to unique cycles within Attempt.;
proc sort data=saf(keep=spid method5 Attempt) out=uniqueCycles NODUPKEY; by spid Attempt method5; run;

*** Remove observations where METHOD5 is missing.;
data uniqueCycles;
    set uniqueCycles;
    if ( method5 = . ) then delete;
run;

*** Here, compute the ZEROCYC variable for Attempt #1.
*** SAS Data Set zerocyc_dat
*** Number of observations              = 501
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 1;
data zerocyc_dat;
    retain spid Attempt zerocyc;
    set uniqueCycles;
    by spid Attempt;

    *** Initialize ZEROCYC to 0.;
    if ( first.Attempt ) then do;
        zerocyc = 0;
    end;

    *** If we find a zero cycle, set ZEROCYC to 1.;
    if ( method5 = 0 ) then zerocyc = 1;

    *** If this is the last observation within an Attempt, output;
    if ( last.Attempt ) then output;

    keep spid Attempt zerocyc;
run;
%CountUniqueVals(inputData=zerocyc_dat,vrbl=spid);

*** Merge.
*** SAS Data Set NonrepeatedMeasures
*** Number of observations              = 501
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 1;
proc sort data=NonrepeatedMeasures; by spid; run;
proc sort data=zerocyc_dat;         by spid; run;
data NonrepeatedMeasures;
    merge NonrepeatedMeasures zerocyc_dat;
    by spid;
run;
%CountUniqueVals(inputData=NonrepeatedMeasures,vrbl=spid);

*** Delete temporary data set(s).;
proc datasets nolist;
    delete saf first_last_dates_Attempts123 uniqueCycles zerocyc_dat;
run;
quit;

******************************************************************************;
******************************************************************************;
*** Add NUMMTHS and NTTP to the NONREPEATEDMEASURES data set.
*** Adapting code from the SAS program
*** Make Cycle-Level Analytic Data Set for Intercourse Pattern Study - v6.022015.sas
*** where it was in turn adapted from the SAS program
*** Make Analytic Data Set For Kate - Dissertation - v10.110514.sas
******************************************************************************;
******************************************************************************;

*** SAS Data Set nummths_wide
*** Number of observations              = 501
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 1;
data nummths_wide;
    set nummths.&NUMMTHS_FILE(keep=spid nummths1);
    rename nummths1 = nummths;
run;
%CountUniqueVals(inputData=nummths_wide,vrbl=spid);

*** Merge.
*** SAS Data Set NonrepeatedMeasures
*** Number of observations              = 501
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 1;
proc sort data=NonrepeatedMeasures; by spid; run;
proc sort data=nummths_wide;        by spid; run;
data NonrepeatedMeasures;
    merge NonrepeatedMeasures nummths_wide;
    by spid;
    if zerocyc = 1 then nttp = ttp1 + nummths + 1;
    if zerocyc = 0 then nttp = ttp1 + nummths;
    label nttp = "Time to pregnancy (WITH Left Truncation, PROSPECTIVELY reported pregnancies only)";
    label zerocyc = "Subject has a zero cycle in this Pregnancy Attempt?";
    format zerocyc NOYESNUMFMT.;
run;
%CountUniqueVals(inputData=NonrepeatedMeasures,vrbl=spid);

/*
*** Check missingness in nttp and nummths.;
proc means data=NonrepeatedMeasures N NMISS;
    var nttp nummths;
run;
*** There is no missingness.;
*/

*** Delete temporary data set(s).;
proc datasets nolist;
    delete nummths_wide;
run;
quit;

******************************************************************************;
******************************************************************************;
*** Impute missing values in categorical variables with the most frequent
*** value. Adapting the SAS macro IMPUTECOVARIATES from the SAS program
*** Impute Trace Elements-Metals, Male-Female Income and Race - v2.080613.sas.
******************************************************************************;
******************************************************************************;

%let covarLIST = EducationCat_m bmiCat_f bmiCat_m;

*** Find frequencies of each covariate.;
ods select none;
proc freq data=NonrepeatedMeasures;
    tables &covarLIST;
    ods output OneWayFreqs = OneWayFreqs;
run;
ods select all;

*** Impute covariates with most frequent values.;
%macro ImputeCovariates();

*** Loop over covariates.;
%let i = 1;
%let covar = %scan(&covarLIST,&i);
%do %until(NOT %length(&covar));

    *** Filter the ONEWAYFREQS data to retain only output
    *** pertaining to the current covariate.;
    data OneWayFreqs_subset;
        set OneWayFreqs;
        if ( index(Table,"&covar") > 0 );
        keep Table &covar Frequency;
    run;

    *** Find the most frequent level.;
    data most_freq_level;
        retain maxN mostFreqLevel;
        set OneWayFreqs_subset end=lastobs;
        length mostFreqLevel $ 16.;
        if ( _N_ = 1 ) then do;
            maxN = -Inf;
            mostFreqLevel = " ";
        end;

        *** Update most frequent level;
        if ( Frequency > maxN ) then do;
            maxN          = Frequency;
            mostFreqLevel = &covar;
        end;
    
        *** If we reach the end of the data set, output the line.;
        if ( lastobs ) then output;
        keep maxN mostFreqLevel;
    run;

    *** Go back to the complete data, fill in the missing values
    *** with the most frequent value.;
    data NonrepeatedMeasures;
        set NonrepeatedMeasures;
        if ( _N_ = 1 ) then set most_freq_level;
        if ( &covar = " " ) then &covar = mostFreqLevel;
        drop maxN mostFreqLevel;
    run;

    *** Delete temporary data sets.;
    proc datasets nolist;
        delete OneWayFreqs_subset most_freq_level;
    run;
    quit;

    *** Get the next covariate.;
    %let i = %eval( &i + 1 );
    %let covar = %scan(&covarLIST,&i);
%end;

%mend ImputeCovariates;

%ImputeCovariates();

*** Check that there is no longer any missingness.;
/*
proc freq data=NonrepeatedMeasures;
    tables &covarLIST;
run;
*/

*** Delete temporary data set(s).;
proc datasets nolist;
    delete OneWayFreqs;
run;
quit;

******************************************************************************;
******************************************************************************;
*** Load the cycle-level data. Previous versions had only N=418 subjects, but
*** with the latest update of the SAF data we were able to recover one subject.
******************************************************************************;
******************************************************************************;

*** SAS Data Set cycle_level_dat
*** Number of observations              = 2240
*** Number of unique occurences of spid = 419
*** Maximum number of repeats of spid   = 16;
data cycle_level_dat;
    set inlib.&CYCLE_LEVEL_DAT(keep=spid method5 numActsIntercourse twoDayIntercoursePattern threeDayIntercoursePattern);
run;
%CountUniqueVals(inputData=cycle_level_dat,vrbl=spid);

*** Make uniquified list of the N=419 SPIDs.;
proc sort data=cycle_level_dat(keep=spid) out=N419_LIST NODUPKEY; by spid; run;

*** Make a list of the N=501-419=82 excluded subjects.;
data N82_LIST;
    merge N501_LIST N419_LIST(in=in2);
    by spid;
    if ( NOT in2 );
run;

*** Delete temporary data set(s).;
proc datasets nolist;
    delete N501_LIST N419_LIST;
run;
quit;

******************************************************************************;
******************************************************************************;
*** In the cycle-level data, categorize NUMACTSINTERCOURSE in exactly the
*** same way that is done when doing the modeling. See SAS program
*** Run Unadjusted and Adjusted Models by Number of Acts of Intercourse - v5.112614.sas
*** lines 199-201.
******************************************************************************;
******************************************************************************;

*** SAS Data Set cycle_level_dat
*** Number of observations              = 2240
*** Number of unique occurences of spid = 419
*** Maximum number of repeats of spid   = 16;
data cycle_level_dat;
    set cycle_level_dat;

    *** Set values.;
    if      (      round(numActsIntercourse,1) = 0 )        then NumIntercourseCat = '0';
    else if (      round(numActsIntercourse,1) = 1 )        then NumIntercourseCat = '1';
    else if ( 2 <= round(numActsIntercourse,1) <= 4 )       then NumIntercourseCat = '2';
    else if (      round(numActsIntercourse,1) > 4 )        then NumIntercourseCat = '3';
    format NumIntercourseCat $NUMACTSINTERCOURSEF.;
    label NumIntercourseCat = "Number of Acts of Intercourse over the [-9,+2] window (categorized)";
run;
%CountUniqueVals(inputData=cycle_level_dat,vrbl=spid);

/*
proc freq data=cycle_level_dat;
    tables NumIntercourseCat;
run;
*/

******************************************************************************;
******************************************************************************;
*** We currently have three categorizations for intercourse patterns: 
***     a. Intercourse Pattern on Fertile Days -1 and 0
***     b. Intercourse Pattern on Fertile Days -2, -1, and 0
***     c. Number of Acts of Intercourse
*** Find the frequencies of the levels within each of these three categorizations.
*** Do this across cycles (for imputation of Cycle 0), as well as by Cycle
*** (for imputation of all other Cycles).
******************************************************************************;
******************************************************************************;

*** Frequencies across cycles (for imputation of Cycle 0).;
ods select none;
proc freq data=cycle_level_dat;
    tables NumIntercourseCat twoDayIntercoursePattern threeDayIntercoursePattern;
    ods output OneWayFreqs = FreqsAcrossCycles_tall;
run;
ods select all;

*** Frequencies by Cycle (for imputation of all other Cycles).
*** Note that Cycle 0 does seem to have SOME data, but we will not be using it.;
proc sort data=cycle_level_dat; by method5 spid; run;
ods select none;
proc freq data=cycle_level_dat;
    tables NumIntercourseCat twoDayIntercoursePattern threeDayIntercoursePattern;
    by method5;
    ods output OneWayFreqs = FreqsByCycle_tall;
run;
ods select all;

*** Convert to wide -- frequencies across cycles (for imputation of Cycle 0).;
data FreqsAcrossCycles_wide;
    retain IP00_PCT IP01_PCT IP10_PCT IP11_PCT
           IP000_PCT IP001_PCT IP010_PCT IP011_PCT IP100_PCT IP101_PCT IP110_PCT IP111_PCT
           NumIntercourse_EQ_0_PCT NumIntercourse_EQ_1_PCT NumIntercourse_GE2_LE4_PCT NumIntercourse_GT_4_PCT;
    set FreqsAcrossCycles_tall end=lastobs;

    *** Intercourse Pattern on Fertile Days -1 and 0.;
    if ( F_twoDayIntercoursePattern = "00" ) then IP00_PCT = CumPercent;
    if ( F_twoDayIntercoursePattern = "01" ) then IP01_PCT = CumPercent;
    if ( F_twoDayIntercoursePattern = "10" ) then IP10_PCT = CumPercent;
    if ( F_twoDayIntercoursePattern = "11" ) then IP11_PCT = CumPercent;

    *** Intercourse Pattern on Fertile Days -2, -1, and 0.;
    if ( F_threeDayIntercoursePattern = "000" ) then IP000_PCT = CumPercent;
    if ( F_threeDayIntercoursePattern = "001" ) then IP001_PCT = CumPercent;
    if ( F_threeDayIntercoursePattern = "010" ) then IP010_PCT = CumPercent;
    if ( F_threeDayIntercoursePattern = "011" ) then IP011_PCT = CumPercent;
    if ( F_threeDayIntercoursePattern = "100" ) then IP100_PCT = CumPercent;
    if ( F_threeDayIntercoursePattern = "101" ) then IP101_PCT = CumPercent;
    if ( F_threeDayIntercoursePattern = "110" ) then IP110_PCT = CumPercent;
    if ( F_threeDayIntercoursePattern = "111" ) then IP111_PCT = CumPercent;

    *** Number of Acts of Intercourse.;
    if ( F_NumIntercourseCat = "0-# Acts of Intercourse = 0" )   then NumIntercourse_EQ_0_PCT    = CumPercent;
    if ( F_NumIntercourseCat = "1-# Acts of Intercourse = 1" )   then NumIntercourse_EQ_1_PCT    = CumPercent;
    if ( F_NumIntercourseCat = "2-# Acts of Intercourse = 2-4" ) then NumIntercourse_GE2_LE4_PCT = CumPercent;
    if ( F_NumIntercourseCat = "3-# Acts of Intercourse > 4" )   then NumIntercourse_GT_4_PCT    = CumPercent;

    *** Output;
    if ( lastobs ) then output;

    keep IP00_PCT IP01_PCT IP10_PCT IP11_PCT
         IP000_PCT IP001_PCT IP010_PCT IP011_PCT IP100_PCT IP101_PCT IP110_PCT IP111_PCT
         NumIntercourse_EQ_0_PCT NumIntercourse_EQ_1_PCT NumIntercourse_GE2_LE4_PCT NumIntercourse_GT_4_PCT;
run;

*** Convert to wide -- frequencies by Cycle (for imputation of all other Cycles).
*** Note that Cycle 0 does seem to have SOME data, but we will not be using it.;
%macro ListPctVariables(varLIST=);

%do j = 0 %to 15;
    %let i = 1;
    %let vrbl = %scan(&varLIST,&i);
    %do %until( NOT %length(&vrbl) );
        &vrbl._&j._PCT
        %let i = %eval( &i + 1 );
        %let vrbl = %scan(&varLIST,&i);
    %end;
%end;

%mend ListPctVariables;

data FreqsByCycle_wide;
    retain %ListPctVariables(varLIST=IP00 IP01 IP10 IP11)
           %ListPctVariables(varLIST=IP000 IP001 IP010 IP011 IP100 IP101 IP110 IP111)
           %ListPctVariables(varLIST=NumIntercourse_EQ_0 NumIntercourse_EQ_1 NumIntercourse_GE2_LE4 NumIntercourse_GT_4);
    array TwoDayPattern[*]   %ListPctVariables(varLIST=IP00 IP01 IP10 IP11);
    array ThreeDayPattern[*] %ListPctVariables(varLIST=IP000 IP001 IP010 IP011 IP100 IP101 IP110 IP111);
    array NumIntercourse[*]  %ListPctVariables(varLIST=NumIntercourse_EQ_0 NumIntercourse_EQ_1 NumIntercourse_GE2_LE4 NumIntercourse_GT_4);
    set FreqsByCycle_tall end=lastobs;

    *** Intercourse Pattern on Fertile Days -1 and 0.;
    if ( F_twoDayIntercoursePattern = "00" ) then TwoDayPattern[4*method5+1] = CumPercent;
    if ( F_twoDayIntercoursePattern = "01" ) then TwoDayPattern[4*method5+2] = CumPercent;
    if ( F_twoDayIntercoursePattern = "10" ) then TwoDayPattern[4*method5+3] = CumPercent;
    if ( F_twoDayIntercoursePattern = "11" ) then TwoDayPattern[4*method5+4] = CumPercent;

    *** Intercourse Pattern on Fertile Days -2, -1, and 0.;
    if ( F_threeDayIntercoursePattern = "000" ) then ThreeDayPattern[8*method5+1] = CumPercent;
    if ( F_threeDayIntercoursePattern = "001" ) then ThreeDayPattern[8*method5+2] = CumPercent;
    if ( F_threeDayIntercoursePattern = "010" ) then ThreeDayPattern[8*method5+3] = CumPercent;
    if ( F_threeDayIntercoursePattern = "011" ) then ThreeDayPattern[8*method5+4] = CumPercent;
    if ( F_threeDayIntercoursePattern = "100" ) then ThreeDayPattern[8*method5+5] = CumPercent;
    if ( F_threeDayIntercoursePattern = "101" ) then ThreeDayPattern[8*method5+6] = CumPercent;
    if ( F_threeDayIntercoursePattern = "110" ) then ThreeDayPattern[8*method5+7] = CumPercent;
    if ( F_threeDayIntercoursePattern = "111" ) then ThreeDayPattern[8*method5+8] = CumPercent;

    *** Number of Acts of Intercourse.;
    if ( F_NumIntercourseCat = "0-# Acts of Intercourse = 0" )   then NumIntercourse[4*method5+1] = CumPercent;
    if ( F_NumIntercourseCat = "1-# Acts of Intercourse = 1" )   then NumIntercourse[4*method5+2] = CumPercent;
    if ( F_NumIntercourseCat = "2-# Acts of Intercourse = 2-4" ) then NumIntercourse[4*method5+3] = CumPercent;
    if ( F_NumIntercourseCat = "3-# Acts of Intercourse > 4" )   then NumIntercourse[4*method5+4] = CumPercent;

    *** Output;
    if ( lastobs ) then output;

    keep %ListPctVariables(varLIST=NumIntercourse_EQ_0 NumIntercourse_EQ_1 NumIntercourse_GE2_LE4 NumIntercourse_GT_4)
         %ListPctVariables(varLIST=IP00 IP01 IP10 IP11)
         %ListPctVariables(varLIST=IP000 IP001 IP010 IP011 IP100 IP101 IP110 IP111);
run;

*** Delete temporary data set(s).;
proc datasets nolist;
    delete FreqsAcrossCycles_tall FreqsByCycle_tall;
run;
quit;

******************************************************************************;
******************************************************************************;
*** Extract the 60 subjects who had TTP1 = 0 (whether they got pregnant or not).
*** Then create 10000 permutations of intercourse patterns for these subjects.
******************************************************************************;
******************************************************************************;

*** SAS Data Set N60_LIST
*** Number of observations              = 60
*** Number of unique occurences of spid = 60
*** Maximum number of repeats of spid   = 1;
data N60_LIST;
    set NonrepeatedMeasures(keep=spid TTP1);
    if ( TTP1 = 0 );
    keep spid;
run;
%CountUniqueVals(inputData=N60_LIST,vrbl=spid);

*** SAS Data Set Permutations60_dat
*** Number of observations              = 600000
*** Number of unique occurences of spid = 60
*** Maximum number of repeats of spid   = 10000;
data Permutations60_dat;
    length _PERMUTATION_ 8.;
    call streaminit(&RANDOMSEED1); /* set random number seed */
    set N60_LIST;
	length twoDayIntercoursePattern $2.;
    if ( _N_ = 1 ) then set FreqsAcrossCycles_wide;
    method5 = 0;

    do _PERMUTATION_ = 1 to &NUMPERMUTATIONS;
        *** Intercourse Pattern on Fertile Days -2, -1, and 0.;
        randNum = 100*rand("Uniform");  /* randNum ~ U[0,100] */
        if      ( ( IP000_PCT ^= . ) AND ( randNum < IP000_PCT ) ) then threeDayIntercoursePattern = "000";
        else if ( ( IP001_PCT ^= . ) AND ( randNum < IP001_PCT ) ) then threeDayIntercoursePattern = "001";
        else if ( ( IP010_PCT ^= . ) AND ( randNum < IP010_PCT ) ) then threeDayIntercoursePattern = "010";
        else if ( ( IP011_PCT ^= . ) AND ( randNum < IP011_PCT ) ) then threeDayIntercoursePattern = "011";
        else if ( ( IP100_PCT ^= . ) AND ( randNum < IP100_PCT ) ) then threeDayIntercoursePattern = "100";
        else if ( ( IP101_PCT ^= . ) AND ( randNum < IP101_PCT ) ) then threeDayIntercoursePattern = "101";
        else if ( ( IP110_PCT ^= . ) AND ( randNum < IP110_PCT ) ) then threeDayIntercoursePattern = "110";
        else if ( ( IP111_PCT ^= . ) AND ( randNum < IP111_PCT ) ) then threeDayIntercoursePattern = "111";

        *** Intercourse Pattern on Fertile Days -1 and 0.;
        twoDayIntercoursePattern = substr(threeDayIntercoursePattern,2,2);

        *** Number of Acts of Intercourse.;
        if      ( ( NumIntercourse_EQ_0_PCT    ^= . ) AND ( randNum < NumIntercourse_EQ_0_PCT ) )    then NumIntercourseCat = '0';
        else if ( ( NumIntercourse_EQ_1_PCT    ^= . ) AND ( randNum < NumIntercourse_EQ_1_PCT ) )    then NumIntercourseCat = '1';
        else if ( ( NumIntercourse_GE2_LE4_PCT ^= . ) AND ( randNum < NumIntercourse_GE2_LE4_PCT ) ) then NumIntercourseCat = '2';
        else if ( ( NumIntercourse_GT_4_PCT    ^= . ) AND ( randNum < NumIntercourse_GT_4_PCT ) )    then NumIntercourseCat = '3';
        format NumIntercourseCat $NUMACTSINTERCOURSEF.;
        label NumIntercourseCat = "Number of Acts of Intercourse over the [-9,+2] window (categorized)";

        *** Set ZEROCYC to 1.;
        zerocyc = 1;

        *** Output line.;
        output;
    end;

    keep _PERMUTATION_ spid method5 twoDayIntercoursePattern threeDayIntercoursePattern NumIntercourseCat;
run;
%CountUniqueVals(inputData=Permutations60_dat,vrbl=spid);

*** Delete temporary data set(s).;
proc datasets nolist;
    delete FreqsAcrossCycles_wide;
run;
quit;

******************************************************************************;
******************************************************************************;
*** Extract the remaining N=82-60=22 subjects who were exluded from the modeling
*** previously.
*** Then create 10000 permutations of intercourse patterns for these subjects.
******************************************************************************;
******************************************************************************;

data N22_LIST;
    merge N82_LIST N60_LIST(in=in2);
    by spid;
    if ( NOT in2 );
run;

*** Find TTP1 for these 22 subjects.;
data TTP1_22_dat;
    merge N22_LIST(in=in1) NonrepeatedMeasures(keep=spid TTP1);
    by spid;
    if ( in1 );
run;

*** Merge ZEROCYC data with the TTP1 data.;
proc sort data=NonrepeatedMeasures; by spid; run;
proc sort data=TTP1_22_dat; by spid; run;
data TTP1_22_dat;
    merge TTP1_22_dat(in=in1) NonrepeatedMeasures(keep=spid zerocyc);
    by spid;
    if ( in1 );
run;

%macro SetupArrays(varLIST=);

%let i = 1;
%let vrbl = %scan(&varLIST,&i);
%do %until ( NOT %length(&vrbl) );
    array &vrbl._PCT[*]
    %do j = 0 %to 15;
        &vrbl._&j._PCT
    %end;
    ;
    %let i = %eval( &i + 1 );
    %let vrbl = %scan(&varLIST,&i);
%end;

%mend;

*** Now create 10000 permutations for these 22 subjects.
*** SAS Data Set Permutations22_dat
*** Number of observations              = 480000
*** Number of unique occurences of spid = 22
*** Maximum number of repeats of spid   = 40000;
data Permutations22_dat;
    length _PERMUTATION_ 8.;
    call streaminit(&RANDOMSEED2); /* set random number seed */
    set TTP1_22_dat;
	length twoDayIntercoursePattern $2.;
    if ( _N_ = 1 ) then set FreqsByCycle_wide;
    %SetupArrays(varLIST=IP000 IP001 IP010 IP011 IP100 IP101 IP110 IP111);
    %SetupArrays(varLIST=NumIntercourse_EQ_0 NumIntercourse_EQ_1 NumIntercourse_GE2_LE4 NumIntercourse_GT_4);

    *** Determine the starting cycle.;
    if ( zerocyc = 1 ) then startCycle = 0;
    else                    startCycle = 1;

    do _PERMUTATION_ = 1 to &NUMPERMUTATIONS;
        do method5 = startCycle to TTP1;

            *** Intercourse Pattern on Fertile Days -2, -1, and 0.;
            randNum = 100*rand("Uniform");  /* randNum ~ U[0,100] */
            if      ( ( IP000_PCT[method5+1] ^= . ) AND ( randNum < IP000_PCT[method5+1] ) ) then threeDayIntercoursePattern = "000";
            else if ( ( IP001_PCT[method5+1] ^= . ) AND ( randNum < IP001_PCT[method5+1] ) ) then threeDayIntercoursePattern = "001";
            else if ( ( IP010_PCT[method5+1] ^= . ) AND ( randNum < IP010_PCT[method5+1] ) ) then threeDayIntercoursePattern = "010";
            else if ( ( IP011_PCT[method5+1] ^= . ) AND ( randNum < IP011_PCT[method5+1] ) ) then threeDayIntercoursePattern = "011";
            else if ( ( IP100_PCT[method5+1] ^= . ) AND ( randNum < IP100_PCT[method5+1] ) ) then threeDayIntercoursePattern = "100";
            else if ( ( IP101_PCT[method5+1] ^= . ) AND ( randNum < IP101_PCT[method5+1] ) ) then threeDayIntercoursePattern = "101";
            else if ( ( IP110_PCT[method5+1] ^= . ) AND ( randNum < IP110_PCT[method5+1] ) ) then threeDayIntercoursePattern = "110";
            else if ( ( IP111_PCT[method5+1] ^= . ) AND ( randNum < IP111_PCT[method5+1] ) ) then threeDayIntercoursePattern = "111";

            *** Intercourse Pattern on Fertile Days -1 and 0.;
            twoDayIntercoursePattern = substr(threeDayIntercoursePattern,2,2);

            *** Number of Acts of Intercourse.;
            if      ( ( NumIntercourse_EQ_0_PCT[method5+1]    ^= . ) AND ( randNum < NumIntercourse_EQ_0_PCT[method5+1] ) )    then NumIntercourseCat = '0';
            else if ( ( NumIntercourse_EQ_1_PCT[method5+1]    ^= . ) AND ( randNum < NumIntercourse_EQ_1_PCT[method5+1] ) )    then NumIntercourseCat = '1';
            else if ( ( NumIntercourse_GE2_LE4_PCT[method5+1] ^= . ) AND ( randNum < NumIntercourse_GE2_LE4_PCT[method5+1] ) ) then NumIntercourseCat = '2';
            else if ( ( NumIntercourse_GT_4_PCT[method5+1]    ^= . ) AND ( randNum < NumIntercourse_GT_4_PCT[method5+1] ) )    then NumIntercourseCat = '3';
            format NumIntercourseCat $NUMACTSINTERCOURSEF.;
            label NumIntercourseCat = "Number of Acts of Intercourse over the [-9,+2] window (categorized)";

            *** Output line.;
            output;
        end;
    end;

    keep _PERMUTATION_ spid method5 twoDayIntercoursePattern threeDayIntercoursePattern NumIntercourseCat;
run;
%CountUniqueVals(inputData=Permutations22_dat,vrbl=spid);

*** Delete temporary data set(s).;
proc datasets nolist;
    delete N82_LIST N60_LIST N22_LIST TTP1_22_dat FreqsByCycle_wide;
run;
quit;

******************************************************************************;
******************************************************************************;
*** Take the N=419 subjects who were not excluded in previous analyses, and
*** replicate their data 10000 times.
******************************************************************************;
******************************************************************************;

*** SAS Data Set Permutations419_dat
*** Number of observations              = 22400000
*** Number of unique occurences of spid = 419
*** Maximum number of repeats of spid   = 160000;
data Permutations419_dat;
    length _PERMUTATION_ 8.;
    set cycle_level_dat;
    do _PERMUTATION_ = 1 to &NUMPERMUTATIONS;
        output;
    end;
run;
proc sort data=Permutations419_dat; by _PERMUTATION_ spid; run;
%CountUniqueVals(inputData=Permutations419_dat,vrbl=spid);

*** Delete temporary data set(s).;
proc datasets nolist;
    delete cycle_level_dat;
run;
quit;

******************************************************************************;
******************************************************************************;
*** Now merge the PERMUTATIONS60_DAT, PERMUTATIONS22_DAT, and
*** PERMUTATIONS419_dat data sets.
*** Then add the non-repeated measures covariates.
******************************************************************************;
******************************************************************************;

*** Merge the PERMUTATIONS60_DAT, PERMUTATIONS22_DAT, and
*** PERMUTATIONS419_dat data sets.
*** SAS Data Set Permutations501_dat
*** Number of observations              = 23480000
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 160000;
proc sort data=Permutations419_dat; by spid method5 _PERMUTATION_; run;
proc sort data=Permutations60_dat;  by spid method5 _PERMUTATION_; run;
proc sort data=Permutations22_dat;  by spid method5 _PERMUTATION_; run;
data Permutations501_dat;
    merge Permutations419_dat Permutations60_dat Permutations22_dat;
    by spid method5 _PERMUTATION_;
run;
%CountUniqueVals(inputData=Permutations501_dat,vrbl=spid);

*** Add the non-repeated measures covariates.
*** SAS Data Set Permutations501_dat
*** Number of observations              = 23480000
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 160000;
proc sort data=Permutations501_dat; by spid _PERMUTATION_; run;
proc sort data=NonrepeatedMeasures; by spid              ; run;
data Permutations501_dat;
    merge Permutations501_dat NonrepeatedMeasures;
    by spid;
run;
%CountUniqueVals(inputData=Permutations501_dat,vrbl=spid);

*** Delete temporary data set(s).;
proc datasets nolist;
    delete Permutations419_dat Permutations60_dat Permutations22_dat NonrepeatedMeasures;
run;
quit;

******************************************************************************;
******************************************************************************;
*** Define AGE_AVG and AGE_DIFF. Then drop AGE_F, AGE_M, TTP1, ATTEMPT, and
*** NUMACTSINTERCOURSE. These variables will not be used in the modeling.
*** And the output file is very large, so it is desirable to minimize its size.
******************************************************************************;
******************************************************************************;

data Permutations501_dat;
    set Permutations501_dat;

    *** Define average age and age difference.;
    Age_AVG  = mean(Age_f,Age_m);
    Age_DIFF = Age_m - Age_f;
    label Age_AVG  = "Average age between male and female"
          AGE_DIFF = "Age difference between male and female";

    drop Age_f Age_m TTP1 Attempt numActsIntercourse;
run;

******************************************************************************;
******************************************************************************;
*** Save to disk.
******************************************************************************;
******************************************************************************;

proc sort data=Permutations501_dat; by _PERMUTATION_ spid method5; run;
data outlib.Permutations_10K_&VERSION._&DATESTR;
    set Permutations501_dat;
run;
