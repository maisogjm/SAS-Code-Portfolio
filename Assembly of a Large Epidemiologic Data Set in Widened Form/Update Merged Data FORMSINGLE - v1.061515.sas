/*--------------------------------------------------------------*/
/*                                                              */
/* Study: NICHD Fetal Growth Study                              */
/*                                                              */
/* This program creates a merged datafile for the NICHD Fetal   */
/* Growth Study that includes all of the forms for the          */
/* SINGLETON pregnancies. Any forms that had "long" data will   */
/* be "widened" for the merge.                                  */
/* Also this code creates derived variables that require        */
/* multiple variables from different forms. This program will   */
/* archive the previous version of the data.                    */
/* This code also creates a code book that includes information */
/* for categorical variables that have been coded using         */
/* formats, namely, the levels within format.                   */
/*                                                              */
/*--------------------------------------------------------------*/

%let WORK_FOLDER = N:/DIPHRData/Fetal Growth/Working Data/Study form data;

LIBNAME ORIGINAL "N:/DIPHRData/Fetal Growth/Data Management/Working Data/Original Study Form";
LIBNAME WORKING  "&WORK_FOLDER";
LIBNAME ARCHIVE  "N:/DIPHRData/Fetal Growth/Data Management/Working Data/Archive Study Form";

******************************************************************************;
******************************************************************************;
*** Set up formats.
******************************************************************************;
******************************************************************************;

%include "N:/DIPHRData/Fetal Growth/Data Management/Working Data/Set Up Formats - v1.061515.sas";

*** Store format information in a temporary SAS data set.;
proc format library=WORK.formats cntlout = fmtdata_codebook;
run;

*** Rename LABEL to FORMATVALUELABEL to avoid name
*** collision when merging with variable tables.;
data fmtdata_codebook;
    set fmtdata_codebook(keep=FMTNAME LABEL);
    rename LABEL = FormatValueLabel;
    label LABEL = "Format Value Label";
run;

******************************************************************************;
******************************************************************************;
*** Load utility macros.
*** Change the macro variable MACRO_FOLDER to point to the folder on your
*** computer where the macro definitions are stored.
******************************************************************************;
******************************************************************************;

%let MACRO_FOLDER = N:/DIPHRData/Fetal Growth/Data Management/Working Data;
filename macdef "&MACRO_FOLDER/Utility Macros.sas";
%include macdef;

******************************************************************************;
******************************************************************************;
*** Set macro variable RUNDATE to a six-digit representation of the
*** date that this code is being run.;
******************************************************************************;
******************************************************************************;

data _NULL_;
    RUNDATE     = today();
    RUNDATEChar = put(RUNDATE,mmddyy6.-L);
    call symput("RUNDATE",RUNDATEChar);
run;
%put RUNDATE = &RUNDATE; * Show RUNDATE in the SAS log.;

******************************************************************************;
******************************************************************************;
/*1. ARCHIVE THE PREVIOUS VERSION OF FORMSINGLE. */
******************************************************************************;
******************************************************************************;

data ARCHIVE.FORMSINGLE_&RUNDATE;
    set WORKING.FORMSINGLE;
run;

******************************************************************************;
******************************************************************************;
/*2. Read in all of the form level data
  3. Widen form level data that is in long format
  Form level data will be sequentially read in, widened if necessary,
  then merged into a growing merged study form data set.
*/
******************************************************************************;
******************************************************************************;

******************************************************************************;
*** Initialize code book for NON-REPEATED MEASURES AND REPEATED MEASURES C-TASC data.
******************************************************************************;

*** Initialize output to include only entries for SUBJECT_ID, VISIT_NBR, and SEQ_NBR.;
ods select none;
proc contents data=ORIGINAL.fm013a varnum;
    ods output Position = codebook;
run;
ods select all;
data codebook;
    retain Member Num Variable Type Len Format Informat Label;
    length Member Label $ 256.;
    length Variable     $ 32.;
    length Format       $ 15.;
    length Informat     $ 11.;
    set codebook;
    if ( ( Variable = "SUBJECT_ID" )
      OR ( Variable = "VISIT_NBR" )
      OR ( Variable = "SEQ_NBR" ) );
    Member = "Various";
    if      ( Variable = "SUBJECT_ID" ) then Label = "Subject ID";
    else if ( Variable = "VISIT_NBR" )  then Label = "Visit Number";
    else if ( Variable = "SEQ_NBR" )    then Label = "Sequence number";
    if      ( Variable = "SUBJECT_ID" ) then Member = "All (appears as the variable ID in the Screening Form)";
run;

******************************************************************************;
*** Now widen (as necessary) and merge the study form data.
*** As this is done, the codebook data set CODEBOOK will be updated.
******************************************************************************;

%MergeNonrepeatedDataIntoOutput(inputData=WORKING.fm002,                                 initData=  MergedWidenedFormData);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm003,repVar1=VISIT_NBR, widePrefix1=V,outputData=MergedWidenedFormData);
%MergeNonrepeatedDataIntoOutput(inputData=WORKING.fm004,                                 outputData=MergedWidenedFormData);

%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm005,repVar1=VISIT_NBR,widePrefix1=V,outputData=MergedWidenedFormData,repVar2=SEQ_NBR,widePrefix2=S);

%MergeNonrepeatedDataIntoOutput(inputData=WORKING.fm011,                                 outputData=MergedWidenedFormData);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm011a,repVar1=SEQ_NBR,  widePrefix1=S,outputData=MergedWidenedFormData);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm011b,repVar1=SEQ_NBR,  widePrefix1=S,outputData=MergedWidenedFormData);
%MergeNonrepeatedDataIntoOutput(inputData=WORKING.fm012,                                 outputData=MergedWidenedFormData);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm013, repVar1=VISIT_NBR,widePrefix1=V,outputData=MergedWidenedFormData);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm013a,repVar1=VISIT_NBR,widePrefix1=V,outputData=MergedWidenedFormData,repVar2=SEQ_NBR,widePrefix2=S);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm014, repVar1=VISIT_NBR,widePrefix1=V,outputData=MergedWidenedFormData);
%MergeNonrepeatedDataIntoOutput(inputData=WORKING.fm015,                                 outputData=MergedWidenedFormData);
%MergeNonrepeatedDataIntoOutput(inputData=WORKING.fm016,                                 outputData=MergedWidenedFormData);
%MergeNonrepeatedDataIntoOutput(inputData=WORKING.fm017,                                 outputData=MergedWidenedFormData);
%MergeNonrepeatedDataIntoOutput(inputData=WORKING.fm018,                                 outputData=MergedWidenedFormData);
%MergeNonrepeatedDataIntoOutput(inputData=WORKING.fm019,                                 outputData=MergedWidenedFormData);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm021, repVar1=VISIT_NBR,widePrefix1=V,outputData=MergedWidenedFormData);

%MergeNonrepeatedDataIntoOutput(inputData=WORKING.fm024,                                 outputData=MergedWidenedFormData);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm024a,repVar1=SEQ_NBR,  widePrefix1=S,outputData=MergedWidenedFormData);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm024b,repVar1=SEQ_NBR,  widePrefix1=S,outputData=MergedWidenedFormData);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm024c,repVar1=SEQ_NBR,  widePrefix1=S,outputData=MergedWidenedFormData);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm024d,repVar1=SEQ_NBR,  widePrefix1=S,outputData=MergedWidenedFormData);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm024e,repVar1=SEQ_NBR,  widePrefix1=S,outputData=MergedWidenedFormData);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm024f,repVar1=SEQ_NBR,  widePrefix1=S,outputData=MergedWidenedFormData);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm024g,repVar1=SEQ_NBR,  widePrefix1=S,outputData=MergedWidenedFormData);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm024h,repVar1=SEQ_NBR,  widePrefix1=S,outputData=MergedWidenedFormData);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm024i,repVar1=SEQ_NBR,  widePrefix1=S,outputData=MergedWidenedFormData);
%WidenDataSetAndMergeIntoOutput(inputData=WORKING.fm024j,repVar1=SEQ_NBR,  widePrefix1=S,outputData=MergedWidenedFormData);

%MergeNonrepeatedDataIntoOutput(inputData=WORKING.fm034,                                 outputData=MergedWidenedFormData);
%MergeNonrepeatedDataIntoOutput(inputData=WORKING.iugr_status,                           outputData=MergedWidenedFormData);
%MergeNonrepeatedDataIntoOutput(inputData=WORKING.gdm_status,                            outputData=MergedWidenedFormData);

*** Turn NOTES options back on (it was turned off by the WIDENDATASET macro).;
options notes;

******************************************************************************;
*** Edit select variable names to conform to variable list from Katie
*** (MS Excel file Copy of Book2 (klg).xlsx)
*** Need to update the corresponding entries in CODEBOOK.
******************************************************************************;

data MergedWidenedFormData;
    set MergedWidenedFormData;
    rename Age_fm002              = Age
           Agecat_fm002           = Agecat
		   Birthweightcat_fm024   = Birthweightcat
           DadBMI_fm011           = DadBMI
           DadBMIcat_fm011        = DadBMIcat
           DadHeight_fm011        = DadHeight
           DadRaceEth_fm011       = DadRaceEth
           DadWeight_fm011        = DadWeight
           Education_fm011        = Education
           ENRBMIcat_fm002        = ENRBMIcat
           HeightSR_fm011         = HeightSR
           Height_fm011           = Height
           Incomecat_fm011        = Incomecat
           Insurance_fm024        = Insurance
           Jobstudent_fm011       = Jobstudent
           JOBS_NUMcat_fm011      = JOBS_NUMcat
           Married_fm011          = Married
		   MissingForm024_fm024   = MissingForm024
           PostWeight_fm015       = PostWeight
           Preweight_fm011        = Preweight
		   PreBMI_fm011           = PreBMI
           RaceEth_fm011          = RaceEth
           Studentcat_fm011       = Studentcat
           Weight_fm011           = Weightv0
		   Weight_fm013_V1        = Weightv1
           Weight_fm013_V2        = Weightv2
           Weight_fm013_V3        = Weightv3
           Weight_fm013_V4        = Weightv4
           Weight_fm013_V5        = Weightv5
		   Weight_fm024           = Weightv6
		   Weight_fm024b_S1       = Weightv6s1
		   Weight_fm024b_S2       = Weightv6s2
		   Weight_fm024b_S3       = Weightv6s3
		   Weight_fm024b_S4       = Weightv6s4
		   Weight_fm024b_S5       = Weightv6s5
		   Weight_fm024b_S6       = Weightv6s6
		   Weight_fm024b_S7       = Weightv6s7
		   Weight_fm024b_S8       = Weightv6s8
		   Weight_fm024b_S9       = Weightv6s9
		   Weight_fm024b_S10      = Weightv6s10
		   Weight_fm024b_S11      = Weightv6s11
		   Weight_fm024b_S12      = Weightv6s12
		   Weight_fm024b_S13      = Weightv6s13
		   Weight_fm024b_S14      = Weightv6s14
		   Weight_fm024b_S15      = Weightv6s15
		   Weight_fm024b_S16      = Weightv6s16
		   Weight_fm024b_S17      = Weightv6s17
		   Weight_fm024b_S18      = Weightv6s18
		   Weight_fm024b_S19      = Weightv6s19
		   Weight_fm024b_S20      = Weightv6s20
		   Weight_fm024b_S21      = Weightv6s21
		   Weight_fm024b_S22      = Weightv6s22
		   Weight_fm024b_S23      = Weightv6s23
		   Weight_fm024b_S24      = Weightv6s24
		   Weight_fm024b_S25      = Weightv6s25
		   Weight_fm024b_S26      = Weightv6s26
		   Weight_fm024b_S27      = Weightv6s27
		   Weight_fm024b_S28      = Weightv6s28
		   Weight_fm024b_S29      = Weightv6s29
		   Weight_fm024b_S30      = Weightv6s30
		   Weight_fm024b_S31      = Weightv6s31
		   Weight_fm024b_S32      = Weightv6s32
           ; 
