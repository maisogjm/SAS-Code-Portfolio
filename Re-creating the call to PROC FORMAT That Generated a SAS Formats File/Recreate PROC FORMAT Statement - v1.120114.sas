******************************************************************************;
******************************************************************************;
*** SAS program to read in the formats provided by C-TASC, and reverse
*** engineer the PROC FORMAT statement required to create those
*** formats.
******************************************************************************;
******************************************************************************;

%let VERSION     = v1;
%let DATESTR     = 120114;
%let MAIN_FOLDER = N:/DIPHRData/Fetal Growth/Data Management/Working Data;

******************************************************************************;
******************************************************************************;
*** Load formats from C-TASC, store them in a SAS data set name FMTDATA.
******************************************************************************;
******************************************************************************;

%include "N:/DIPHRData/Fetal Growth/Data Management/Working Data/Set Up Formats - v1.112114.sas";

*** Store format information in a temporary SAS data set.;
proc format library=WORK.formats cntlout = fmtdata;
run;

******************************************************************************;
******************************************************************************;
*** Examine formats. Is the STARTING VALUE the same as the ENDING VALUE for
*** all formats? Is the FUZZ VALUE 1E-12 for all formats?
*** Note that while most of the formats are of type N, there are a few listed
*** as type C, which all seem to have a FUZZ VALUE of 0.
******************************************************************************;
******************************************************************************;

*** Is the STARTING VALUE the same as the ENDING VALUE for all formats?;
data start_vs_end;
    set fmtdata(keep=FMTNAME START END);
    if ( START ^= END );
run;
*** The answer is yes.;

*** Is the FUZZ VALUE 1E-12 for all NUMERIC formats?;
data check_fuzz_value;
    set fmtdata(keep=FMTNAME FUZZ TYPE);
    if ( ( TYPE = 'N' ) AND ( FUZZ ^= 1E-12 ) );
run;
*** The answer is yes.;

*** Delete temporary data set(s).;
proc datasets nolist;
    delete start_vs_end check_fuzz_value;
run;
quit;

******************************************************************************;
******************************************************************************;
*** Loop over format names, create a new SAS data set containing statements
*** that correspond to the desired call to PROC FORMAT.
******************************************************************************;
******************************************************************************;

*** Sort BY FMTNAME.;
proc sort data=fmtdata; by FMTNAME; run;

*** Build new SAS data set containing pieces of information that can be used to
*** build the statements that correspond to the desired call to PROC FORMAT.;
data CALL_TO_PROC_FORMAT;
    set fmtdata(keep=FMTNAME START LABEL TYPE) end=lastobs;
    by FMTNAME;
    length ProcFormatStatement $ 196.; * Max length is actually 142, but 196 is safe.;

    *** Set the opening call to PROC FORMAT.;
    if ( _N_ = 1 ) then do;
        ProcFormatStatement = 'proc format;';
        output;
    end;

    *** If this is the FIRST observation for a given format, set the VALUE statement.;
    if ( first.FMTNAME ) then do;
        if ( TYPE = 'N' ) then ProcFormatStatement = cat("    value ",   strip(FMTNAME));
        else                   ProcFormatStatement = cat("    value $ ", strip(FMTNAME));
        output;
    end;

    *** Output key-value pairs within the VALUE statements.;
    if ( TYPE = 'N' ) then do;
        if ( strip(START) = '.' ) then ProcFormatStatement = cat("        ",    strip(START), " = ' '");
        else                           ProcFormatStatement = cat("        ",    strip(START), " = ", quote(strip(Label)));
	end;
    else ProcFormatStatement = cat("        '", strip(START), "' = ",quote(strip(Label)));
    output;

    *** If this is the LAST observation for a given format, issue an ending semicolon.;
    if ( last.FMTNAME ) then do;
        ProcFormatStatement = "    ;";
        output;
    end;

    *** Set the closing RUN statement.;
    if ( lastobs ) then do;
        ProcFormatStatement = 'run;';
        output;
    end;

    keep ProcFormatStatement;
run;

******************************************************************************;
******************************************************************************;
*** Save CALL_TO_PROC_FORMAT to a plain text file.
******************************************************************************;
******************************************************************************;

*** Cool way to write the data to a text file.
*** PROC EXPORT was problematic, inserting extra quotes when none were desired.
*** Reference: http://www.ciser.cornell.edu/FAQ/SAS/write_delimited_file.shtml;
data _NULL_;
    set CALL_TO_PROC_FORMAT;
	FILE "&MAIN_FOLDER/Call To PROC FORMAT to Define Formats - &VERSION..&DATESTR..sas";
	put ProcFormatStatement;
run;
