******************************************************************************;
******************************************************************************;
*** SAS script to plot splines for the Iodine study.
***
*** Version 2: Run the spline macro on NON-log-transformed iodine.
*** This may make more sense, since the spline is intended to model nonlinearities
*** so the log transformation MIGHT be redundant.
***
*** Version 1: Since this is NON-imputed NON-joint data (for the time being),
*** this is heavily based on the SAS program
*** Plot Splines Using Frank Harrel Macros - v21.020614.sas
*** rather than on some later version.
******************************************************************************;
******************************************************************************;

%let VERSION       = v2;
%let DATESTR       = 041714;
%let OUTPUT_FOLDER = Output-04-17-15;
%let IODINE_FOLDER = C:/Users/maisogjm/Documents/LIFE/Iodine;
%let IODINE_DATA   = iodine_v5_041615;
%let SPLINE_FOLDER = C:/Users/maisogjm/Documents/LIFE/Phalates_BPA_UV_and_Trace_Elements;

libname inlib   "&IODINE_FOLDER";

******************************************************************************;
******************************************************************************;
*** Load utility macros.
******************************************************************************;
******************************************************************************;

%let MACRO_FOLDER     = C:/Users/maisogjm/Documents/GLOTECH/SAS Utility Macros;
filename macdef "&MACRO_FOLDER/Utility Macros - v47.011515.sas";
%include macdef;

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
    value $ AGECATFMT
        '1' = '<=29'
        '2' = '30-34'
        '3' = '>=35';
    value $ BMIFMT
        '1' = 'Under/healthy <= 24.9'
        '2' = 'Overweight 25.0 – 29.9'
        '3' = 'Obese >= 30';
    value RACEFMT
        1 ='1-Non-Hispanic White'
        2 ='2-Non-Hispanic Black'
        3 ='3-Hispanic'
        4 ='4-Other';
    value $ EDUFMT
        '1' ='1-Less than high school graduate'
        '2' ='2-High school graduate/GED'
        '3' ='3-Some college or technical school'
        '4' ='4-College graduate or higher';
    value EDU2FMT
        1 ='1- High school or below'
        2 ='2-Some college or above';
    value INCOFMT
        1 ='1- < 50K'
        2 ='2- 50K - 99999'
        3 ='3- 100K and above';
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
    value GRAVIDITYF
        0 = 'Nulligravid'
        1 = '1'
        2 = '2+';
    value PARITYF
        0 = 'Nulliparous'
        1 = '1'
        2 = '2+';
    value $ INFERTILEFMT
        '0' = '0-No'
        '1' = '1-Yes'
        '2' = '2-Withdrew from study, lost to follow-up (censored)';
    value COLLECTNUMBINFMT
        1 = 'Collection #1 - Baseline urine specimen'
        2 = 'All other collection numbers';
    value COLLECTNUMFMT
        1 = 'Collection #1 - Baseline urine specimen'
        2 = 'Collection #2 - 2nd visit- not pregnant'
        3 = 'Collection #3 - 2nd visit- pregnant, 6 month visit- not pregnant, OR Prior to 6 month visit-pregnant'
        4 = 'Collection #4 - Post 6 month visit- pregnant'
        5 = 'Collection #5 - 6 month visit not pregnant again (post pregnancy loss #1)'
        6 = 'Collection #6 - 2nd pregnancy';
    value $ CONDPARFMT
        '0' = '0 - Gravidity = 0, Parity = 0'
        '1' = '1 - Gravidity > 0, Parity = 0'
        '2' = '2 - Gravidity > 0, Parity > 0';
    value $ PREGCATFMT
        '0' = '0-Became Pregnant'
        '1' = '1-Did Not Become Pregnant'
        '2' = '2-Withdrew from study, lost to follow-up (censored)';
    value IODINEBINFMT
        0 = '0 - Less than 100 ng/mL'
        1 = '1 - 100 ng/mL or greater';
    value IODINECATFMT
        0 = '0 - Severe Deficiency (Iodine < 20 ng/mL)'
        1 = '1 - Moderate Deficiency (20 ng/mL <= Iodine < 50 ng/mL)'
        2 = '2 - Mild Deficiency (50 ng/mL <= Iodine < 100 ng/mL)'
        3 = '3 - Sufficient (Iodine >= 100 ng/mL)';
run;

******************************************************************************;
******************************************************************************;
*** Load data.
******************************************************************************;
******************************************************************************;

*** SAS Data Set iodine_dat
*** Number of observations              = 501
*** Number of unique occurences of spid = 501
*** Maximum number of repeats of spid   = 1;
data iodine_dat;
    set inlib.&IODINE_DATA;
run;
%CountUniqueVals(inputData=iodine_dat,vrbl=spid);

******************************************************************************;
******************************************************************************;
*** Source the Vanderbilt macro definitions.
******************************************************************************;
******************************************************************************;

filename harrel "&SPLINE_FOLDER/Spline Macro Definitions by Frank Harrel - v15.020514.sas";
%include harrel;

******************************************************************************;
******************************************************************************;
*** Run Vanderbilt spline macro.
***
*** Version 2: Run the spline macro on NON-log-transformed iodine.
*** This may make more sense, since the spline is intended to model nonlinearities
*** so the log transformation MIGHT be redundant.
******************************************************************************;
******************************************************************************;

title "Iodine (NON-log-transformed) : Unadjusted: Non-Imputed Data";
%let outcsv = &IODINE_FOLDER/&OUTPUT_FOLDER/Iodine - Harrel Spline - Unadjusted - &VERSION..&DATESTR..csv;
%psplinet(X=iodine,Y=nttp,adj=,MODEL=COX,EVENT=status1,data=iodine_dat,outcsv=&outcsv,TIESDISCRETE=YES);