run;

data codebook;
    set codebook;
    if ( Variable = 'Age_fm002' )              then Variable = 'Age';
    if ( Variable = 'Agecat_fm002' )           then Variable = 'Agecat';
    if ( Variable = 'Birthweightcat_fm024' )   then Variable = 'Birthweightcat';
    if ( Variable = 'DadBMI_fm011' )           then Variable = 'DadBMI';
    if ( Variable = 'DadBMIcat_fm011' )        then Variable = 'DadBMIcat';
    if ( Variable = 'DadHeight_fm011' )        then Variable = 'DadHeight';
    if ( Variable = 'DadRaceEth_fm011' )       then Variable = 'DadRaceEth';
    if ( Variable = 'DadWeight_fm011' )        then Variable = 'DadWeight';
    if ( Variable = 'Education_fm011' )        then Variable = 'Education';
    if ( Variable = 'ENRBMIcat_fm002' )        then Variable = 'ENRBMIcat';
    if ( Variable = 'HeightSR_fm011' )         then Variable = 'HeightSR';
    if ( Variable = 'Height_fm011' )           then Variable = 'Height';
    if ( Variable = 'Incomecat_fm011' )        then Variable = 'Incomecat';
    if ( Variable = 'Insurance_fm024' )        then Variable = 'Insurance';
    if ( Variable = 'Jobstudent_fm011' )       then Variable = 'Jobstudent';
    if ( Variable = 'JOBS_NUMcat_fm011' )      then Variable = 'JOBS_NUMcat';
    if ( Variable = 'Married_fm011' )          then Variable = 'Married';
    if ( Variable = 'RaceEth_fm011' )          then Variable = 'RaceEth';
    if ( Variable = 'Studentcat_fm011' )       then Variable = 'Studentcat';
    if ( Variable = 'MissingForm024_fm024' )   then Variable = 'MissingForm024';
	if ( Variable = 'Weight_fm011' )           then Variable = 'Weightv0';
    if ( Variable = 'PostWeight_fm015' )       then Variable = 'PostWeight';
    if ( Variable = 'Preweight_fm011' )        then Variable = 'Preweight';
	if ( Variable = 'PreBMI_fm011' )           then Variable = 'PreBMI';
	if ( Variable = 'Weight_fm013_V1' )        then Variable = 'Weightv1';
    if ( Variable = 'Weight_fm013_V2' )        then Variable = 'Weightv2';
    if ( Variable = 'Weight_fm013_V3' )        then Variable = 'Weightv3';
    if ( Variable = 'Weight_fm013_V4' )        then Variable = 'Weightv4';
    if ( Variable = 'Weight_fm013_V5' )        then Variable = 'Weightv5';
    if ( Variable = 'Weight_fm024' )           then Variable = 'Weightv6';
	if ( Variable = 'Weight_fm024b_S1' )       then Variable = 'Weightv6s1';
	if ( Variable = 'Weight_fm024b_S2' )       then Variable = 'Weightv6s2';
	if ( Variable = 'Weight_fm024b_S3' )       then Variable = 'Weightv6s3';
	if ( Variable = 'Weight_fm024b_S4' )       then Variable = 'Weightv6s4';
	if ( Variable = 'Weight_fm024b_S5' )       then Variable = 'Weightv6s5';
	if ( Variable = 'Weight_fm024b_S6' )       then Variable = 'Weightv6s6';
	if ( Variable = 'Weight_fm024b_S7' )       then Variable = 'Weightv6s7';
	if ( Variable = 'Weight_fm024b_S8' )       then Variable = 'Weightv6s8';
	if ( Variable = 'Weight_fm024b_S9' )       then Variable = 'Weightv6s9';
	if ( Variable = 'Weight_fm024b_S10' )      then Variable = 'Weightv6s10';
	if ( Variable = 'Weight_fm024b_S11' )      then Variable = 'Weightv6s11';
	if ( Variable = 'Weight_fm024b_S12' )      then Variable = 'Weightv6s12';
	if ( Variable = 'Weight_fm024b_S13' )      then Variable = 'Weightv6s13';
	if ( Variable = 'Weight_fm024b_S14' )      then Variable = 'Weightv6s14';
	if ( Variable = 'Weight_fm024b_S15' )      then Variable = 'Weightv6s15';
	if ( Variable = 'Weight_fm024b_S16' )      then Variable = 'Weightv6s16';
	if ( Variable = 'Weight_fm024b_S17' )      then Variable = 'Weightv6s17';
	if ( Variable = 'Weight_fm024b_S18' )      then Variable = 'Weightv6s18';
	if ( Variable = 'Weight_fm024b_S19' )      then Variable = 'Weightv6s19';
	if ( Variable = 'Weight_fm024b_S20' )      then Variable = 'Weightv6s20';
	if ( Variable = 'Weight_fm024b_S21' )      then Variable = 'Weightv6s21';
	if ( Variable = 'Weight_fm024b_S22' )      then Variable = 'Weightv6s22';
	if ( Variable = 'Weight_fm024b_S23' )      then Variable = 'Weightv6s23';
	if ( Variable = 'Weight_fm024b_S24' )      then Variable = 'Weightv6s24';
	if ( Variable = 'Weight_fm024b_S25' )      then Variable = 'Weightv6s25';
	if ( Variable = 'Weight_fm024b_S26' )      then Variable = 'Weightv6s26';
	if ( Variable = 'Weight_fm024b_S27' )      then Variable = 'Weightv6s27';
	if ( Variable = 'Weight_fm024b_S28' )      then Variable = 'Weightv6s28';
	if ( Variable = 'Weight_fm024b_S29' )      then Variable = 'Weightv6s29';
	if ( Variable = 'Weight_fm024b_S30' )      then Variable = 'Weightv6s30';
	if ( Variable = 'Weight_fm024b_S31' )      then Variable = 'Weightv6s31';
	if ( Variable = 'Weight_fm024b_S32' )      then Variable = 'Weightv6s32';
	
run;

******************************************************************************;
******************************************************************************;
/*4. CODE REVISED AND DERIVED VARIABLES. */
/*     Note: Revised variables are cleaned versions of the original variable or of a previously derived variable*/
/*   and should have a "R#" at the end of the variable to indicate the revision */
/*   number. All variables should be labeled and formated, where apprpriate. */
/*   Revised variables should have the label from the original variable with */
/*   "(Revised)" added to the label. New formats should be added to the Fetal*/
/*     Growth Format Library. */
******************************************************************************;
******************************************************************************;

