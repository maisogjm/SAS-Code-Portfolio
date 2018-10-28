proc format;
value ABBOTHNS
1 = "1 - A"
2 = "2 - B"
3 = "3 - Both"
4 = "4 - Not Specified"
;
value ABFMT
1 = "1 - A"
2 = "2 - B"
;
value ABNREASF
1 = "1 - Acute Vasculitis"
2 = "2 - Single Umbilical Artery"
3 = "3 - Thrombus"
4 = "4 - Other"
;
value ACUCHORF
1 = "1 - Yes"
2 = "2 - No"
3 = "3 - Other"
;
value AERELF
1 = "1 - Unrelated, due to concurrent illness"
2 = "2 - Unrelated, due to concurrent drug"
3 = "3 - Remote"
4 = "4 - Possible"
5 = "5 - Probably"
6 = "6 - Definite"
7 = "7 - Other known cause"
;
value AFICODEF
991 = "991 - Absent"
992 = "992 - Decreased / oligo hydramnios"
993 = "993 - Normal / adequate"
994 = "994 - Increased / (poly) hydramnios"
;
value AGEFMT
1 = "1 - LT20"
2 = "2 - 20-24"
3 = "3 - 25-29"
4 = "4 - 30-34"
5 = "5 - 35-39"
6 = "6 - 40-44"
7 = "7 - GT45"
;
value AINR
1 = "1 - Antepartum"
2 = "2 - Intrapartum"
3 = "3 - Not Recorded"
;
value ALC5DPWF
1 = "1 - Not at all"
2 = "2 - Once"
3 = "3 - Twice"
4 = "4 - Three times or more"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value ALCFMT
1 = "1 - Never"
2 = "2 - About once a month"
3 = "3 - About once a week"
4 = "4 - About once a day"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value ALPWFQF
1 = "1 - 5 or more times"
2 = "2 - 2-4 times"
3 = "3 - Once"
4 = "4 - Not at all"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value ALSLVFMT
1 = "1 - 5 or more times a week"
2 = "2 - 2-4 times a week"
3 = "3 - Once a week"
4 = "4 - 1-3 times a month"
5 = "5 - Less than once a month"
6 = "6 - Never"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value AMNFLUDF
1 = "1 - Clear"
2 = "2 - Thin meconium"
3 = "3 - Mod/thick meconium"
4 = "4 - Bloody"
5 = "5 - Meconium unknown degree"
6 = "6 - Other"
7 = "7 - Unknown"
;
value AMOUNTF
. = ' '
1 = "1 - Much more than usual"
2 = "2 - Usual"
3 = "3 - Much less than usual"
8 = "8 - Don't know"
;
value ANOMALYFMT
0 = "0-no anomaly"
1 = "1-major anomaly"
2 = "2-minor anomaly"
3 = "3-anomaly, type not specified"
4 = "4-anomaly, in utero only"
88 = "88-unknown"
;
value ANTSTD1F
1 = "1 - Partial Course"
2 = "2 - Single Course (2 doses)"
3 = "3 - Multiple Courses"
4 = "4 - Not Recorded"
;
value ANTSTDF
1 = "1 - Single Dose"
2 = "2 - Multiple Dose"
3 = "3 - Not Recorded"
;
value AP_FMT
1 = "1 - Absent"
2 = "2 - Present"
;
value ASABSTAF
2 = "2 - Complete"
5 = "5 - Incomplete"
;
value ASASTATF
1 = "1  - FOOD COMPLETE SUPPLEMTNT - COMPLETE"
2 = "2 - FOOD COMPLETE SUPPLEMENT NOT APPLICABLE"
3 = "3 - FOOD COMPLETE SUPPLEMENT QUIT"
4 = "4 - FOOD COMPLETE SUPPLEMENT NOT STARTED"
5 = "5 - FOOD QUIT"
;
value ASNBKGF
1 = "1 - Chinese"
2 = "2 - Filipino"
3 = "3 - Indian Subcontinent (India, Pakistan, Sri Lanka)"
4 = "4 - Japanese"
5 = "5 - Korean"
6 = "6 - Malay"
7 = "7 - Thai"
8 = "8 - Vietnamese"
9 = "9 - Other, specify"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value BFFREQF
1 = "1 - Do not breast feed every day"
2 = "2 - Once every other day"
3 = "3 - One to three times a day"
4 = "4 - Four to eight times a day"
5 = "5 - More than eight times a day"
97 = "97 - Refused to answer"
98 = "98 - Don't Know"
;
value BIRTHOCF
1 = "1 - Live birth"
2 = "2 - Antepartum fetal death"
3 = "3 - Intrapartum fetal death"
4 = "4 - Unknown"
;
value BMICATF
1 = "1 - BMI < 18.5"
2 = "2 - 18.5 <= BMI < 25"
3 = "3 - 25 <= BMI < 30"
4 = "4 - 30 <= BMI < 35"
5 = "5 - BMI >= 35"
;
value BMIGRPF
1 = "1 - Normal"
2 = "2 - Obese"
;
value BRACUP
1 = "1 - A"
2 = "2 - AA"
3 = "3 - B"
4 = "4 - C"
5 = "5 - D"
6 = "6 - DD"
7 = "7 - DDD"
8 = "8 - E"
9 = "9 - EE"
10 = "10 - EEE"
11 = "11 - F"
12 = "12 - G"
13 = "13 - H"
14 = "14 - I"
15 = "15 - J"
16 = "16 - K"
17 = "17 - L"
18 = "18 - M"
;
value BRTHWTF
1 = "1 - Birth Weight < 2500 gm"
2 = "2 - 2500 gm <= Birth Weight < 4000 gm"
3 = "3 - Birth Weight >= 4000 gm"
;
value BSFTEVRF
1 = "1 - Yes"
2 = "2 - Never breast fed"
97 = "97 - Refused to answer"
98 = "98 - Don't Know"
;
value CAFINAL
1 = "1 - Euploid"
2 = "2 - Aneuploid"
3 = "3 - Mosaic"
4 = "4 - Other"
;
value CARSLTS
1 = "1 - 46XX"
2 = "2 - 46XY"
3 = "3 - Other"
4 = "4 - Not Available"
;
value CASEFMT
0 = "0 - Control"
1 = "1 - Case"
;
value CBOXFMT
1 = "1 - Box checked"
;
value CINSRTPF
1 = "1 - Central"
2 = "2 - Paracentral"
3 = "3 - Marginal"
4 = "4 - Velamentous"
5 = "5 - Furcate"
6 = "6 - Interpositional"
;
value COMPLETF
1 = "1 - Complete / intact"
2 = "2 - Complete / disrupted"
3 = "3 - Incomplete / fragmented"
;
value COMPLTDF
1 = "1 - Yes, Respondent gave complete date"
2 = "2 - No. Interviewer entered middle of the week for day"
;
value CONPLAC
1 = "1 - Consent to have her afterbirth (placenta) stored and be used for any future purpose"
2 = "2 - Consent to have her afterbirth (placenta) stored and be used for future fetal growth reasearch"
3 = "3 - Refuse to have her afterbirth (placenta) stored or used for any reason"
;
value CONTYPE
1 = "1 - Consent to have her blood samples stored and be used for any future purpose"
2 = "2 - Consent to have her blood samples stored and be used for future fetal growth research"
3 = "3 - Refuse to have her blood samples stored or used for any reason"
;
value CONUMBC
1 = "1 - Consent to have her umbilical cord blood stored and be used for any future purpose"
2 = "2 - Consent to have her umbilical cord blood stored and be used for future fetal growth research"
3 = "3 - Refuse to have her umbilical cord blood stored or used for any reason"
;
value CRDBLDTY
1 = "1 - Anterial (preferred)"
2 = "2 - Venous"
3 = "3 - Mixed"
4 = "4 - Unknown"
5 = "5 - Not Done"
;
value DATACMPF
. = ' '
1 = "1 - Data Complete"
2 = "2 - Data Missing"
;
value DEACF
1 = "1 - Deceased"
2 = "2 - Lost to follow-up"
3 = "3 - Refusal to continue"
4 = "4 - Moved"
5 = "5 - Voluntary termination of pregnancy"
6 = "6 - Miscarriage/Stillbirth"
7 = "7 - Other"
8 = "8 - Ineligible after enrollment"
;
value DEAC_R
1 = "1 - Deceased"
2 = "2 - Lost to follow-up"
3 = "3 - Refusal to continue"
4 = "4 - Moved"
5 = "5 - Voluntary termination of pregnancy"
6 = "6 - Miscarriage/Stillbirth"
7 = "7 - Other"
;
value DELFMT
1 = "1 - Vaginal"
2 = "2 - C-Section"
3 = "3 - Both"
98 = "98 - DK"
;
value DSGDMF
1 = "1 - Diet Control"
2 = "2 - Medication"
3 = "3 - Unknown Control"
4 = "4 - Not Recorded"
;
value DVDCTVNF
1 = "01 - Normal"
2 = "02 - Abnormal - pulsations"
;
value DVMCAF
1 = "01 - Normal"
2 = "02 - Abnormal, evidence of ""brain sparing"""
;
value DVOTRVF
1 = "01 - Normal"
2 = "02 - Abnormal (specify)"
;
value DVUMBAF
1 = "01 - Normal"
2 = "02 - Abnormal, Increased Systolic/Diastolic ratio"
3 = "03 - Abnormal, Absent end-diastolic flow (EDF)"
4 = "04 - Abnormal, Reversed EDF"
;
value DVUTAFT
1 = "01 - Normal"
2 = "02 - Abnormal, Increased Systolic/Diastolic ratio"
3 = "03 - Abnormal, early diastolic notch"
;
value DVUTRNAF
1 = "01 - Normal"
2 = "02 - Abnormal, Increased Systolic Diastolic ratio"
3 = "03 - Abnormal, early diastolic notch"
;
value EATWTBF
1 = "1 - No one (ate alone)"
2 = "2 - Spouse or partner"
3 = "3 - Child or children"
4 = "4 - Other family"
5 = "5 - Co-worker(s)"
6 = "6 - Friend(s)"
7 = "7 - Other(s)"
9 = "9 - Don't know"
;
value EATWTINF
1 = "1 - Eat Alone"
2 = "2 - Spouse/Partner; Child/Children; Other adult(s)"
3 = "3 - Don't know"
;
value EATWTMSF
1 = "1 - Eat Alone"
2 = "2 - Family Member(s)"
3 = "3 - Other(s)"
4 = "4 - Family Member(s) and Other(s)"
9 = "9 - Don't know"
;
value EBLDLOSF
1 = "1 - < 500 cc"
2 = "2 - 500 - 1000 cc"
3 = "3 - Over 1000 cc"
4 = "4 - Unknown"
;
value EDUCFMT
1 = "1 - No formal schooling"
2 = "2 - Nursery School to 6th Grade"
3 = "3 - 7th - 8th Grade"
4 = "4 - 9th to 11th Grade"
5 = "5 - High School Diploma"
6 = "6 - GED or equivalent"
7 = "7 - Some college- 1-3 Years"
8 = "8 - Associate Degree-(Occupational, Technical or Vocational Program)"
9 = "9 - Bachelor's Degree (e.g., BA, BS)"
10 = "10 - Master's Degree (e.g., MA, MS, MSW, MEng, MBA)"
11 = "11 - Advanced Degree (e.g., MD, PhD, EdD, DVM)"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value EDUFMT
1 = "1 - Less than high school"
5 = "5 - High school diploma or GED or equivalent"
7 = "7 - Some college or Associate degree"
9 = "9 - Bachelors degree"
10 = "10 - Masters degree or Advanced degree"
97 = "97 - Refused"
98 = "98 - Do not Know"
;
value ENRRACEF
1 = "1 - Non-Hispanic White"
2 = "2 - Non-Hispanic Black"
3 = "3 - Hispanic"
4 = "4 - Asian & Pacific Islander"
;
value EPISODEF
1 = "1 - No"
2 = "2 - Yes, mild"
3 = "3 - Yes, moderate"
4 = "4 - Yes, severe"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value EQFLAGF
0 = "0 - Food codes with few or no calories and zero (0) equivalents for all MyPyramid groups"
1 = "1 - Food codes where the number of equivalents for at least one MyPyramid group is greater than zero (0)"
2 = "2 - Food codes for infant formula for which equivalents values have not been assigned and, hence, appear as zero (0) equivalents"
;
value FANOMF
1 = "1 - Yes"
2 = "2 - No"
3 = "3 - Unable to determine"
;
value FETSELF
1 = "1 - Fetus 1"
2 = "2 - Fetus 2"
3 = "3 - Both"
;
value FIBRIN
1 = "1 - Absent"
2 = "2 - Present, focal"
3 = "3 - Present, diffuse"
;
value FOODCMPF
. = ' '
1 = "1 - Data Complete"
2 = "2 - Data Missing"
;
value FOODSRCB
1 = "1 - Store"
2 = "2 - Restaurant"
3 = "3 - Fast food or pizza place"
4 = "4 - Work cafeteria"
5 = "5 - School cafeteria"
6 = "6 - Cafeteria restaurant"
7 = "7 - Bar, tavern, lounge"
8 = "8 - Sport, recreation, or entertainment vendor"
9 = "9 - Street vendor or vending truck"
10 = "10 - Vending machine"
11 = "11 - From someone else/Gift"
12 = "12 - Grown or caught by you or someone you know"
13 = "13 - Someplace else"
98 = "98 - Don't know"
;
value FOODSRCF
1 = "1 - Store"
2 = "2 - Restaurant"
3 = "3 - Fast food or pizza place"
4 = "4 - Work cafeteria"
5 = "5 - School cafeteria"
6 = "6 - Cafeteria restaurant"
7 = "7 - Bar, tavern, lounge"
8 = "8 - Sport, recreation, or entertainment vendor"
9 = "9 - Street vendor or vending truck"
10 = "10 - Vending machine"
;
value FOODTYPF
. = ' '
1 = "1 - Primary"
2 = "2 - Addition"
;
value FSCOLRF
1 = "1 - Tan"
2 = "2 - Green"
3 = "3 - Brown"
4 = "4 - Red"
5 = "5 - Other"
;
value GENDER
1 = "1 - Male"
2 = "2 - Female"
;
value GENDERU
1 = "1 - Male"
2 = "2 - Female"
3 = "3 - Unable to Determine"
;
value GENHLTHF
1 = "1 - Excellent"
2 = "2 - Very good"
3 = "3 - Good"
4 = "4 - Fair"
5 = "5 - Poor"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value GENTF
1 = "1 - Male"
2 = "2 - Female"
3 = "3 - N/D"
;
value HADMRF
1 = "1 - Labor"
2 = "2 - Spontaneous rupture of the membranes without labor"
3 = "3 - Induction"
4 = "4 - Planned cesarean delivery"
5 = "5 - Maternal indication (diabetes, hypertension, preeclampsia, PROM, chorioamnionitis)"
6 = "6 - Fetal indication (non-reassuring fetal status, IUGR, macrosomia, anomalies, demise)"
7 = "7 - Other"
;
value HEMATOMA
1 = "1 - Absent"
2 = "2 - Present, Retroplacental"
3 = "3 - Present, marginal"
;
value HISPORGF
1 = "1 - Puerto Rican"
2 = "2 - Cuban/Cuban American"
3 = "3 - Dominican (Republic)"
4 = "4 - Mexican, Mexican American, Chicano"
5 = "5 - Central or South American"
6 = "6 - Other, specify"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value INCOMEFMT
1 = "1 - Less than $30,000"
2 = "2 - $30,000-$39,999"
3 = "3 - $40,000-$49,999"
4 = "4 - $50,000-$74,999"
5 = "5 - $75,000-$99,999"
6 = "6 - $100,000 or more"
;
value INCOMFMT
1 = "1 - Less than $4,999"
2 = "2 - $5,000-$9,999"
3 = "3 - $10,000-$19,999"
4 = "4 - $20,000-$29,999"
5 = "5 - $30,000-$39,999"
6 = "6 - $40,000-$49,999"
7 = "7 - $50,000-$74,999"
8 = "8 - $75,000-$99,999"
9 = "9 - $100,000-$199,999"
10 = "10 - $200,000 or more"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value INSERTPF
1 = "1 - Marginal"
2 = "2 - Circummarginate"
3 = "3 - Circumvallate"
4 = "4 - Mixed"
;
value INSURANCEF
0 = "0 - Other"
1 = "1 - Private or Managed Care"
;
value INTKDAYF
. = ' '
1 = "1 - SUNDAY"
2 = "2 - MONDAY"
3 = "3 - TUESDAY"
4 = "4 - WEDNESDAY"
5 = "5 - THURSDAY"
6 = "6 - FRIDAY"
7 = "7 - SATURDAY"
;
value JOBSNUMF
1 = "1 - None (stay at home)"
2 = "2 - One job"
3 = "3 - Two jobs"
4 = "4 - More than two jobs"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value JOBSNUMFMT
1 = "1 - None (stay at home)"
2 = "2 - One job"
3 = "3 - Two or more jobs"
97 = "97 - Refused"
98 = "98 - Do not Know"
;
value LABRDISF
1 = "1 - None"
2 = "2 - Prolonged latent phase"
3 = "3 - Prolonged active phase"
4 = "4 - Arrest of dilation"
5 = "5 - Arrest of descent"
6 = "6 - Failure to progress"
7 = "7 - Other"
;
value LANG1F
1 = "1 - English"
2 = "2 - Spanish"
;
value LANG2F
. = ' '
1 = "1 - English"
2 = "2 - Spanish"
3 = "3 - English and Spanish"
;
value LANGES
1 = "1 - English"
2 = "2 - Spanish"
3 = "3 - Chinese"
4 = "4 - Korean"
5 = "5 - Vietnamese"
;
value LIETYPEF
1 = "1 - Vertex"
2 = "2 - Breech"
3 = "3 - Transverse"
4 = "4 - Oblique"
5 = "5 - Unable to determine"
;
value LOCAT1F
1 = "1 - Home"
2 = "2 - Fast food restaurant"
3 = "3 - Other restaurant"
4 = "4 - Cafeteria"
5 = "5 - Bar or tavern"
6 = "6 - Work (not in cafeteria)"
7 = "7 - Car"
8 = "8 - Sports or entertainment venue"
9 = "9 - Some place else"
10 = "10 - School, cafeteria (kids version only)"
11 = "11 - School, not in cafeteria (kids version only)"
98 = "98 - Don't Know"
;
value LOCAT2F
1 = "1 - Home"
2 = "2 - Fast food restaurant"
3 = "3 - Other restaurant"
4 = "4 - Cafeteria"
5 = "5 - Bar or tavern"
6 = "6 - Work (not in cafeteria)"
7 = "7 - Car"
8 = "8 - Sports or entertainment venue"
9 = "9 - Some place else"
10 = "10 - School Cafeteria"
98 = "98 - Don't Know"
;
value LOCAT3F
1 = "1 - Home"
2 = "2 - Restaurant"
3 = "3 - Fast food or pizza place"
4 = "4 - Cafeteria"
5 = "5 - Bar, or tavern"
6 = "6 - Work (not in cafeteria)"
7 = "7 - Car"
8 = "8 - Sport or entertainment venue"
9 = "9 - Some place else"
98 = "98 - Don't know"
;
value LT1CAN
77 = "77 (code for < 1 can)"
;
value LT1CUP
77 = "77 (code for < 1 cup)"
;
value MAFMT
1 = "1 - Manual"
2 = "2 - Automated"
;
value MARITALF
0 = "0 - Not married"
1 = "1 - Married or living with partner"
;
value MARSTATF
1 = "1 - Married"
2 = "2 - Not married but living with a partner of the opposite sex"
3 = "3 - Not married but living together with a partner of the same sex"
4 = "4 - Widowed"
5 = "5 - Divorced"
6 = "6 - Separated"
7 = "7 - Never been married"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value MARSTATFMT
1 = "1 - Married or living with a partner of the same or the opposite sex"
5 = "5 - Widowed, divorced, or separated"
7 = "7 - Never been married"
97 = "97 - Refused"
98 = "98 - Do not Know"
;
value MEMCOLRF
1 = "1 - Tan"
2 = "2 - Red"
3 = "3 - Green"
4 = "4 - Brown"
5 = "5 - Other"
;
value MODDELVF
1 = "1 - Spontaneous vaginal delivery"
2 = "2 - Outlet/low forceps or outlet vacuum"
3 = "3 - Mid-forceps, forceps rotation, or vacuum other than outlet"
4 = "4 - Scheduled Cesarean section without labor"
5 = "5 - Cesarean section after trial of labor"
6 = "6 - Unknown"
;
value MODLABRF
1 = "1 - No Labor"
2 = "2 - Spontaneous"
3 = "3 - Induced"
4 = "4 - Unknown"
;
value MOMAGEFMT
1 = "1 - LT20"
2 = "2 - 20-24"
3 = "3 - 25-29"
4 = "4 - 30-34"
5 = "5 - 35-39"
6 = "6 - 40-44"
7 = "7 - GT45"
;
value MONTHF
1 = "1 - JAN"
2 = "2 - FEB"
3 = "3 - MAR"
4 = "4 - APR"
5 = "5 - MAY"
6 = "6 - JUN"
7 = "7 - JUL"
8 = "8 - AUG"
9 = "9 - SEP"
10 = "10 - OCT"
11 = "11 - NOV"
12 = "12 - DEC"
;
value MOODMED
1 = "1 - Yes, Prozac, Zoloft, Paxil, Celexa, Lexapro, or Luvox"
2 = "2 - Yes, Valium, Xanax, Ativan, or Librium"
3 = "3 - Yes, others"
4 = "4 - No"
97 = "97 - Refused"
;
value MOODS_A
1 = "1 - As much as I always could"
2 = "2 - Not quite so much now"
3 = "3 - Definitely not so much now"
4 = "4 - Not at all"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value MOODS_B
1 = "1 - As much as I ever did"
2 = "2 - Rather less than I used to"
3 = "3 - Definitely less than I used to"
4 = "4 - Hardly at all"
97 = "97 - Refused"
98 = "98 - Don't know"
;
value MOODS_C
1 = "1 - Yes, most of the time"
2 = "2 - Yes, some of the time"
3 = "3 - Not very often"
4 = "4 - No, never"
97 = "97 - Refused"
98 = "98 - Don't know"
;
value MOODS_D
1 = "1 - No, not at all"
2 = "2 - Hardly ever"
3 = "3 - Yes, sometimes"
4 = "4 - Yes, very often"
97 = "97 - Refused"
98 = "98 - Don't know"
;
value MOODS_E
1 = "1 - Yes, quite a lot"
2 = "2 - Yes, sometimes"
3 = "3 - No, not much"
4 = "4 - No, not at all"
97 = "97 - Refused"
98 = "98 - Don't know"
;
value MOODS_F
1 = "1 - Yes, most of the time I haven't been able to cope at all"
2 = "2 - Yes, sometimes I haven't been coping as well as usual"
3 = "3 - No, most of the time I have coped quite well"
4 = "4 - No, I have been coping as well as ever"
97 = "97 - Refused"
98 = "98 - Don't know"
;
value MOODS_G
1 = "1 - Yes, most of the time"
2 = "2 - Yes, sometimes"
3 = "3 - Not very often"
4 = "4 - No, not at all"
97 = "97 - Refused"
98 = "98 - Don't know"
;
value MOODS_H
1 = "1 - Yes, most of the time"
2 = "2 - Yes, quite often"
3 = "3 - Not very often"
4 = "4 - No, not at all"
97 = "97 - Refused"
98 = "98 - Don't know"
;
value MOODS_I
1 = "1 - Yes, most of the time"
2 = "2 - Yes quite often"
3 = "3 - Only occassionally"
4 = "4 - No, never"
97 = "97 - Refused"
98 = "98 - Don't know"
;
value MOODS_J
1 = "1 - Yes, quite often"
2 = "2 - Yes, sometimes"
3 = "3 - Hardly ever"
4 = "4 - Never"
97 = "97 - Refused"
98 = "98 - Don't know"
;
value MSAPRNF
1 = "1 - Normal / lobular"
2 = "2 - Abnormal / irregular with flat areas"
;
value MSCOLORF
1 = "1 - Maroon"
2 = "2 - Pale"
;
value MSSUPCAF
1 = "1 - Absent"
2 = "2 - Focal"
3 = "3 - Diffuse"
;
value MVPCFMT
991 = "991 - Absent"
992 = "992 - Decreased"
993 = "993 - Normal / adequate"
994 = "994 - Increased"
;
value NAPNEEDF
1 = "1 - Most of the time"
2 = "2 - Sometimes"
3 = "3 - Rarely or never"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value NDCCDF
10 = "10 - Congenital malformation"
20 = "20 - RDS"
21 = "21 - RDS with severe intracranial hemorrhage"
22 = "22 - RDS with infection"
25 = "25 - BPD"
26 = "26 - BPD with infection"
30 = "30 - Suspect sepsis / infection"
31 = "31 - Proven sepsis / infection"
40 = "40 - NEC"
41 = "41 - NEC with sepsis"
50 = "50 - Severe intracranial hemorrhage"
60 = "60 - Immaturity"
61 = "61 - Other"
62 = "62 - Unknown"
;
value NDEAB
1 = "1 - Normal"
2 = "2 - Decreased"
3 = "3 - Absent"
;
value NEODEATHF
0 = "0 - No"
1 = "1 - Yes"
9 = "9 - N/A Non-live birth"
;
value NEWOUTCOMEFMT
1 = "1-Live birth"
2 = "2-Fetal death-antepartum"
3 = "3-Fetal death-intrapartum"
4 = "4-Fetal death-not specified"
5 = "5-Miscarriage"
6 = "6-Voluntary termination of pregnancy"
88 = "88-Unknown"
;
value NOCBLSTF
1 = "1- Sent elsewhere for Testing"
2 = "2- Too Little"
3 = "3- Clotted"
4 = "4- Forgotten"
5 = "5- Other"
;
value NOYES01F
0 = "0 - No"
1 = "1 - Yes"
;
value NSUCACDF
100 = "100 - Cystic Hygroma"
201 = "201 - Open neural tube defect (Meningomyelocele,,Spina bifida)"
202 = "202 - Anencephaly"
203 = "203 - Hydranencephaly"
204 = "204 - Hydrocephalus"
205 = "205 - Holoprosencephaly"
299 = "299 - Other Central Nervous System Defects (Specify)"
301 = "301 - Congenital Diaphragmatic Hernia"
302 = "302 - Cystic Adenomatoid Malformation (CAM)"
303 = "303 - Pulmonary Sequestration"
399 = "399 - Other Thorax Defects (Specify)"
401 = "401 - Atrioseptal defect (ASD)"
402 = "402 - Ventricular Septal Defect (VSD)"
403 = "403 - Atrioventricular Canal Defect (Endocardial Cushion Defect)"
404 = "404 - Transposition of the Great Vessels"
405 = "405 - Tetralogy of Fallot"
499 = "499 - Other Congenital Heart Defect (Specify)"
501 = "501 - Cleft Palate"
502 = "502 - Gastroschisis"
503 = "503 - Omphalocele"
504 = "504 - Duodenal Atresia"
599 = "599 - Other Gastro-Intestinal Defect (Specify)"
601 = "601 - Hydronephrosis/ureteropelvic junction obstruction"
602 = "602 - Autosomal Recessive Polycystic Kidney Disease"
603 = "603 - Multicystic/Dysplastic Kidney"
604 = "604 - Posterior Urethral valves (PUV)"
605 = "605 - Renal Agenesis"
699 = "699 - Other Genitourinary Defects (Specify)"
701 = "701 - Skeletal dysplasia"
702 = "702 - Club feet"
799 = "799 - Other limb abnormalities (Specify)"
800 = "800 - Umbilical cord abnormalities"
999 = "999 - Other anomaly (Specify)"
;
value NSUCODEF
100 = "100 - Normal growth"
110 = "110 - IUGR/SGA (Specify growth %-tile)"
120 = "120 - Macrosomia (Specify growth %-tile)"
130 = "130 - Oligohydramnios (AFI < 5.0 cm)"
140 = "140 - Polyhydramnios (AFI > 24.0 cm)"
150 = "150 - Cervical shortening (< 25 mm at < 32 weeks)"
160 = "160 - Fetal arrhythmia"
170 = "170 - Fetal demise"
301 = "301 - Choroid Plexus Cyst (CPC)"
302 = "302 - Pyelectasis (4-10 mm)"
303 = "303 - Echogenic Intra-Cardiac Focus (ECF)"
304 = "304 - Ventriculomegaly (> 10 mm)"
305 = "305 - Bowel hyperechoic"
306 = "306 - Shortened femur or humerus"
307 = "307 - Increased nuchal translucency (> 2.5 mm 1st trimester)"
308 = "308 - Thickened nuchal fold (> 6 mm 2nd trimester)"
310 = "310 - Congenital Anomaly"
321 = "321 - Previa"
322 = "322 - Abruption/sub-chorionic hemorrhage"
329 = "329 - Other abnormal placenta (specify)"
331 = "331 - Marginal"
332 = "332 - Velamentous"
339 = "339 - Other abnormal cord insertion (specify)"
341 = "341 - 2VC"
342 = "342 - Nuchal"
343 = "343 - Varix"
349 = "349 - Other abnormal umbilical cord (specify)"
350 = "350 - Amniotic Band"
499 = "499 - Other (specify)"
;
value NUMSABF
0 = "0"
1 = "1"
2 = "2"
3 = "3+"
;
value OCCNAMEF
. = ' '
1 = "1 - Breakfast"
2 = "2 - Brunch"
3 = "3 - Lunch"
4 = "4 - Dinner"
5 = "5 - Supper"
6 = "6 - Snack"
7 = "7 - Just a Drink"
;
value ODTTTYPE
1 = "1 - 100 gms load"
2 = "2 - 75 gms load"
;
value OUTCOMEF
1 = "1 - Resolved"
2 = "2 - Persistent at the time of reporting"
;
value PAGRP_A
1 = "1 - None"
2 = "2 - Less than 1/2 Hour"
3 = "3 - 1/2 to almost 1 Hour"
4 = "4 - 1 to almost 2 Hours"
5 = "5 - 2 to almost 3 Hours"
6 = "6 - 3 or more Hours"
97 = "97 - Refused"
98 = "98 - DK"
;
value PAGRP_B
1 = "1 - None"
2 = "2 - Less than 1/2 Hour"
3 = "3 - 1/2 to almost 2 Hours"
4 = "4 - 2 to almost 4 Hours"
5 = "5 - 4 to almost 6 Hours"
6 = "6 - 6 or more Hours"
97 = "97 - Refused"
98 = "98 - DK"
;
value PAINFMT
1 = "1 - Yes, always"
2 = "2 - Yes, most of the time"
3 = "3 - Yes, some of the time"
4 = "4 - Never"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value PARITYF
0 = "0"
1 = "1"
2 = "2"
3 = "3"
4 = "4+"
;
value PAXSTAT
1 = "1 - 1 Tube collected"
2 = "2 - 2 Tubes collected"
3 = "3 - Not Collected"
;
value PA_FMT
1 = "1 - Present"
2 = "2 - Absent"
;
value PGOUTCMF
1 = "1 - Live Birth Singleton"
2 = "2 - Live Birth Multiple"
3 = "3 - Still Birth"
4 = "4 - Miscarriage"
5 = "5 - Ectopic Pregnancy"
6 = "6 - Molar Pregnancy"
7 = "7 - Induced Abortion"
8 = "8 - Other"
97 = "97 - Refused"
;
value PNFMT
1 = "1 - Positive"
2 = "2 - Negative"
;
value PPCUTAPF
1 = "1 - Red/Maroon, spongy"
2 = "2 - Pale, boggy"
;
value PPGDTLDF
1 = "1 - Never Pregnant"
2 = "2 - Yes"
3 = "3 - No"
97 = "97 - Refused"
98 = "98 - Don't know"
;
value PRABND
1 = "1 - Present"
2 = "2 - Absent"
3 = "3 - Not Done"
;
value PREGTYPE
1 = "1 - Singleton"
2 = "2 - Twin"
;
value PRESTF
1 = "1 - Vertex"
2 = "2 - Breech"
3 = "3 - Unable to determine"
;
value PRODCFMT
101 = "101 - Narcotic"
102 = "102 - NSAID"
109 = "109 - Other Anagesics"
110 = "110 - Nitrofurantoin"
111 = "111 - Penicillins"
112 = "112 - Metronidazole"
113 = "113 - Erythromycins"
114 = "114 - Sulfa drugs"
115 = "115 - Aminoglycosides"
116 = "116 - Clindamycin"
117 = "117 - Vaginal clindamycin"
118 = "118 - Vaginal metronidazole"
119 = "119 - Vaginal Antifungals"
120 = "120 - Other antiobiotic"
125 = "125 - Anticoagulants"
130 = "130 - Antidepressants"
140 = "140 - Anticonvulsants"
150 = "150 - Tocolytics"
161 = "161 - Aldomet"
162 = "162 - Labetolol"
163 = "163 - Ca-Channel Blockers"
164 = "164 - Beta-Blockers"
165 = "165 - Ace Inhibitors"
169 = "169 - Other Antihypertensive"
170 = "170 - Antipsychotics"
180 = "180 - Antivirals"
190 = "190 - Hormonal contaceptives"
200 = "200 - Chemotherapeutics"
210 = "210 - Diuretics"
220 = "220 - Gi Agents"
230 = "230 - Progesterone (for purpose other than contraception)"
235 = "235 - 17-alphahydroxy-progesterone (Gestiva)"
240 = "240 - Steroids"
251 = "251 - Antithyroids (overactive)"
252 = "252 - Thyroid Replacement (under active)"
260 = "260 - Decongestants"
270 = "270 - Antihistamines"
280 = "280 - Combined Antihstamine/Decongestant"
290 = "290 - Combined antihistamine/Decongestant/Analgesic"
399 = "399 - Other Medication"
400 = "400 - Herbal/Natural Product"
510 = "510 - Multi-vitamin"
520 = "520 - Iron"
530 = "530 - Folate"
599 = "599 - Other Vitamin"
610 = "610 - Influenza"
620 = "620 - Hepatitis B"
630 = "630 - Rubella"
640 = "640 - Varicella-zoster Immune Globulin (VZIG)"
699 = "699 - Other Vaccine"
;
value PRODFFMT
1 = "1 - Less than once a month"
2 = "2 - Once a month"
3 = "3 - 2-3 times a month (but less than once a week)"
4 = "4 - 1-2 times a week"
5 = "5 - 3-4 times a week"
6 = "6 - 5-6 times a week"
7 = "7 - Everyday"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value PRODSTRF
1 = "1 - Before you became pregnant"
2 = "2 - In first month of pregnancy"
3 = "3 - After 1st mo of pregnancy"
97 = "97 - Refused"
98 = "98 - Don't know"
;
value PRODTYP
1 = "1 - Prescription"
2 = "2 - Non Prescription"
;
value PVHIVHGF
1 = "1 - Grade I"
2 = "2 - Grade II"
3 = "3 - Grade III"
4 = "4 - Grade IV"
5 = "5 - Unknown"
;
value RACEETHF
1 = "1 - White/non-Hispanic"
2 = "2 - Black/non-Hispanic"
3 = "3 - Hispanic"
4 = "4 - American Indian or Alaska Native"
5 = "5 - Asian"
6 = "6 - Native Hawaiian or Other Pacific Islander"
7 = "7 - Other race/non-Hispanic"
8 = "8 - Multiracial"
9 = "9 - Unknown"
;
value RDKFMT
1 = "1 - Refused"
2 = "2 - Don't know"
;
value REASC1F
1 = "1 - No time"
2 = "2 - Participant illness/emergency"
3 = "3 - Equipment failure"
4 = "4 - Fainting"
5 = "5 - Light-headedness"
6 = "6 - Hematoma"
7 = "7 - Bruising"
8 = "8 - Vein collapsed during the procedure"
9 = "9 - No suitable vein"
10 = "10 - Other, specify"
11 = "11 - Refused"
12 = "12 - Not expected - OGTT visit"
13 = "13 - Not expected - normal weight cohort"
;
value REASONCF
1 = "1 - No time"
2 = "2 - Participant illness/emergency"
3 = "3 - Equipment failure"
4 = "4 - Fainting"
5 = "5 - Light-headedness"
6 = "6 - Hematoma"
7 = "7 - Bruising"
8 = "8 - Vein collapsed during the procedure"
9 = "9 - No suitable vein"
10 = "10 - Other, specify"
11 = "11 - Refused"
;
value RECOMFMT
1 = "1 - Destroy specimen"
2 = "2 - Relabel specimen"
;
value RGTMFMT
1 = "1 - Too soon"
2 = "2 - Right time"
3 = "3 - Later"
4 = "4 - Didn't care"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value RLSFREQF
1 = "1 - Less than once per month"
2 = "2 - 2 to 4 times per month"
3 = "3 - 2 to 3 times per week"
4 = "4 - 4 to 5 times per week"
5 = "5 - 6 or more times per week"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value RLSMEDSF
1 = "1 - Yes with good response"
2 = "2 - Yes with poor response"
3 = "3 - None of the above medications"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value RLSPAINF
1 = "1 - Yes always"
2 = "2 - Yes most of the time"
3 = "3 - Yes some of the time"
4 = "4 - Never"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value ROUTE
1 = "1 - By mouth"
2 = "2 - Inhaled, either by mouth or nose"
3 = "3 - Injected"
4 = "4 - Applied to skin (i.e., patch or creams)"
5 = "5 - Some other way, specify"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value RUCFMT
100 = "100 - Normal growth"
110 = "110 - IUGR/SGA (Specify growth %-tile)"
120 = "120 - Macrosomia (Specify growth %-tile)"
130 = "130 - Oligohydramnios (AFI < 5.0 cm)"
140 = "140 - Polyhydramnios (AFI > 24.0 cm)"
150 = "150 - Cervical shortening (< 25 mm at < 32 weeks)"
160 = "160 - Fetal arrhythmia"
170 = "170 - Fetal demise"
321 = "321 - Previa"
322 = "322 - Abruption/sub-chorionic hemorrhage"
329 = "329 - Other (specify)"
331 = "331 - Marginal"
332 = "332 - Velamentous"
339 = "339 - Other (specify)"
341 = "341 - 2VC"
342 = "342 - Nuchal"
343 = "343 - Varix"
349 = "349 - Other abnormal umbilical cord (specify)"
350 = "350 - Amniotic Band"
499 = "499 - Other (specify)"
;
value SABNAFT
100 = "100 - Cystic Hygroma"
201 = "201 - Open neural tube defect (Meningomyelocele, Spina bifida)"
202 = "202 - Anencephaly"
203 = "203 - Hydranencephaly"
204 = "204 - Hydrocephalus"
205 = "205 - Holoprosencephaly"
299 = "299 - Other (Specify)"
301 = "301 - Congenital Diaphragmatic Hernia"
302 = "302 - Cystic Adenomatoid Malformation (CAM)"
303 = "303 - Pulmonary Sequestration"
399 = "399 - Other (Specify)"
401 = "401 - Atrioseptal defect (ASD)"
402 = "402 - Ventricular Septal Defect (VSD)"
403 = "403 - Atrioventricular Canal Defect  (Endocardial Cushion Defect)"
404 = "404 - Transposition of the Great Vessels"
405 = "405 - Tetralogy of Fallot"
499 = "499 - Other Congenital Heart Defect (Specify)"
501 = "501 - Cleft Palate"
502 = "502 - Gastroschisis"
503 = "503 - Omphalocele"
504 = "504 - Duodenal Atresia"
599 = "599 - Other Gastro-Intestinal Defect (Specify)"
601 = "601 - Hydronephrosis/ureteropelvic junction obstruction"
602 = "602 - Autosomal Recessive Polycystic Kidney Disease"
603 = "603 - Multicystic / Dysplastic Kidney"
604 = "604 - Posterior Urethral valves (PUV)"
605 = "605 - Renal Agenesis"
699 = "699 - Other GU defect (Specify)"
701 = "701 - Skeletal dysplasia"
702 = "702 - Club feet"
799 = "799 - Other limb abnormalities (Specify)"
800 = "800 - Umbilical cord abnormality (Specify)"
999 = "999 - Other anomaly (Specify)"
;
value SALTFREQ
. = ' '
1 = "1 - Rarely"
2 = "2 - Occassionally"
3 = "3- Very often"
4 = "4 - Other"
8 = "8 - Don't know"
9 = "9 - Not applicable"
;
value SALTTYPE
. = ' '
1 = "1 - Ordinary, sea, seasoned, or other flavored salt"
2 = "2 - Lite salt"
3 = "3 - Salt substitute"
4 = "4 - None"
5 = "5 - Other"
8 = "8 - Don't know"
9 = "9 - Not applicable"
;
value SALTUSED
. = ' '
1 = "1 - Never"
2 = "2 - Rarely"
3 = "3 - Occasionally"
4 = "4 - Very Often"
5 = "5 - Other"
8 = "8 - Don't Know"
9 = "9 - Not applicable"
;
value SEVRMSNR
1 = "1 - Mild"
2 = "2 - Severe"
3 = "3 - Not Recorded"
;
value SFVF
1 = "1 - Intact"
2 = "2 - Disrupted"
3 = "3 - Thrombosed"
4 = "4 - Other"
;
value $ SITEFMT
'001' = "001 - Columbia U."
'002' = "002 - Christiana"
'003' = "003 - St. Peter's"
'004' = "004 - MUSC"
'005' = "005 - Northwestern U."
'006' = "006 - UC Irvine"
'007' = "007 - Long Beach"
'010' = "010 - NYH Queens"
'011' = "011 - U. of Alabama"
'012' = "012 - Fountain Valley"
'013' = "013 - WIHRI"
'014' = "014 - Tufts U."
;
value SLEEPHRF
1 = "1 - 5 hours or less"
2 = "2 - 6 hours"
3 = "3 - 7 hours"
4 = "4 - 8 hours"
5 = "5 - 9 hours"
6 = "6 - 10 or more hours"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value SPECPAXF
1 = "1 - 1 Tube collected"
2 = "2 - 2 Tubes collected"
3 = "3 -  Not collected"
;
value SPECSTAT
1 = "1 - Collected"
2 = "2 - Not Collected"
;
value STATFMT
0 = "0 - In both DCC and FBS database"
1 = "1 - In FBS database only"
2 = "2 - In DCC database only"
3 = "3 - Specimen destroyed, never shipped to FBS"
;
value STDF
0 = "0 - Excluded from standard"
1 = "1 - Included in standard"
;
value STRCABNF
100 = "100 - Cystic Hygroma"
201 = "201 - Open neural tube defect (Meningomyelocele, Spina bifida)"
202 = "202 - Anencephaly"
203 = "203 - Hydranencephaly"
204 = "204 - Hydrocephalus"
205 = "205 - Holoprosencephaly"
299 = "299 - Other Central Nervous System Defect (Specify)"
301 = "301 - Congenital Diaphragmatic Hernia"
302 = "302 - Cystic Adenomatoid Malformation (CAM)"
303 = "303 - Pulmonary Sequestration"
399 = "399 - Other Thorax Defect (Specify)"
401 = "401 - Atrioseptal defect (ASD)"
402 = "402 - Ventricular Septal Defect (VSD)"
403 = "403 - Atrioventricular Canal Defect  (Endocardial Cushion Defect)"
404 = "404 - Transposition of the Great Vessels"
405 = "405 - Tetralogy of Fallot"
499 = "499 - Other Congenital Heart Defect (Specify)"
501 = "501 - Cleft Palate"
502 = "502 - Gastroschisis"
503 = "503 - Omphalocele"
504 = "504 - Duodenal Atresia"
599 = "599 - Other Gastro-Intestinal Defect (Specify)"
601 = "601 - Hydronephrosis/ureteropelvic junction obstruction"
602 = "602 - Autosomal Recessive Polycystic Kidney Disease"
603 = "603 - Multicystic / Dysplastic Kidney"
604 = "604 - Posterior Urethral valves (PUV)"
605 = "605 - Renal Agenesis"
699 = "699 - Other GU defect (Specify)"
701 = "701 - Skeletal dysplasia"
702 = "702 - Club feet"
799 = "799 - Other limb abnormalities (Specify)"
800 = "800 - Umbilical cord abnormality (Specify)"
999 = "999 - Other anomaly (Specify)"
;
value STRESSFQ
1 = "1 - Never"
2 = "2 - Almost never"
3 = "3 - Sometimes"
4 = "4 - Fairly Often"
5 = "5 - Very Often"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value STUDENTF
1 = "1 - No, not a student"
2 = "2 - Yes, full-time student"
3 = "3 - Yes, part-time student"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value STUDENTFMT
1 = "1 - No, not a student"
2 = "2 - Yes, full- or part-time student"
97 = "97 - Refused"
98 = "98 - Do not Know"
;
value STUDYFMT
1 = "1 - Singleton"
2 = "2 - Twins"
;
value STYPEFMT
1 = "1 - Maternal Blood Serum"
2 = "2 - Maternal Blood Plasma"
3 = "3 - Maternal Blood Buffycoat"
4 = "4 - Maternal Blood RBC"
5 = "5 - Maternal Blood Clots"
6 = "6 - Maternal Blood Paxgene"
7 = "7 - Placenta"
8 = "8 - Infant Buccal Swab"
11 = "11 - Cord Blood Serum"
12 = "12 - Cord Blood Plasma"
13 = "13 - Cord Blood Buffycoat"
14 = "14 - Cord Blood RBC"
15 = "15 - Cord Blood Clots"
16 = "16 - Cord Blood Paxgene"
;
value SUPTFMT
1 = "1 - None of the time"
2 = "2 - A little of the time"
3 = "3 - Some of the time"
4 = "4 - Most of the time"
5 = "5 - All of the time"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value TEVALRF
1 = "1 - Unexpected delivery at outside hospital"
2 = "2 - Woman did not consent to pathology and/or elected to take the placenta home"
3 = "3 - Not sent to pathology, intended (i.e. delivering clinician elected not to submit to pathology)"
4 = "4 - Not sent to pathology, unintended"
5 = "5 - Other"
;
value THAWFMT
1 = "1 - Thawed"
;
value TRNSPCYF
1 = "1 - Translucent"
2 = "2 - Opaque"
;
value URDIPR
1 = "1 - Negative"
2 = "2 - Trace"
3 = "3 - 1+"
4 = "4 - 2+"
5 = "5 - 3+"
6 = "6 - 4+"
;
value VERSIONF
1 = "1 - Yes"
2 = "2 - No"
3 = "3 - Unable to determine"
;
value VISTYPEF
1 = "1 - Hospital Admission"
2 = "2 - L,D Triage"
3 = "3 - ER Visit"
;
value VSTATF
1 = "1 - Partially missed"
2 = "2 - Completely missed"
;
value WATCHTVB
1 = "1 - Yes, and I watched it"
2 = "2 - Yes, but I didn't watch"
3 = "3 - No"
9 = "9 - Don't know"
;
value WATCHTVF
1 = "1 - Watching TV"
2 = "2 - Using a computer"
3 = "3 - Watching TV and uising a computer"
4 = "4 - Neither of these"
;
value WGHTSRCF
1 = "1 - Birth Weight"
2 = "2 - Measured at time of exam"
;
value WHTBKGF
1 = "1 - European ancestry"
2 = "2 - Northern Africa"
3 = "3 - Middle Eastern"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value YNDKFMT
1 = "1 - Yes"
2 = "2 - No"
98 = "98 - DK"
;
value YNFMT
1 = "1 - Yes"
2 = "2 - No"
;
value YNNARDK
1 = "1 - Yes"
2 = "2 - No"
3 = "3 - Not Applicable"
97 = "97 - Refused"
98 = "98 - Don't Know"
;
value YNOTREC
1 = "1 - Yes"
2 = "2 - Not Recorded"
;
value YNRDK
1 = "1 - Yes"
2 = "2 - No"
97 = "97 - Refused to answer"
98 = "98 - DK"
;
value YNUKNF
1 = "1 - Yes"
2 = "2 - No"
3 = "3 - Unknown"
;
run;
