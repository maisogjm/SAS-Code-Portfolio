******************************************************************************;
******************************************************************************;
*** Example SAS Script demonstrating usage of the four SAS macros to generate
*** a descriptive table ("Table 1"), with separate columns for each level of
*** some categorical variable.
*** Obviously, the column variable must therefore be categorical.
*** Row variables can be either continuous or categorical.
*** Synthetic data is used for the example.
***
*** Special note regarding levels in categorical variables.
*** Levels of categorical variables will appear in the output table in
*** ALPHABETICAL ORDER. Sometimes some NON-alphabetical order is desired.
*** For example, if the levels of SIZE are "Small", "Medium", and
*** "Large", then when they are in alphabetical order we would have:
*** "Large", "Medium", then "Small". However, we might prefer the order to be
*** "Small", "Medium", and "Large" instead, which is not alphabetical.
*** A work-around is to insert prefixes in the level labels to force the
*** desired ordering, e.g. "A: Small", "B: Medium", and "C: Large".
*** The same holds true for the categorical variable for the columns.
******************************************************************************;
******************************************************************************;

******************************************************************************;
******************************************************************************;
*** Load macros.
*** Change the macro variable MACRO_FOLDER to point to the folder on your
*** computer where the macro definitions are stored.
******************************************************************************;
******************************************************************************;

%let MACRO_FOLDER = C:/Users/maisogjm/Documents/GLOTECH/SAS Utility Macros;
filename macdefs "&MACRO_FOLDER/Utility Macros - v47.011515.sas";
%include macdefs;

******************************************************************************;
******************************************************************************;
*** Generate some random data with two continuous variables HEIGHT and WEIGHT,
*** and two categorical variables COLOR and SIZE.
*** Also generate a categorical variable GROUP to be used for the column variable.
*** Induce some missingness in row and column variables to test the handling
*** of missingness.
***
*** Reference: http://blogs.sas.com/content/iml/2011/08/24/how-to-generate-random-numbers-in-sas/
******************************************************************************;
******************************************************************************;

%MakeSyntheticNonrepeatedData(outputData=random_data,numSubjects=100,randomSeed=123,missingnessPct=0.2);

******************************************************************************;
******************************************************************************;
*** Check number of observations in RANDOM_DATA.
*** Also check the number of unique IDs, and the maximum number of repeats
*** of any ID. The information printed to the SAS Log window is:
***
***     SAS Data Set random_data
***     Number of observations            = 100
***     Number of unique occurences of id = 100
***     Maximum number of repeats of id   = 1
*** 
*** You can copy and paste this information from the Log into your SAS program
*** to help you document your SAS code.
*** In this case, we see that the maximum number of repeats is 1, which
*** indicates that this data is NON-repeated measures. (Usually we use
*** NON-repeated measures when making descriptive tables about subjects.)
******************************************************************************;
******************************************************************************;

%CountUniqueVals(inputData=random_data,vrbl=id);

******************************************************************************;
******************************************************************************;
*** Generate Descriptive Table.
***
*** Demonstration of the following five macros:
*** CATEGORICALROWVAR: generates row for a categorical variable
*** CONTINUOUSROWVAR:  generates row for a continuous variable
*** ADDTEXT:           adds a (possibly blank) text row
*** CONTINUOUSROWVAR_GEOMETRICMEAN: similar to CONTINUOUSROWVAR, but computes
***                    GEOMETRIC rather than ARITHMETIC MEANS.
*** WRITEDESCRIPTIVETABLETORTFFILE: writes the descriptive table to an RTF file.
***
*** At this point, the output data set TABLE1 does not yet exist,
*** so the first call to ADDTEXT will automatically create it.
*** If the output data set TABLE1 already existed, ADDTEXT would instead APPEND to it.
*** The macros CONTINUOUSROWVAR, CONTINUOUSROWVAR_GEOMETRICMEAN, and
*** CATEGORICALROWVAR have the same behavior.
*** Once the output data set TABLE1 exists, calls to the ADDTEXT, CONTINUOUSVAR,
*** CONTINUOUSROWVAR_GEOMETRICMEAN, and CATEGORICALVAR macros APPEND to it.
***
*** For a blank row, invoke ADDTEXT but leave TEXT unspecified.
******************************************************************************;
******************************************************************************;

*** Specify input and output data sets, and the column variable.;
%let INPUT_DATA  = random_data;
%let OUTPUT_DATA = Table1;
%let COLVAR      = Group;

*** Try executing the following SAS commands one-by-one, and after each step
*** examine the result on the output data set TABLE1.;
%AddText(text=CONTINUOUS VARIABLES: ARITHMETIC MEANS);
%ContinuousRowVar(rowVar=Height);
%ContinuousRowVar(rowVar=Weight);
%AddText();
%AddText(text=CONTINUOUS VARIABLES: GEOMETRIC MEANS);
%ContinuousRowVar_GeometricMean(rowVar=Height);
%ContinuousRowVar_GeometricMean(rowVar=Weight);
%AddText();
%AddText(text=CATEGORICAL VARIABLES);
%AddText(text=Color);
%CategoricalRowVar(rowVar=Color);
%AddText();
%AddText(text=Size);
%CategoricalRowVar(rowVar=Size);

*** Write the newly created descriptive table to an RTF file.;
%WriteDescriptiveTableToRtfFile(outFile=C:/Users/maisogjm/Documents/GLOTECH/Table1.rtf);

*** Save the newly created descriptive table to a CSV file.;
%WriteDescriptiveTableToCsvFile(outFile=C:/Users/maisogjm/Documents/GLOTECH/Table1.csv);