*** Define parity, gravidity, and prior C-sections.;
DATA WORK.MergedWidenedFormData;
    SET WORK.MergedWidenedFormData; 

    ***************************************;
    *** DERIVED VARIABLES
    ***************************************;

    *** Compute parity.;
    array PPOUTCM[*]  PPOUTCM_fm011b_S1-PPOUTCM_fm011b_S15;
    array PPTOTWKS[*] PPTOTWKS_fm011b_S1-PPTOTWKS_fm011b_S15;
    Parity = 0;
    do i = 1 to 15;
        if ( ( PPOUTCM[i] in (1,2,3) )
         AND ( PPTOTWKS[i] > 20 ) ) then Parity = Parity + 1;
    end;
    label Parity = "Parity (counting responses 1, 2, or 3 to Question K18a in Form 011, with GA > 20 Weeks";
    * label Parity = "Parity, prior live birth or stillbirth, Form 011, K18";

    *** Version 3 (4/8/2014): Make a categorical PARITY variable.;
    if      ( Parity =  . ) then Paritycat = .;
    else if ( Parity >= 4 ) then Paritycat = 4;
    else                         Paritycat = Parity;
    label Paritycat = "Parity (categorical), number of prior live birth or stillbirth [Recategorized Form 011, K18]";
    format Paritycat PARITYF.;

    *** The variable PREGNUM could be used as gravidity.
    *** However, Katie has pointed out that this variable could be unreliable
    *** (e.g., some subjects might have mistakenly answered this question
    *** with number of CHILDREN rather than number of PREGNANCIES.
    *** So, define gravidity not only equal to PREGNUM, but also
    *** equal to the number of non-missing K18a responses.
    *** We will compare these two versions of gravidity below,
    *** as well as explore the Other response.
    *** We have decided to go with the second defintion of GRAVIDITY.;
    Gravidity = 1; * Initialize to 1 to include current pregnancy.;
    do i = 1 to 15;
        if ( PPOUTCM[i] ^= . ) then Gravidity = Gravidity + 1;
    end;
    * label Gravidity = "Gravidity, number of prior pregnancies, Form 011, K18";
    label Gravidity = 'Gravidity (counting nonmissing responses to question K18a in Form 011, including the current pregnancy)';

    *** Compute CONDITIONAL PARITY as gravidity - parity. See email Katie sent on 6/9/2014 at 4:22 PM.;
    Paritycond = Gravidity - Parity;
    label Paritycond = "Conditional Parity (Gravidity - Parity)";

    *** Count number of miscarriages.;
    NumSAB = 0;
    do i = 1 to 15;
        if ( PPOUTCM[i] = 4 ) then NumSAB = NumSAB + 1;
    end;
    label NumSAB = "Number of prior miscarriages, form 011 K18";

    *** Version 3 (4/8/2014): Make a categorical NUMBER OF MISCARRIAGES variable.;
    if      ( NumSAB =  . ) then NumSABcat = .;
    else if ( NumSAB >= 3 ) then NumSABcat = 3;
    else                         NumSABcat = NumSAB;
    label NumSABcat = "Number of prior miscarriages, form 011 K18 (categorical)";
    format NumSABcat NUMSABF.;

    *** Count number of prior caesarians.;
    array PPDELVRY[*] PPDELVRY_fm011b_S1-PPDELVRY_fm011b_S15;
    NumCS = 0;
    do i = 1 to 15;
        if ( PPDELVRY[i] in (2,3) ) then NumCS = NumCS + 1;
    end;
    label NumCS = "Number of prior C-Sections, F011B K18h";
    drop i;
RUN; 

data MergedWidenedFormDatab;
    set MergedWidenedFormData;
    /*    DROP TWINS AND TWIN SPECIFIC VARIABLES*/
    if ( PREGTYPE_fm002 = 2 ) then delete;
    DROP
    TVIS_DT_fm002        TBIRTH_DT_fm002        TFDLMP_DT_fm002        TCALCLMP_fm002        TELIGIBLE_fm002
    TCFSIGNED_fm002        TCONSAMP_fm002        TCONBLD_fm002        TCONPLAC_fm002        TCONUMBC_fm002
    TCONMEDR_fm002        TCONFUT_fm002        TSTUDYGRP_fm002        TINTERVW_fm003_V0    TINTERVW_fm003_V1
    TINTERVW_fm003_V2    TINTERVW_fm003_V3    TINTERVW_fm003_V4    TINTERVW_fm003_V5    TINTERVW_fm003_V6
    TINTERVW_fm003_V7    TQUESTN_fm003_V0    TQUESTN_fm003_V1    TQUESTN_fm003_V2    TQUESTN_fm003_V3
    TQUESTN_fm003_V4    TQUESTN_fm003_V5    TQUESTN_fm003_V6    TQUESTN_fm003_V7    TFFQ3MON_fm003_V0
    TFFQ3MON_fm003_V1    TFFQ3MON_fm003_V2    TFFQ3MON_fm003_V3    TFFQ3MON_fm003_V4    TFFQ3MON_fm003_V5
    TFFQ3MON_fm003_V6    TFFQ3MON_fm003_V7    TANTHROA_fm003_V0    TANTHROA_fm003_V1    TANTHROA_fm003_V2
    TANTHROA_fm003_V3    TANTHROA_fm003_V4    TANTHROA_fm003_V5    TANTHROA_fm003_V6    TANTHROA_fm003_V7
    TANTHRON_fm003_V0    TANTHRON_fm003_V1    TANTHRON_fm003_V2    TANTHRON_fm003_V3    TANTHRON_fm003_V4
    TANTHRON_fm003_V5    TANTHRON_fm003_V6    TANTHRON_fm003_V7    TULTRASN_fm003_V0    TULTRASN_fm003_V1
    TANTHRON_fm003_V5    TANTHRON_fm003_V6    TANTHRON_fm003_V7    TULTRASN_fm003_V0    TULTRASN_fm003_V1
    TULTRASN_fm003_V2    TULTRASN_fm003_V3    TULTRASN_fm003_V4    TULTRASN_fm003_V5    TULTRASN_fm003_V6
    TULTRASN_fm003_V7    TMATBLD_fm003_V0    TMATBLD_fm003_V1    TMATBLD_fm003_V2    TMATBLD_fm003_V3
    TMATBLD_fm003_V4    TMATBLD_fm003_V5    TMATBLD_fm003_V6    TMATBLD_fm003_V7    TPLACENT_fm003_V0
    TMATBLD_fm003_V4    TMATBLD_fm003_V5    TMATBLD_fm003_V6    TMATBLD_fm003_V7    TPLACENT_fm003_V0
    TPLACENT_fm003_V1    TPLACENT_fm003_V2    TPLACENT_fm003_V3    TPLACENT_fm003_V4    TPLACENT_fm003_V5
    TPLACENT_fm003_V6    TPLACENT_fm003_V7    TCORD_fm003_V0        TCORD_fm003_V1        TCORD_fm003_V2
    TCORD_fm003_V3        TCORD_fm003_V4        TCORD_fm003_V5        TCORD_fm003_V6        TCORD_fm003_V7
    TCORD_fm003_V3        TCORD_fm003_V4        TCORD_fm003_V5        TCORD_fm003_V6        TCORD_fm003_V7
    TABSTRAC_fm003_V0    TABSTRAC_fm003_V1    TABSTRAC_fm003_V2    TABSTRAC_fm003_V3    TABSTRAC_fm003_V4
    TABSTRAC_fm003_V5    TABSTRAC_fm003_V6    TABSTRAC_fm003_V7    TCBCR_fm003_V0        TCBCR_fm003_V1
    TCBCR_fm003_V2        TCBCR_fm003_V3        TCBCR_fm003_V4        TCBCR_fm003_V5        TCBCR_fm003_V6
    TCBCR_fm003_V7        T1TULT_fm003_V0        T1TULT_fm003_V1        T1TULT_fm003_V2        T1TULT_fm003_V3
    T1TULT_fm003_V4        T1TULT_fm003_V5        T1TULT_fm003_V6        T1TULT_fm003_V7        TDESIGN_fm003_V0
    TDESIGN_fm003_V1    TDESIGN_fm003_V2    TDESIGN_fm003_V3    TDESIGN_fm003_V4    TDESIGN_fm003_V5
    TDESIGN_fm003_V6    TDESIGN_fm003_V7
    TABORT_fm005_V0_S0-TABORT_fm005_V0_S4
    TABORT_fm005_V1_S0-TABORT_fm005_V1_S4
    TABORT_fm005_V2_S0-TABORT_fm005_V2_S4
    TABORT_fm005_V3_S0-TABORT_fm005_V3_S4
    TABORT_fm005_V4_S0-TABORT_fm005_V4_S4
    TABORT_fm005_V5_S0-TABORT_fm005_V5_S4
    TABORT_fm005_V6_S0-TABORT_fm005_V6_S4
    TABORT_fm005_V7_S0-TABORT_fm005_V7_S4
    TCONG_fm005_V0_S0-TCONG_fm005_V0_S4
    TCONG_fm005_V1_S0-TCONG_fm005_V1_S4
    TCONG_fm005_V2_S0-TCONG_fm005_V2_S4
    TCONG_fm005_V3_S0-TCONG_fm005_V3_S4
    TCONG_fm005_V4_S0-TCONG_fm005_V4_S4
    TCONG_fm005_V5_S0-TCONG_fm005_V5_S4
    TCONG_fm005_V6_S0-TCONG_fm005_V6_S4
    TCONG_fm005_V7_S0-TCONG_fm005_V7_S4
    TFD_fm005_V0_S0-TFD_fm005_V0_S4
    TFD_fm005_V1_S0-TFD_fm005_V1_S4
    TFD_fm005_V2_S0-TFD_fm005_V2_S4
    TFD_fm005_V3_S0-TFD_fm005_V3_S4
    TFD_fm005_V4_S0-TFD_fm005_V4_S4
    TFD_fm005_V5_S0-TFD_fm005_V5_S4
    TFD_fm005_V6_S0-TFD_fm005_V6_S4
    TFD_fm005_V7_S0-TFD_fm005_V7_S4
    THYDRO_fm005_V0_S0-THYDRO_fm005_V0_S4
    THYDRO_fm005_V1_S0-THYDRO_fm005_V1_S4
    THYDRO_fm005_V2_S0-THYDRO_fm005_V2_S4
    THYDRO_fm005_V3_S0-THYDRO_fm005_V3_S4
    THYDRO_fm005_V4_S0-THYDRO_fm005_V4_S4
    THYDRO_fm005_V5_S0-THYDRO_fm005_V5_S4
    THYDRO_fm005_V6_S0-THYDRO_fm005_V6_S4
    THYDRO_fm005_V7_S0-THYDRO_fm005_V7_S4
	Weight_fm013_V6;             

    ***************************************;
    *** DEFINE DERIVED VARIABLES.
    ***************************************;

    *** Visit 0.
    *** Find the date for Visit 0 from Forms 011 and 012.
    *** If the forms have different dates, then choose the one that is the earliest.
    *** Then compute gestational age.;
    VIS_DT         = min(of VIS_DT_fm011, VIS_DT_fm012);
    GA_Visit0_Days = VIS_DT - FDLMP_DT_fm002;
    GAv0           = round(GA_Visit0_Days/7,0.01);
    label GAv0 = "Estimated Gestational Age based on VIS_DT AND FDLMP_DT (weeks), Visit 0";

    *** Visits 1-5.
    *** Find the date for Visit #N, where N = 1 to 5, from Forms 013 and 014.
    *** If the forms have different dates, then choose the one that is the earliest.
    *** (Note that we have visit dates for Visit #6, but we are concerned only
    *** with Visits #1 through #5 here.)
    *** Then compute gestational age.;
    array VIS_DT_fm013_ARRAY[*] VIS_DT_fm013_V1-VIS_DT_fm013_V5;
    array VIS_DT_fm014_ARRAY[*] VIS_DT_fm014_V1-VIS_DT_fm014_V5;
    array GA_Visit_Wks[*}       GAv1 GAv2 GAv3 GAv4 GAv5;
    array GA_Visit_Days[*}      GaDays_1 GaDays_2 GaDays_3 GaDays_4 GaDays_5;

    *** Convert to tall.;
    do VISIT_NBR = 1 to 5;
        VIS_DT = min(of VIS_DT_fm013_ARRAY[VISIT_NBR], VIS_DT_fm014_ARRAY[VISIT_NBR]);

        if ( VIS_DT ^= . ) then do;
            *** Compute GA based on FDLMP_DT.;
            GA_Visit_Days[VISIT_NBR] = VIS_DT - FDLMP_DT_fm002;
            GA_Visit_Wks[VISIT_NBR]  = round(GA_Visit_Days[VISIT_NBR]/7,0.01);
        end;
    end;
    label GAv1  = "Estimated Gestational Age based on VIS_DT AND FDLMP_DT (weeks), Visit 1"
          GAv2  = "Estimated Gestational Age based on VIS_DT AND FDLMP_DT (weeks), Visit 2"
          GAv3  = "Estimated Gestational Age based on VIS_DT AND FDLMP_DT (weeks), Visit 3"
          GAv4  = "Estimated Gestational Age based on VIS_DT AND FDLMP_DT (weeks), Visit 4"
          GAv5  = "Estimated Gestational Age based on VIS_DT AND FDLMP_DT (weeks), Visit 5";

    *** Delivery. Note that all visit numbers in Form 024 are Visit #6.;
    GA_Del_Days = BDOB_fm024 - FDLMP_DT_fm002;
    GADel       = round(GA_Del_Days/7,0.01);
    label GADel  = "Estimated Gestational Age based on BDOB_fm024 AND FDLMP_DT (weeks), At Delivery";

    *** Drop temporary variables.;
    drop VIS_DT VISIT_NBR GA_Visit0_Days GaDays_1-GaDays_5;

    /*--------------------------------------------------------------*/
    /*--------------------------------------------------------------*/

    /* BIRTH OUTCOME AND NEONATAL DEATH */

    /*All potential cases of miscarriage or stillbirth with the gestational age if available  */
    /*were evaluated across data sources by S. Hinkle and K. Laughon Grantz. */
    /*See spreadsheet Creation of Birth Outcome and Neodeath Variables (5-30-2014).xlsx*/

    /*1-Live birth     Live birth >= 20 weeks*/
    /*2-Fetal death-antepartum      Fetal death >= 20 weeks, antepartum*/
    /*3-Fetal death-intrapartum     Fetal death >= 20 weeks, intrapartum*/
    /*4-Fetal death-not specified    Fetal death >= 20 weeks, timing not specified*/
    /*5-Miscarriage     Miscarriage < 20 weeks*/
    /*6-Voluntary Terrmination*/
    /*88-Unknown    */

    if BIRTHOC_fm024 = . then BOutcome = 88; 
    if BIRTHOC_fm024 = 1 then BOutcome = 1; 
    if BIRTHOC_fm024 = 2 then BOutcome = 2; 
    if BIRTHOC_fm024 = 3 then BOutcome = 3; 
    if BIRTHOC_fm024 = 4 then BOutcome = 88; 

    if subject_id ="0040136" then BOutcome =5  ; 
    if subject_id ="0020262" then BOutcome =5  ; 
    if subject_id ="0060037" then BOutcome =5  ; 
    if subject_id ="0050521" then BOutcome =5  ; 
    if subject_id ="0050132" then BOutcome =5  ; 
    if subject_id ="0040366" then BOutcome =5  ; 
    if subject_id ="0100373" then BOutcome =5  ; 
    if subject_id ="0100299" then BOutcome =5  ; 
    if subject_id ="0020225" then BOutcome =5  ; 
    if subject_id ="0050809" then BOutcome =5  ; 
    if subject_id ="0020358" then BOutcome =5  ; 
    if subject_id ="0020739" then BOutcome =3  ; 
    if subject_id ="0060015" then BOutcome =4  ; 
    if subject_id ="0110163" then BOutcome =2  ; 
    if subject_id ="0020506" then BOutcome =1  ; 
    if subject_id ="0070259" then BOutcome =4  ; 
    if subject_id ="0110127" then BOutcome =4  ; 
    if subject_id ="0010289" then BOutcome =4  ; 
    if subject_id ="0100638" then BOutcome =4  ; 
    if subject_id ="0020627" then BOutcome =1  ; 
    if subject_id ="0110148" then BOutcome =1  ; 
    if subject_id ="0120059" then BOutcome =4  ; 
    if subject_id ="0070354" then BOutcome =1  ; 
    if subject_id ="0100738" then BOutcome =4  ; 
    if subject_id ="0020407" then BOutcome =1  ; 
    if subject_id ="0020633" then BOutcome =1  ; 
    if subject_id ="0020689" then BOutcome =1  ; 
    if subject_id ="0110057" then BOutcome =4  ; 
    if subject_id ="0130129" then BOutcome =4  ; 
    if subject_id ="0040074" then BOutcome =4  ; 
    if subject_id ="0040154" then BOutcome =4  ; 
    if subject_id ="0030166" then BOutcome =2  ; 
    if subject_id ="0020163" then BOutcome =2  ; 
    if subject_id ="0030072" then BOutcome =2  ; 
    if subject_id ="0040034" then BOutcome =4  ; 
    if subject_id ="0120072" then BOutcome =2  ; 
    if subject_id ="0010260" then BOutcome =88 ; 
    if subject_id ="0050231" then BOutcome =1  ; 
    if subject_id ="0040270" then BOutcome =2  ; 
    if subject_id ="0130228" then BOutcome =88 ; 
    if subject_id ="0010206" then BOutcome =88 ; 
    if subject_id ="0010320" then BOutcome =1  ; 
    if subject_id ="0040044" then BOutcome =88 ; 
    if subject_id ="0070379" then BOutcome =88 ; 
    if subject_id ="0130190" then BOutcome =88 ; 
    if subject_id ="0070014" then BOutcome =88 ; 
    if subject_id ="0070345" then BOutcome =88 ; 
    if subject_id ="0040160" then BOutcome =88 ; 
    if subject_id ="0010269" then BOutcome =88 ; 
    if subject_id ="0050619" then BOutcome =88 ; 
    if subject_id ="0040153" then BOutcome =88 ; 
    if subject_id ="0040091" then BOutcome =88 ; 
    if subject_id ="0040132" then BOutcome =88 ; 
    if subject_id ="0070116" then BOutcome =88 ; 
    if subject_id ="0010100" then BOutcome =88 ; 
    if subject_id ="0010258" then BOutcome =88 ;  
    /*these last four are updated using the general comment section on form 24*/
    if subject_id ="0010100" then BOutcome =1 ;  /*    Live birth. Participant delivered outside of Columbia and we were not able to get in touch with her or retrieve her medical records.    */
    if subject_id ="0010206" then BOutcome =1 ;  /*    Live birth. Participant delivered outside of Columbia and we were not able to get in touch with her or retrieve her medical records.    */
    if subject_id ="0010258" then BOutcome =1 ;  /*    Live birth. Participant delivered outside of Columbia and we were not able to get in touch with her or retrieve her medical records.    */
    if subject_id ="0010269" then BOutcome =1 ;  /*    The delivery date is actually dec-20-2011. Live birth. Participant delivered outside of Columbia and we were not able to retrieve her medical records.    */
    /*    add level for Voluntary termination of pregnancy. from deactivation form*/
    if Deactivation_fm004 = 5 then BOutcome = 6; 

    ATTRIB BOutcome  LABEL="Pregnancy Outcome (Updated)" Format=NEWOUTCOMEFMT.; 
    *Drop BIRTHOC_fm024; 
    if NEODEATH_fm024 = . then NEODEATHR1 = .; 
    if NEODEATH_fm024 = 1 then NEODEATHR1 = 1; 
    if NEODEATH_fm024 = 2 then NEODEATHR1 = 0; 

    if subject_id ="0020225" then NEODEATHR1 =9;
    if subject_id ="0020358" then NEODEATHR1 =9;
    if subject_id ="0020739" then NEODEATHR1 =9;
    if subject_id ="0020163" then NEODEATHR1 =9;
    if subject_id ="0120072" then NEODEATHR1 =9;
    
    if BOutcome in (2 3 4 5 6) then NEODEATHR1 =9; /*    Stillbirths and miscarriages or vol. terr*/

    ATTRIB NEODEATHR1  LABEL="F024 M10 Neonatal death (Revised)" FORMAT=NEODEATHF.; 
    *Drop NEODEATH_fm024; 

	/*MAJOR AND MINOR ANOMALIES CODED FROM VARIABLE M12 ON FORM 24*/


	/*SUMMARY Anomaly*/

		IF VIS_DT_fm024 NE .      THEN Anomaly = 	0; 
	 	ELSE IF VIS_DT_fm024 EQ . THEN Anomaly = 	88; 

	if subject_id = "0010044" then Anomaly = 	1	; 																				
	if subject_id = "0010152" then Anomaly = 	1	; 																				
	if subject_id = "0010160" then Anomaly = 	1	; 																				
	if subject_id = "0010284" then Anomaly = 	1	; 																				
	if subject_id = "0010296" then Anomaly = 	1	; 																				
	if subject_id = "0010304" then Anomaly = 	1	; 																				
	if subject_id = "0010323" then Anomaly = 	1	; 																				
	if subject_id = "0010324" then Anomaly = 	1	; 																				
	if subject_id = "0010346" then Anomaly = 	1	; 																				
	if subject_id = "0010361" then Anomaly = 	1	; 																				
	if subject_id = "0010376" then Anomaly = 	1	; 																				
	if subject_id = "0020106" then Anomaly = 	1	; 																				
	if subject_id = "0020178" then Anomaly = 	1	; 																				
	if subject_id = "0020402" then Anomaly = 	1	; 																				
	if subject_id = "0020408" then Anomaly = 	1	; 																				
	if subject_id = "0020507" then Anomaly = 	1	; 																				
	if subject_id = "0020602" then Anomaly = 	1	; 																				
	if subject_id = "0030021" then Anomaly = 	1	; 																				
	if subject_id = "0030039" then Anomaly = 	1	; 																				
	if subject_id = "0030056" then Anomaly = 	1	; 																				
	if subject_id = "0030191" then Anomaly = 	1	; 																				
	if subject_id = "0040097" then Anomaly = 	1	; 																				
	if subject_id = "0040149" then Anomaly = 	1	; 																				
	if subject_id = "0040162" then Anomaly = 	1	; 																				
	if subject_id = "0040168" then Anomaly = 	1	; 																				
	if subject_id = "0040263" then Anomaly = 	1	; 																				
	if subject_id = "0040307" then Anomaly = 	1	; 																				
	if subject_id = "0050298" then Anomaly = 	1	; 																				
	if subject_id = "0050407" then Anomaly = 	1	; 																				
	if subject_id = "0050419" then Anomaly = 	1	; 																				
	if subject_id = "0050430" then Anomaly = 	1	; 																				
	if subject_id = "0050559" then Anomaly = 	1	; 																				
	if subject_id = "0050694" then Anomaly = 	1	; 																				
	if subject_id = "0050747" then Anomaly = 	1	; 																				
	if subject_id = "0050756" then Anomaly = 	1	; 																				
	if subject_id = "0050803" then Anomaly = 	1	; 																				
	if subject_id = "0050821" then Anomaly = 	1	; 																				
	if subject_id = "0050847" then Anomaly = 	1	; 																				
	if subject_id = "0060057" then Anomaly = 	1	; 																				
	if subject_id = "0060061" then Anomaly = 	1	; 																				
	if subject_id = "0070021" then Anomaly = 	1	; 																				
	if subject_id = "0070039" then Anomaly = 	1	; 																				
	if subject_id = "0070069" then Anomaly = 	1	; 																				
	if subject_id = "0070309" then Anomaly = 	1	; 																				
	if subject_id = "0070321" then Anomaly = 	1	; 																				
	if subject_id = "0100032" then Anomaly = 	1	; 																				
	if subject_id = "0100038" then Anomaly = 	1	; 																				
	if subject_id = "0100070" then Anomaly = 	1	; 																				
	if subject_id = "0100580" then Anomaly = 	1	; 																				
	if subject_id = "0100615" then Anomaly = 	1	; 																				
	if subject_id = "0100698" then Anomaly = 	1	; 																				
	if subject_id = "0110002" then Anomaly = 	1	; 																				
	if subject_id = "0110043" then Anomaly = 	1	; 																				
	if subject_id = "0110048" then Anomaly = 	1	; 																				
	if subject_id = "0110050" then Anomaly = 	1	; 																				
	if subject_id = "0110083" then Anomaly = 	1	; 																				
	if subject_id = "0110090" then Anomaly = 	1	; 																				
	if subject_id = "0110112" then Anomaly = 	1	; 																				
	if subject_id = "0110121" then Anomaly = 	1	; 																				
	if subject_id = "0110154" then Anomaly = 	1	; 																				
	if subject_id = "0110173" then Anomaly = 	1	; 																				
	if subject_id = "0110181" then Anomaly = 	1	; 																				
	if subject_id = "0110198" then Anomaly = 	1	; 																				
	if subject_id = "0110203" then Anomaly = 	1	; 																				
	if subject_id = "0110207" then Anomaly = 	1	; 																				
	if subject_id = "0120021" then Anomaly = 	1	; 																				
	if subject_id = "0120050" then Anomaly = 	1	; 																				
	if subject_id = "0120075" then Anomaly = 	1	; 																				
	if subject_id = "0120089" then Anomaly = 	1	; 																				
	if subject_id = "0130208" then Anomaly = 	1	; 																				
	if subject_id = "0130219" then Anomaly = 	1	; 																				
	if subject_id = "0130225" then Anomaly = 	1	; 																				
	if subject_id = "0010203" then Anomaly = 	2	; 																				
	if subject_id = "0010290" then Anomaly = 	2	; 																				
	if subject_id = "0050805" then Anomaly = 	2	; 																				
	if subject_id = "0110010" then Anomaly = 	2	; 																				
	if subject_id = "0110095" then Anomaly = 	2	; 																				

	/*MAJOR AND MINOR ANOMALIES CODED FROM VARIABLE M9U_SP NEO MORB - OTHER (SPECIFY) ON FORM 24*/
	/*SEE SPEADSHEET FOR SPECIFICS*/

	if subject_id = "0010261" then Anomaly = 	1	; 
	if subject_id = "0100501" then Anomaly = 	1	; 

	/*MAJOR AND MINOR ANOMALIES CODED FROM VARIABLE M9S PATENT DUCTUS ARTERIOSUS ON FORM 24*/

	if subject_id = "0100003" then Anomaly = 	1	; 

	/*MAJOR AND MINOR ANOMALIES CODED FROM VARIABLE PNCOMPSP_fm024b F024B C1j Other preg complication (specify) ON FORM 24*/
	if subject_id = "0040084" then Anomaly = 	4	; 
	if subject_id = "0010046" then Anomaly = 	4	; 

	/*0040084 Fetal Abdominal mass on ultrasound */
	/*0010046 Moderate ventriculomegaly of fetus */

	/*MAJOR AND MINOR ANOMALIES CODED FROM VARIABLE F024H G5c.i_sp Ultrasound result 3, other (specify) ON FORM 24*/
	if subject_id = "0020208" then Anomaly = 	4	; 
	/* 0020208 cyst in stomach */

	/*MAJOR AND MINOR ANOMALIES FROM ADVERSE EVENT FORM*/
	if subject_id = "0010004" then Anomaly = 	3	; 
	/*0010004 Patient chose to terminate pregnancy due to Anomaly of the fetus */
	if subject_id = "0030050" then Anomaly = 	4	; 
	if subject_id = "0120072" then Anomaly = 	4	; 
	if subject_id = "0120090" then Anomaly = 	4	; 

	attrib Anomaly  label = "Major, minor anomaly classification" format=AnomalyFMT.;

	if MissingForm024 = . then MissingForm024 = 1; 
	attrib MissingForm024  label = "Missing Form 024 Indicator" format=NOYES01F.;
run;

    /*---------------------------------------------------------------------------------*/
    /*---------------------------------------------------------------------------------*/

    /*CODE THE STANDARD VARIABLE*/
    
    /*     NOTE: FETALGROWTH_FREETEXT_20140707.sas7bdat is a dataset with */
    /*           the mapped free text variables from the first two rounds of      */
    /*            mapping (i.e. round 1 being the "certain" exclusions and round 2*/
    /*            being the exclusions that were "other complications" and abnormalities  */
    /*            that we compiled  after the main exclusions were removed. */
    /*           These were mapped by Chris Bryant (Glotech) */
    LIBNAME MAPPED   "N:\DIPHRData\Fetal Growth\Projects\Standard\Free Text Variables\Mapped 20140116";
    DATA WORK.FREETEXT;        SET MAPPED.FETALGROWTH_FREETEXT_20140707; RUN; 
    PROC SORT DATA=MergedWidenedFormDatab;                BY SUBJECT_ID; RUN; 
    PROC SORT DATA=FREETEXT;                              BY SUBJECT_ID; RUN; 
    DATA MergedWidenedFormDatac; MERGE MergedWidenedFormDatab FREETEXT; BY SUBJECT_ID; RUN; 

    DATA MergedWidenedFormDatad; SET MergedWidenedFormDatac; 

    /*................................................*/
    /* REFUSAL BEFORE DELIVERY                        */
    /*................................................*/
    /*This variable is created to separate out the 6 cases that deactivated the day of delivery.*/ 
    /*All form 24 chart abstraction data is available, so they are not excluded from the standard*/

    IF    Deactivation_fm004 = 3 and (BOUTCOME = 88 | BOUTCOME = .)  THEN REF_PRIOR_DELIVERY = 1; 

    /*................................................*/
    /* PRETERM DELIVERY- GESTATIONAL AGE < 37 WEEKS   */
    /*................................................*/

    IF      GADEL = . THEN PRETERM = .; 
    ELSE IF GADEL LT 20 then PRETERM = . ; 
    ELSE IF GADEL LT 37 THEN PRETERM = 1; 
    ELSE    PRETERM = 0;
    ATTRIB  PRETERM LABEL="PRETERM <37 W, 1=YES 0=NO" ; 

    /*................................................*/
    /* HYPERTENSION                                   */
    /*................................................*/

    /*RlimprecR1_fm024:  F024 J1a.vi Labor induction -  Preeclampsia    Chart abstraction form 024; J. Labor and delivery summary - J1a. Reason for labor induction, vi. Maternal indication: Preeclampsia */
    /*RlimhyptR1_fm024:  F024 J1a.vii Labor induction - Hypertension       Chart abstraction form 024; J. Labor and delivery summary - J1a. Reason for labor induction, vii. Maternal indication: hypertension */
    /*RLIMO_SP_HTN:    F024 J1a.ix_sp Labor induction -Other maternal(specify)    Chart abstraction form 024; J. Labor and delivery summary - J1a. Reason for labor induction, ix. Maternal indication: other*/
    /*CSPREECLR1_fm024:  F024 J6m C/S - Preeclampsia     Chart abstraction form 024; J. Labor and delivery summary - J6. Indication for c-section, m. Preeclampsia*/
    /*CSOTR_SP_HTN:    F024 J6p_sp C/S - Other reason (specify)    Chart abstraction form 024; J. Labor and delivery summary - J6. Indication for c-section, p. Other*/
    /*DSGESTHY_fm024:  F024 L1b Discharge dx - Gest hypertension     Chart abstraction form 024; Discharge dx - L1b Gest hypertension; 1-mild, 2-severe, 3-not recorded*/
    /*DSPREECLR1_fm024:  F024 L1c Discharge dx - Preeclampsia       Chart abstraction form 024; Discharge dx - L1c Preeclampsia, eclampsia, HELLP syndrome; 1-mild, 2-severe, 3-not recorded*/
    /*HTN_F024_L1D:    F024 L1d Discharge dx - Unspec hypertension     Chart abstraction form 024; Discharge dx - L1d Unspecified; 1-mild, 2-severe, 3-not recorded*/
    /*DSUNSHYPR1_fm024:  F024 L1v Discharge dx - Other     Chart abstraction form 024; Discharge dx - L1v, Other, Specify */

    /*Note, sources NOT used for the classification for the standard include: */
    /*F024B C1j Other preg complication (specify)    Chart abstraction form 024; C- Prenatal Care Flow Sheet; C1j. Condition or significant pregnancy complication, Specify    PNCOMPSP_HTN*/
    /*F024H G5a.i_sp  Ultrasound result 1 (5), other (specify)    Chart abstraction form 024; G- Prenatal Ultrasound Diagnosis; G5. Result; Specify, If Other    NSUCD1SP_HTN*/
    /*F024 I2_sp Other reason    Chart abstraction form 024; I. Hospital admission resulting in delivery; I2 Reason for admission, 7-If Other, specify     HADMR_SP_HTN*/

    /* GESTATIONAL HYPERTENSION-DISCHARGE DIAGNOSIS*/
        IF DSGESTHY_fm024 IN ( 1 2 ) THEN HTN_F024_L1B = 1; ELSE HTN_F024_L1B = 0; /*1=MILD 2=SEVERE*/
        ATTRIB HTN_F024_L1B LABEL="HYPERTENSION: F024 L1B GEST HYPERTENSION" ; 

    /* PREECLAMPSIA-DISCHARGE DIAGNOSIS*/
        IF DSPREECLR1_fm024 IN ( 1 2 ) THEN HTN_F024_L1C = 1; ELSE HTN_F024_L1C = 0; /*1=MILD 2=SEVERE*/
        ATTRIB HTN_F024_L1C LABEL="HYPERTENSION: F024 L1C PREECLAMPSIA" ; 

    /* UNSPECIFIED HYPERTENSION-DISCHARGE DIAGNOSIS*/
        IF DSUNSHYPR1_fm024 IN ( 1 2 ) THEN HTN_F024_L1D = 1; ELSE HTN_F024_L1D = 0; /*1=MILD 2=SEVERE*/
        ATTRIB HTN_F024_L1D LABEL="HYPERTENSION: F024 L1D UNSPEC HYPERTENSION" ; 

     IF   RLIMPRECR1_fm024  = 1 | 
          RLIMHYPTR1_fm024  = 1 | 
          RLIMO_SP_HTN      = 1 | 
          CSPREECLR1_fm024  = 1 |
          CSOTR_SP_HTN      = 1 | 
          HTN_F024_L1B      = 1 | 
          HTN_F024_L1C      = 1 |
          HTN_F024_L1D      = 1 |  
          DSOTR_SP_HTN      = 1 
    THEN STD_HTN = 1; 
    ATTRIB STD_HTN LABEL="STD SUMMARY: HYPERTENSION"; 

    /*................................................*/
    /* DIABETES                                       */
    /*................................................*/

    /*RlimdiabR1_fm024:  F024 J1a.viii Labor induction - Diabetes     Chart abstraction form 024; J. Labor and delivery summary - J1a. Reason for labor induction, viii. Maternal indication: diabetes */
    /*RLIMO_SP_DM:     F024 J1a.ix_sp Labor induction -Other maternal(specify)    Chart abstraction form 024; J. Labor and delivery summary - J1a. Reason for labor induction, ix. Maternal indication: other*/
    /*CSOTR_SP_DM:     F024 J6p_sp C/S - Other reason (specify)     Chart abstraction form 024; J. Labor and delivery summary - J6. Indication for c-section, p. Other*/
    /*DSGDM_fm024:     F024 L1e Discharge dx - Gest diabetes    Chart abstraction form 024; Discharge dx - L1e, Gestational Diabetes, 1=diet control, 2=medication, 3=unknown control, 4=not recorded*/
    /*DSOTR_SP_DM:     F024 L1v Discharge dx - Other     Chart abstraction form 024; Discharge dx - L1v, Other, Specify */

    /*Note, sources NOT used for the classification for the standard include: */
    /*F024B C1j Other preg complication (specify)    Chart abstraction form 024; C- Prenatal Care Flow Sheet; C1j. Condition or significant pregnancy complication, Specify    PNCOMPSP_DM*/
    /*F024H G5a.i_sp  Ultrasound result 1 (5), other (specify)    Chart abstraction form 024; G- Prenatal Ultrasound Diagnosis; G5. Result; Specify, If Other    NSUCD1SP_DM*/
    /*F024 I2_sp Other reason    Chart abstraction form 024; I. Hospital admission resulting in delivery; I2 Reason for admission, 7-If Other, specify     HADMR_SP_DM*/

    /* DIABETES -DISCHARGE DIAGNOSIS- USE ALL SOURCES OF CONTROL */
        IF DSGDM_fm024 IN ( 1 2 3 ) THEN DM_F024_L1E = 1; ELSE DM_F024_L1E = 0; /*1=DIET CONTROL 2=MEDICATION 3=UNKNOWN CONTROL*/
        ATTRIB DM_F024_L1E LABEL="DIABETES: F024 L1E DISCHARGE- GEST DIABETES" ; 

     IF   RlimdiabR1_fm024    = 1 | 
          RLIMO_SP_DM         = 1 | 
          CSOTR_SP_DM         = 1 |
          DM_F024_L1E         = 1 | 
          DSOTR_SP_DM         = 1 
    THEN STD_DM = 1; 
    ATTRIB STD_DM LABEL="STD SUMMARY: DIABETES"; 

    /*................................................*/
    /* OTHER PREGNANCY COMPLICATIONS                  */
    /*................................................*/

    /*OTHER PREGNANCY COMPLICATIONS*/
    /*RLIMO_SP_OTHER_COMP: F024 J1a.ix_sp Labor induction -Other maternal(specify)    Chart abstraction form 024; J. Labor and delivery summary - J1a. Reason for labor induction, ix. Maternal indication: other*/
    /*DSOTR_SP_OTHER_COMP: F024 L1v Discharge dx - Other     Chart abstraction form 024; Discharge dx - L1v, Other, Specify */
    /*PNCOMPSP_OTHER_COMP: F024B C1j Other preg complication (specify)    Chart abstraction form 024; C- Prenatal Care Flow Sheet; C1j. Condition or significant pregnancy complication, Specify    PNCOMPSP_DM*/

    /*Note, the conditions that were picked up include: chronic hepatitis, colitis, and hypothyroidism. */
    IF       RLIMO_SP_OTHER_COMP = 1 | 
           DSOTR_SP_OTHER_COMP = 1 |
           PNCOMPSP_OTHER_COMP = 1 
    THEN STD_OTHER_COMP = 1; 
    ATTRIB STD_OTHER_COMP LABEL="STD SUMMARY: OTHER PREGNANCY COMPLICATIONS"; 

    /*................................................*/
    /* OTHER PLACENTAL OR UMBILICAL CORD COMPLICATIONS*/
    /*................................................*/

    /*CODE  2 VESSEL CORD,3VC > SUA VARIANT AND CHORIOANGIOMA  AS OTHER PLACENTAL OR UMBILICAL COMPLICAITONS*/
    /*F024 M12  STRUCTURAL ABNORMALITY PRESENT    Chart abstraction form 024; M, neonatal outcome, Neonatal discharge summary*/
    /*F024B C1j Other preg complication (specify)    Chart abstraction form 024; C- Prenatal Care Flow Sheet; C1j. Condition or significant pregnancy complication, Specify*/
    /*F024H G5a.i_sp  Ultrasound result    Chart abstraction form 024; G- Prenatal Ultrasound Diagnosis; G5. Result Code*/
    /*F024H G5a.i_sp  Ultrasound result 1 (5), other (specify)    Chart abstraction form 024; G- Prenatal Ultrasound Diagnosis; G5. Result; Specify, If Other    */

    /*FROM SABNC1_fm024 (check box)*/
    if subject_id = "0040291" then SABNC_PU = 1; 
    if subject_id = "0130214" then SABNC_PU = 1; 
    if subject_id = "0040023" then SABNC_PU = 1; 
    /*0040291    800 - Umbilical cord abnormality (Specify)    2vessel cord, single umbilical artery*/
    /*0130214    800 - Umbilical cord abnormality (Specify)    2 vessel umbilical cord*/
    /*0040023    800 - Umbilical cord abnormality (Specify)    2 vessel cord*/

    /*PNCOMPSP*/
    if subject_id = "0040381" then PNCOMPSP_PU = 1; 
    /*0040381    3VC > SUA VARIANT*/

    /*2VC FROM ULTRASOUNDS*/
    /*check each of the F024H G5a.i Ultrasound Result Code 1 : SEQ_NBR =1-16 for code 341 indicating 2VC*/
    /*Abnormal Umbilical cord*/

    if      NSUCODE1_fm024h_S1 = 341 then  NSUCODE_PU = 1;  
    if      NSUCODE1_fm024h_S2 = 341 then  NSUCODE_PU = 1;  
    if      NSUCODE1_fm024h_S3 = 341 then  NSUCODE_PU = 1;  
    if      NSUCODE1_fm024h_S4 = 341 then  NSUCODE_PU = 1;  
    if      NSUCODE1_fm024h_S5 = 341 then  NSUCODE_PU = 1;  
    if      NSUCODE1_fm024h_S6 = 341 then  NSUCODE_PU = 1;  
    if      NSUCODE1_fm024h_S7 = 341 then  NSUCODE_PU = 1;  
    if      NSUCODE1_fm024h_S8 = 341 then  NSUCODE_PU = 1;  
    if      NSUCODE1_fm024h_S9 = 341 then  NSUCODE_PU = 1;  
    if      NSUCODE1_fm024h_S10= 341 then  NSUCODE_PU = 1;  
    if      NSUCODE1_fm024h_S11= 341 then  NSUCODE_PU = 1;  
    if      NSUCODE1_fm024h_S12= 341 then  NSUCODE_PU = 1;  
    if      NSUCODE1_fm024h_S13= 341 then  NSUCODE_PU = 1;  
    if      NSUCODE1_fm024h_S14= 341 then  NSUCODE_PU = 1;  
    if      NSUCODE1_fm024h_S15= 341 then  NSUCODE_PU = 1;  
    if      NSUCODE1_fm024h_S16= 341 then  NSUCODE_PU = 1;  
            
    if     NSUCODE2_fm024h_S1     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE2_fm024h_S2     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE2_fm024h_S3     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE2_fm024h_S4     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE2_fm024h_S5     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE2_fm024h_S6     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE2_fm024h_S7     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE2_fm024h_S8     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE2_fm024h_S9     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE2_fm024h_S10    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE2_fm024h_S11    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE2_fm024h_S12    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE2_fm024h_S13    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE2_fm024h_S14    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE2_fm024h_S15    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE2_fm024h_S16    = 341 then  NSUCODE_PU = 1;  
            
    if     NSUCODE3_fm024h_S1     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE3_fm024h_S2     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE3_fm024h_S3     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE3_fm024h_S4     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE3_fm024h_S5     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE3_fm024h_S6     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE3_fm024h_S7     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE3_fm024h_S8     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE3_fm024h_S9     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE3_fm024h_S10    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE3_fm024h_S11    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE3_fm024h_S12    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE3_fm024h_S13    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE3_fm024h_S14    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE3_fm024h_S15    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE3_fm024h_S16    = 341 then  NSUCODE_PU = 1;  
            
    if     NSUCODE4_fm024h_S1     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE4_fm024h_S2     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE4_fm024h_S3     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE4_fm024h_S4     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE4_fm024h_S5     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE4_fm024h_S6     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE4_fm024h_S7     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE4_fm024h_S8     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE4_fm024h_S9     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE4_fm024h_S10    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE4_fm024h_S11    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE4_fm024h_S12    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE4_fm024h_S13    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE4_fm024h_S14    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE4_fm024h_S15    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE4_fm024h_S16    = 341 then  NSUCODE_PU = 1;  
            
    if     NSUCODE5_fm024h_S1     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE5_fm024h_S2     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE5_fm024h_S3     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE5_fm024h_S4     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE5_fm024h_S5     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE5_fm024h_S6     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE5_fm024h_S7     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE5_fm024h_S8     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE5_fm024h_S9     = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE5_fm024h_S10    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE5_fm024h_S11    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE5_fm024h_S12    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE5_fm024h_S13    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE5_fm024h_S14    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE5_fm024h_S15    = 341 then  NSUCODE_PU = 1;  
    if     NSUCODE5_fm024h_S16    = 341 then  NSUCODE_PU = 1;  

    /*ULTRASOUND FREE TEXT*/
    /*NSUCD2SP*/
    if subject_id = "0040291" then NSUCODE_SP_PU = 1; 
    /*0040291 2vessel cord, single umbilical artery*/
    /*0040291 single umbilical artery, 2VC*/
    if subject_id = "0020085" then NSUCODE_SP_PU = 1; 
    /*0020085 Chorioangioma of placenta */

    /*OTHER PLACENTAL OR UMBILICAL CORD COMPLICATIONS*/
     IF    SABNC_PU      = 1 | 
           PNCOMPSP_PU   = 1 |
           NSUCODE_PU    = 1 |
           NSUCODE_SP_PU = 1
    THEN   STD_OTHER_PU  = 1; 
    ATTRIB STD_OTHER_PU LABEL="STD SUMMARY: OTHER PLACENTAL OR UMBILICAL COMPLICATIONS"; 

    /*................................................*/
    /* KARYOTYPE ABNORMALITY                          */
    /*................................................*/

    /*KABNT21_fm024: F024 M11b Karyotype abn - Trisomy 21    Chart abstraction form 024; M, neonatal outcome, Neonatal discharge summary, karyotype abnormality*/
    /*KABNT18_fm024: F024 M11c Karyotype abn - Trisomy 18     Chart abstraction form 024; M, neonatal outcome, Neonatal discharge summary, karyotype abnormality*/
    /*KABNT13_fm024: F024 M11d Karyotype abn - Trisomy 13    Chart abstraction form 024; M, neonatal outcome, Neonatal discharge summary, karyotype abnormality*/
    /*KABNSCA_fm024: F024 M11e Karyotype abn - Sex cho aneuploidy     Chart abstraction form 024; M, neonatal outcome, Neonatal discharge summary, karyotype abnormality*/
    /*KABNCPM_fm024: F024 M11f Karyotype abn - Conf placental mosaicism    Chart abstraction form 024; M, neonatal outcome, Neonatal discharge summary, karyotype abnormality*/
    /*KABNOTR_fm024: F024 M11g Karyotype abn - Other    Chart abstraction form 024; M, neonatal outcome, Neonatal discharge summary, karyotype abnormality*/
     
     IF   KABNT21_fm024 = 1 | 
          KABNT18_fm024 = 1 | 
          KABNT13_fm024 = 1 | 
          KABNSCA_fm024 = 1 | 
          KABNCPM_fm024 = 1 | 
          KABNOTR_fm024 = 1 
    THEN  STD_KARYO     = 1;
    ATTRIB STD_KARYO LABEL="STD SUMMARY: KARYOTYPE ABNORMALITY"; 

    /*................................................*/
    /* STRUCTURAL ABNORMALITY DX IN UTERO             */
    /*................................................*/

    IF   ANOMALY  = 4      
    THEN STD_STR_ABN_IU = 1; 
    ATTRIB STD_STR_ABN_IU LABEL="STD SUMMARY: STRUCTURAL ABNORMALITY DX IN UTERO"; 

    /*................................................*/
    /* STRUCTURAL ABNORMALITY DX AFTER BIRTH          */
    /*................................................*/

    /* 1-major anomaly; 2-minor anomaly; 3-anomaly, type not specified*/
    IF   ANOMALY in ( 1 2 3 )
    THEN STD_STR_ABN_BIRTH = 1; 
    ATTRIB STD_STR_ABN_BIRTH LABEL="STD SUMMARY: STRUCTURAL ABNORMALITY DX AFTER BIRTH"; 

    /*................................................*/
    /* NEONATAL MORBIDITIES                           */
    /*................................................*/
    /*F024 M9u_sp Neo morb - Other (specify)    Chart abstraction form 024; M, neonatal outcome, Neonatal discharge summary*/

    IF   NMOTR_SP_OTHER_NEO = 1 
    THEN STD_OTHER_NEO = 1; 
    ELSE STD_OTHER_NEO = 0; 
    ATTRIB STD_OTHER_NEO LABEL="STD SUMMARY: NEONATAL MORBIDITIES"; 

    /*................................................*/
    /* PLACENTAL ABRUPTION                            */
    /*................................................*/

    /*F024B C1j Other preg complication (specify)    Chart abstraction form 024; C- Prenatal Care Flow Sheet; C1j. Condition or significant pregnancy complication, Specify*/
    /*F024H G5a.i_sp  Ultrasound result 1 (5), other (specify)    Chart abstraction form 024; G- Prenatal Ultrasound Diagnosis; G5. Result; Specify, If Other*/
    /*F024 I2_sp Other reason    Chart abstraction form 024; I. Hospital admission resulting in delivery; I2 Reason for admission, 7-If Other, specify */
    /*F024 J6i C/S -          Placenta abruption    Chart abstraction form 024; J. Labor and delivery summary - J6. Indication for c-section*/
    /*F024 L1l Discharge dx - Placenta abruption    Chart abstraction form 024; Discharge dx - */
    /*F024 J1a.ix_sp Labor induction -Other maternal(specify)    Chart abstraction form 024; J. Labor and delivery summary - J1a. Reason for labor induction, ix. Maternal indication: other*/
    /*F024 J1a.xi_sp Labor induction - Other fetal (specify)    Chart abstraction form 024; J. Labor and delivery summary - J1a. Reason for labor induction, xi. fetal indication: other*/
    /*F024 J6p_sp C/S - Other reason (specify)    Chart abstraction form 024; J. Labor and delivery summary - J6. Indication for c-section, p. Other*/
    /*F024 L1v Discharge dx - Other     Chart abstraction form 024; Discharge dx - L1v, Other, Specify */


    /*Note, only abruptions where we were sure about the timing – antepartum (dx on prenatal record) and at delivery were classified for the standard. */
    /*the diagnosis on the ultrasound chart (result code of 322=ABRUPTION/SUB-CHORIONIC HEMORRHAGE) is too non-specific to use as the only classiciation*/

    /*ABRUPTION INDICATED ON ULTRASOUND. CHECK BOX 322=ABRUPTION/SUB-CHORIONIC HEMORRHAGE*/
    /*CHECK NSUCODE1_fm024h_S1 F024H G5a.i Ultrasound Result Code 1-5 : SEQ_NBR = 1-16 */

    if      NSUCODE1_fm024h_S1 = 322 then  ABRUPTION_F024_G5I = 1;  
    if      NSUCODE1_fm024h_S2 = 322 then  ABRUPTION_F024_G5I = 1;  
    if      NSUCODE1_fm024h_S3 = 322 then  ABRUPTION_F024_G5I = 1;  
    if      NSUCODE1_fm024h_S4 = 322 then  ABRUPTION_F024_G5I = 1;  
    if      NSUCODE1_fm024h_S5 = 322 then  ABRUPTION_F024_G5I = 1;  
    if      NSUCODE1_fm024h_S6 = 322 then  ABRUPTION_F024_G5I = 1;  
    if      NSUCODE1_fm024h_S7 = 322 then  ABRUPTION_F024_G5I = 1;  
    if      NSUCODE1_fm024h_S8 = 322 then  ABRUPTION_F024_G5I = 1;  
    if      NSUCODE1_fm024h_S9 = 322 then  ABRUPTION_F024_G5I = 1;  
    if      NSUCODE1_fm024h_S10= 322 then  ABRUPTION_F024_G5I = 1;  
    if      NSUCODE1_fm024h_S11= 322 then  ABRUPTION_F024_G5I = 1;  
    if      NSUCODE1_fm024h_S12= 322 then  ABRUPTION_F024_G5I = 1;  
    if      NSUCODE1_fm024h_S13= 322 then  ABRUPTION_F024_G5I = 1;  
    if      NSUCODE1_fm024h_S14= 322 then  ABRUPTION_F024_G5I = 1;  
    if      NSUCODE1_fm024h_S15= 322 then  ABRUPTION_F024_G5I = 1;  
    if      NSUCODE1_fm024h_S16= 322 then  ABRUPTION_F024_G5I = 1;  
            
    if     NSUCODE2_fm024h_S1     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE2_fm024h_S2     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE2_fm024h_S3     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE2_fm024h_S4     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE2_fm024h_S5     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE2_fm024h_S6     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE2_fm024h_S7     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE2_fm024h_S8     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE2_fm024h_S9     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE2_fm024h_S10    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE2_fm024h_S11    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE2_fm024h_S12    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE2_fm024h_S13    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE2_fm024h_S14    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE2_fm024h_S15    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE2_fm024h_S16    = 322 then  ABRUPTION_F024_G5I = 1;  
            
    if     NSUCODE3_fm024h_S1     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE3_fm024h_S2     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE3_fm024h_S3     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE3_fm024h_S4     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE3_fm024h_S5     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE3_fm024h_S6     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE3_fm024h_S7     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE3_fm024h_S8     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE3_fm024h_S9     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE3_fm024h_S10    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE3_fm024h_S11    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE3_fm024h_S12    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE3_fm024h_S13    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE3_fm024h_S14    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE3_fm024h_S15    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE3_fm024h_S16    = 322 then  ABRUPTION_F024_G5I = 1;  
            
    if     NSUCODE4_fm024h_S1     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE4_fm024h_S2     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE4_fm024h_S3     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE4_fm024h_S4     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE4_fm024h_S5     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE4_fm024h_S6     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE4_fm024h_S7     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE4_fm024h_S8     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE4_fm024h_S9     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE4_fm024h_S10    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE4_fm024h_S11    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE4_fm024h_S12    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE4_fm024h_S13    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE4_fm024h_S14    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE4_fm024h_S15    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE4_fm024h_S16    = 322 then  ABRUPTION_F024_G5I = 1;  
            
    if     NSUCODE5_fm024h_S1     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE5_fm024h_S2     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE5_fm024h_S3     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE5_fm024h_S4     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE5_fm024h_S5     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE5_fm024h_S6     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE5_fm024h_S7     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE5_fm024h_S8     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE5_fm024h_S9     = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE5_fm024h_S10    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE5_fm024h_S11    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE5_fm024h_S12    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE5_fm024h_S13    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE5_fm024h_S14    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE5_fm024h_S15    = 322 then  ABRUPTION_F024_G5I = 1;  
    if     NSUCODE5_fm024h_S16    = 322 then  ABRUPTION_F024_G5I = 1;  

    /*Abruption at delivery, not from labor*/
    if subject_id ="0010343" then STD_ABRUPT = 1; /*    Antepartum abruption at delivery, not from labor    */
    if subject_id ="0040500" then STD_ABRUPT = 1; /*    Abruption at delivery, not from labor    */
    if subject_id ="0050300" then STD_ABRUPT = 1; /*    Abruption at delivery, CD without labor although modlabor spont    */
    if subject_id ="0130104" then STD_ABRUPT = 1; /*    Antepartum abruption, resolved    */

    ATTRIB STD_ABRUPT LABEL="STD SUMMARY: PLACENTAL ABRUPTION"; 

    /*................................................*/
    /* DOPPLER                                        */
    /*................................................*/

    /*F024B C1j Other preg complication (specify)    Chart abstraction form 024; C- Prenatal Care Flow Sheet; C1j. Condition or significant pregnancy complication, Specify*/
    /*F024H G5a.i_sp  Ultrasound result 1 (5), other (specify)    Chart abstraction form 024; G- Prenatal Ultrasound Diagnosis; G5. Result; Specify, If Other*/
    /*F024H G7a Umbilical artery    Chart abstraction form 024; G- Prenatal Ultrasound Diagnosis; G7. Doppler Velocimetry*/
    /*F024H G7E_SP OTHER VESSEL (SPECIFY)-DOPPLER    Chart abstraction form 024; G- Prenatal Ultrasound Diagnosis; G7. Doppler Velocimetry*/
    /*F024 I2_sp Other reason    Chart abstraction form 024; I. Hospital admission resulting in delivery; I2 Reason for admission, 7-If Other, specify */
    /*F024 J6p_sp C/S - Other reason (specify)    Chart abstraction form 024; J. Labor and delivery summary - J6. Indication for c-section, p. Other*/

    /*Note, Abnormal umbilical artery Doppler defined as absent or reversed end diastolic flow. We also checked the ICC data for additional cases, but none were found. */

    /*         DVUMBA      F024H G7a Umbilical artery */
    /*        03=Abnormal, Absent end-diastolic flow (EDF)*/
    /*        04=Abnormal, Reversed EDF*/
        if DVUMBA_fm024h_S1 in (3 4) | 
        DVUMBA_fm024h_S2 in  (3 4) | 
        DVUMBA_fm024h_S3 in  (3 4) | 
        DVUMBA_fm024h_S4 in  (3 4) | 
        DVUMBA_fm024h_S5 in  (3 4) | 
        DVUMBA_fm024h_S6 in  (3 4) | 
        DVUMBA_fm024h_S7 in  (3 4) | 
        DVUMBA_fm024h_S8 in  (3 4) | 
        DVUMBA_fm024h_S9 in  (3 4) | 
        DVUMBA_fm024h_S10 in (3 4) | 
        DVUMBA_fm024h_S11 in (3 4) | 
        DVUMBA_fm024h_S12 in (3 4) | 
        DVUMBA_fm024h_S13 in (3 4) | 
        DVUMBA_fm024h_S14 in (3 4) | 
        DVUMBA_fm024h_S15 in (3 4) | 
        DVUMBA_fm024h_S16 in (3 4) 
        THEN DVUMBA_ABS_REV = 1; 

    ATTRIB DVUMBA_ABS_REV LABEL="F024H G7a Umbilical artery ABSENT OR REVERSED" ; 

     IF    PNCOMPSP_DOPPLER = 1 |
           NSUCD1SP_DOPPLER = 1 | 
           DVUMBA_ABS_REV   = 1 | 
           DVOTRVSP_DOPPLER = 1 | 
           HADMR_SP_DOPPLER = 1 | 
           CSOTR_SP_DOPPLER = 1 
    THEN STD_UMDOPPLER = 1; 
    ATTRIB STD_UMDOPPLER LABEL="STD SUMMARY: UMBILICAL DOPPLER"; 

    /*................................................*/
    /* SUMMARY STANDARD INCLUSION/EXCLUSION VARIABLE  */
    /*................................................*/
    /*Note, using outcome ne 1 insures that all cases were live births stay in the standard and that there were no missing information on the birht outcome. */
    /*Also, this lets all of the deactivated or lost to follow up cases drop out of the standard, except the 6 cases that deactivated after delivery. */
    if PREGTYPE_FM002 = 1 AND BMIGRP_FM002 = 1 then do; 
        IF BOUTCOME         NE 1 |
           NEODEATHR1       NE 0 |    
           STD_HTN           = 1 | 
           STD_DM            = 1 | 
           PRETERM           = 1 | 
           STD_OTHER_COMP    = 1 | 
           STD_KARYO         = 1 | 
           STD_STR_ABN_IU    = 1 | 
           STD_STR_ABN_BIRTH = 1 |
           STD_OTHER_NEO     = 1 | 
           STD_ABRUPT        = 1 | 
           STD_OTHER_PU      = 1 | 
           STD_UMDOPPLER     = 1 
        THEN Standard = 0; ELSE Standard = 1; 
    end; 
        ATTRIB Standard LABEL="Fetal Growth Standard Inclusion" format=stdf.; 

    /*DROP INTERMIN STANDARD VARIABLES*/
    drop HADMR_SP            RLIMO_SP           RLIFO_SP            CSOTR_SP           DSOTR_SP    
         NMOTR_SP            NDCCD1SP           HADMR_SP_abruption  HADMR_SP_demise    
         HADMR_SP_dm         HADMR_SP_doppler   HADMR_SP_htn        CSOTR_SP_abruption    
         CSOTR_SP_demise     CSOTR_SP_dm        CSOTR_SP_doppler    CSOTR_SP_htn    
         DSOTR_SP_abruption  DSOTR_SP_demise    DSOTR_SP_dm         DSOTR_SP_htn
         DSOTR_SP_other_comp NDCCD1SP_ndeath    NMOTR_SP_other_neo  NMOTR_SP_str_abn    
         RLIFO_SP_abruption  RLIFO_SP_demise    RLIMO_SP_abruption  RLIMO_SP_demise    
         RLIMO_SP_dm         RLIMO_SP_htn       RLIMO_SP_other_comp PNCOMPSP    
         PNCOMPSP_abruption  PNCOMPSP_demise    PNCOMPSP_dm         PNCOMPSP_doppler
         PNCOMPSP_htn        PNCOMPSP_str_abn   PNCOMPSP_other_comp NSUCD1SP    
         DVOTRVSP            NSUCD1SP_abruption NSUCD1SP_demise     NSUCD1SP_dm    
         NSUCD1SP_doppler    NSUCD1SP_htn       DVOTRVSP_doppler    REF_PRIOR_DELIVERY    
         PRETERM             HTN_F024_L1B       HTN_F024_L1C        HTN_F024_L1D    
         STD_HTN             DM_F024_L1E        STD_DM              STD_OTHER_COMP    
         SABNC_PU            PNCOMPSP_PU        NSUCODE_PU          NSUCODE_SP_PU    
         STD_OTHER_PU        STD_KARYO          STD_STR_ABN_IU      STD_STR_ABN_BIRTH    
         STD_OTHER_NEO       ABRUPTION_F024_G5I STD_ABRUPT          DVUMBA_ABS_REV    
         STD_UMDOPPLER
         GA_Del_Days; 
run;

******************************************************************************;
******************************************************************************;
*** Add entries for derived variables that were defined ACROSS rather than
*** WITHIN the study forms -- i.e., variables that were defined within this
*** SAS program rather than in one of the SAS programs that updates
*** an individual study form.
******************************************************************************;
******************************************************************************;

*** Obtain unique list of variables in CODEBOOK.
*** SAS Data Set varsInCodeBook
*** Number of observations                  = 1395
*** Number of unique occurences of Variable = 1395
*** Maximum number of repeats of Variable   = 1;
data varsInCodeBook;
    set codebook(keep=Variable);
    if ( Variable ^= ' ' );
run;
%CountUniqueVals(inputData=varsInCodeBook,vrbl=Variable);

*** Obtain a list of variable in MERGEDWIDENEDFORMDATAD.
*** SAS Data Set type_label_format_dat
*** Number of observations                  = 7122
*** Number of unique occurences of Variable = 7122
*** Maximum number of repeats of Variable   = 1;
ods select none;
proc contents data=MergedWidenedFormDatad varnum;
    ods output Position = type_label_format_dat;
run;
ods select all;
%CountUniqueVals(inputData=type_label_format_dat,vrbl=Variable);

*** Remove entries from TYPE_LABEL_DAT if the Variable is already in
*** the codebook or if the variable named contains _fm,
*** or if the Variable is SUBJECT_ID.
*** What remains should be the derived variables.
*** SAS Data Set type_label_format_dat
*** Number of observations                  = 18
*** Number of unique occurences of Variable = 18
*** Maximum number of repeats of Variable   = 1;
proc sort data=varsInCodeBook;        by Variable; run;
proc sort data=type_label_format_dat; by Variable; run;
data type_label_format_dat;
    merge type_label_format_dat varsInCodeBook(in=in2);
    by Variable;
    if ( ( Variable = "SUBJECT_ID" )
      OR ( index(Variable,"_fm") > 0 )
      OR ( in2 ) ) then delete;
run;
%CountUniqueVals(inputData=type_label_format_dat,vrbl=Variable);

*** Macro to add information on derived variables to the code book.
*** Heavily adapted from the macro CODEBOOKNONREPEATEDDATA.;
%macro AddDerivedVariableInfoToCodebook(outputData=);

options nomprint nonotes;

%local i vrbl varLIST;

%local idVar;
%let idVar = SUBJECT_ID;

*** If output data set does not yet exist,
*** initialize it so it can be appended to.;
%if NOT %sysfunc(exist(&outputData)) %then %do;
data &outputData;
    set _NULL_;
run;
%end;

*** Refresh list of variables, now that we have appended the file name to the variable names.;
proc sql noprint;
    select Variable into :varLIST separated by " " from type_label_format_dat;
quit;

*** Process variables one-by-one. Yes, tedious and slow, but I
*** think this is the best way to go for clarity and debugging.
*** Do not include the subject ID variable.;
%let i = 1;
%let vrbl = %scan(&varLIST,&i);
%do %until( NOT %length(&vrbl));

    %put Derived Variables : &i : &vrbl;

    *** Obtain entry for the current variable.;
    data var_dat;
        length Label $ 256.;
        set type_label_format_dat;
        if ( Variable = "&vrbl" );
    run;

    *** Add information on format labels, if any.;
    %AddInfoOnFormatLabelsIfAny(inputData=var_dat,vrbl=&vrbl);

    *** Set Member to Update Merged Data FORMSINGLE - v1.122414.sas VARIABLE.;
    data var_dat;
        set var_dat;
        Member = "DERIVED VARIABLE";
    run;

    *** Append to output data set.;
    data &outputData;
        set &outputData var_dat;
    run;

    *** Delete temporary data set(s).;
    proc datasets nolist;
    delete var_dat;
    run;
    quit;

    *** Get next variable.;
    %let i = %eval( &i + 1 );
    %let vrbl = %scan(&varLIST,&i);
%end;

*** Re-order columns in output data set.
*** It would be VERY convenient to have the label and
*** format value labels right next to the variable names.;
data &outputData;
    retain Member Num Variable Label Format FormatValueLabel;
    set &outputData;
run;

%mend AddDerivedVariableInfoToCodebook;

%AddDerivedVariableInfoToCodebook(outputData=codebook);

*** Drop temporary data set(s).;
proc datasets nolist;
    delete varsInCodeBook type_label_format_dat;
run;
quit;

******************************************************************************;
******************************************************************************;
*** 5. Write to disk.
*** Overwrite the current working data set with the updated data set.
******************************************************************************;
******************************************************************************;

*** Delete temporary data set(s).;
proc datasets nolist;
    delete MergedWidenedFormData MergedWidenedFormDatab MergedWidenedFormDatac freetext ;
run;
quit;

/*4. REPLACE REVISED DATA IN THE WORKING DATA FOLDER. */
*** Overwrite the current working data set with the updated data set.;
DATA WORKING.FORMSINGLE;
    SET WORK.MergedWidenedFormDatad;
RUN;

*** Write out codebook as CSV file.;
proc export data=codebook replace label
    outfile="&WORK_FOLDER/Code Book - formsingle - &RUNDATE..csv"
    dbms=csv;
run;

*** Write out codebook as RTF file.;
* Output RTF file legal-sized in landscape orientation.
* Change the orientation to landscape, for the RTF output.
* Set paper size to 8.5 inches by 17 inches.;
options orientation=landscape;
options papersize=legal;
ods graphics on;
ods rtf file="&WORK_FOLDER/Code Book - formsingle - &RUNDATE..rtf";
ods rtf select Print.Print;
proc print data=codebook label noobs;
run;
ods rtf close;
ods graphics off;

*** Delete temporary data set(s).;
proc datasets nolist;
    delete fmtdata_codebook codebook;
run;
quit;

****************************************************;
*** Make a list of revised variables.
****************************************************;

ods select none;
proc contents data=MergedWidenedFormDatad varnum;
    ods output Position = vartab_sf_single;
run;
ods select all;

data vartab_sf_single;
    set vartab_sf_single(keep=Variable Label);
	if ( index(Label,'Revised') > 0 );
run;

*** Write out list of revised variables as RTF file.;
proc export data=vartab_sf_single replace label
    outfile="&WORK_FOLDER/Revised Variables - formsingle - &RUNDATE..csv"
    dbms=csv;
run;

*** Delete temporary data set(s).;
proc datasets nolist;
    delete MergedWidenedFormDatad vartab_sf_single;
run;
quit;
