/* special cases */

/* sæt i alfabetisk rækkefølge efter bedste evne... */
/* A */
/* adipo - Fedme adipositas */
/* old name: adipo - new obese2 */
/*
%let LPRadipo             = E65 E66 E67 E68;
%let LPRadipo_ICD8        = "";
%let LPRLadipo            = "Adipositas";
*/

/* AFli - Atrial Fibrillation  */
%let LPRAFli             = I48;
%let LPRAFli_ICD8        = 42793 42794;
%let LPRLAFli            = "Atrial Fibrillation";

/* AFlis - Atrial Fibrillation specific */
%let LPRaflis             = I480 I481 I482 I489B;
%let LPRaflis_ICD8        = ;
%let LPRLaflis            = "Atrial Fibrillation - specific";

/* AFlu - Atrial Flutter  */
%let LPRaflu             = I483 I484 I489A;
%let LPRaflu_ICD8        = ;
%let LPRLaflu            = "Atrial Flutter";

/* AIDS - HIV/AIDS */
%let LPRAids             = B21 B22 B23 B24;
%let LPRAids_ICD8        = "";
%let LPRLAids            = "HIV/AIDS";


/* Alco - Alcohol */
*%let LPRalco             = E244 E529A F10 G312 G621 G721 I426 K292 K70 K860 L278A O354 T51 Z714 Z721;
*%let LPRalco_ICD8        = 30309 30319 30320 30328 30329 30390 57110 57301 57710;
*%let LPRLalco            = "Alcohol";

/* Alcopsyk - Alcohol psychosis and alcohol abuse syndrome */
%let LPRAlcopsyk             = F102 F103 F104 F105 F106 F107 F108 F109;
%let LPRAlcopsyk_ICD8        = 29109 29119 29129 29139 29199 30309 30319 30320 30328 30329 30390 30391 30399;
%let LPRLAlcopsyk            = "Alcohol psychosis and alcohol abuse syndrome";

/* Anemia */
%let LPRAnemia           = D5 D60 D61 D62 D63 D64;
%let LPRAnemia_ICD8      = 280 281 282 283 284 285;
%let LPRLAnemia          = "Anemia";

/* Amnsyn - Amnestic syndromes */
%let LPRAmnsyn            = F04 F051 F106 F186 F196;
%let LPRAmnsyn_ICD8       = 29119;
%let LPRLAmnsyn           = "Amnestic syndromes";

/* ApLaq - Aortic plaque */
%let LPRApLaq            = I700;
%let LPRApLaq_ICD8       = "";
%let LPRLApLaq           = "Aortic Plaque";

/* avblo - AV Block */
%let LPRavblo            = I441 I442 I443;
%let LPRavblo_ICD8       = "";
%let LPRLavblo           = "AV block";

/* alzdi - Alzheimer's disease */
%let LPRalzdi            = F00 G30;
%let LPRalzdi_ICD8       = 29010 29009;
%let LPRLalzdi           = "Alzheimer's disease";


/* B */

/* C */
/* cancer */
%let LPRcancer           = C;
%let LPRcancer_ICD8      = "";
%let LPRLcancer          = "Cancer";

/* canna - cannabis */
%let LPRcanna           = F12;
%let LPRcanna_ICD8      = 30459;
%let LPRLcanna          = "Cannabis";

/* carmyo - Cardio Myopathy */
%let LPRcarmyo           = I42 I43;
%let LPRcarmyo_ICD8      = "";
%let LPRLcarmyo          = "Cardio myopathy";

/* old name: cereamy - Cerebral amyloid angiopati */
/* cereamy - Cerebral amyloid angiopati */
/*
%let LPRcereamy            = I680;
%let LPRcereamy_ICD8       = "";
%let LPRLcereamy           = "Cerebral amyloid angiopati";
*/

/* chd - Medfødte hjertemisdannelser - Congenitial heart disease */
%let LPRchd            = Q20 Q21 Q22 Q23 Q24 I424A;
%let LPRchd_ICD8       = "";
%let LPRLchd           = "Congenital heart disease";

/* chrglome - Chronic glomerulonephritis */
%let LPRchrglome            = N02 N03 N05 N06 N07;
%let LPRchrglome_ICD8       = 582 583;
%let LPRLchrglome           = "Chronic glomerulonephritis";

/* chrtunep - Chronic tubulointestinal nephropathy */
%let LPRchrtunep            = N11 N12 N14 N158 N159 N160 N162 N163 N164 N169;
%let LPRchrtunep_ICD8       = 59009 59320;
%let LPRLchrtunep           = "Chronic tubulointestinal nephropathy";

/* CircDis - other disorders of the circulatory system  */
%let LPRCircDis             = I870;
%let LPRCircDis_ICD8        = "";
%let LPRLCircDis            = "Other circulatory disorders";

/* Coca - Cocaine  */
%let LPRCoca             = F14;
%let LPRCoca_ICD8        = 30449;
%let LPRLCoca            = "Cocaine";

/* Cognit - Cognitive impairment  */
%let LPRCognit             = F06;
%let LPRCognit_ICD8        = "";
%let LPRLCognit            = "Cognitive impairment";

/* CPD - Chronic Pulmonary Disorder (KOL) - Thygesen et al 2011 - ændret 17/5 2016 så den modsvarer versionen på DS */
%let LPRCPD              = J40 J41 J42 J43 J44 J45 J46 J47 J60 J61 J62 J63 J64 J65 J67 J684 J701 J703 J841 J920 J921 J982 J983;
%let LPRCPD_ICD8         = 490 491 493 515 516 517 518;
%let LPRLCPD             = "Chronic Pulmonary Disorder";

/* crenal - chronic kidney disease (FSEID00001577 t011) */
%let LPRcrenal              = E102 E112 E142 I120 I131 I132 I150 I151 N03 N05 N06 N07 N08 N110 N14 N15 N16 N18 N19 N26 N27 N280 N391 Q61;
%let LPRcrenal_ICD8         = 24902 25002 582 583 584 59009 59320 75309 75310 75311 75319 792;
%let LPRLcrenal             = "Chronic kidney disease";


/* D */
/* Depre - Depression */
%let LPRDepre          = F32 F33;
%let LPRDepre_ICD8     = 29609 29629 29699 29809;
%let LPRLDepre         = "Depression";

/* DiabLPR - Diabetes Mellitus */
*%let LPRDiabLPR          = E100 E101 E109 E110 E111 E119;
*%let LPRDiabLPR_ICD8     = 24900 24909 25008 25009;
*%let LPRLDiabLPR         = "Diabetes Mellitus";

/* Diab2LPR - Diabetes Mellitus */
%let LPRDiab2LPR          = E10 E11;
%let LPRDiab2LPR_ICD8     = 24900 24909 25008 25009;
%let LPRLDiab2LPR         = "Diabetes Mellitus";

/* Diab3LPR - Diabetes Mellitus FSEID00001577 t0011 project*/
%let LPRDiab3LPR          = E10 E11 E14;
%let LPRDiab3LPR_ICD8     = 24900 24901 24902 24903 24904 24905 24906 24907 24908 24909 25000 25001 25002 25003 25004 25005 25006 25007 25008 25009;
%let LPRLDiab3LPR         = "Diabetes Mellitus";

/* diabnep - Diabetic nephropathy */
%let LPRdiabnep            = E102 E112 E132 E142 N083;
%let LPRdiabnep_ICD8       = 25002;
%let LPRLdiabnep           = "Diabetic nephropathy";

/* DVT */
%let LPRdvt              = I801 I802 I803 I808 I809 I819 I636 I676 I822 I823 I828 I829;
%let LPRdvt_ICD8         = 451;
%let LPRLdvt             = "DVT";

/* E */
/* F */

/* G */
/* GBleed2 - Gastrointestinal bleeding, strict version  */
%let LPRGBleed2          = K250 K252 K254 K260 K262 K264 K270 K272 K274 K280 K282 K290 K921 K922;
%let LPRGBleed2_ICD8     = 53091 53098 531 532 533 534;
%let LPRLGbleed2         = "Gastrointestinal Bleeding";

/* Genbleed - General bleeding  */
%let LPRGenbleed             = D500 D62 D683 D698 D699 R58 T792A T792B;
%let LPRGenbleed_ICD8        = "";
%let LPRLGenbleed            = "General bleeding";

/* GIbleed - Gastrointestinal bleeding  */ /*Skal erstatte GBleed2 (ny blødningsdefinition okt 2020 - Line*/
%let LPRGIbleed             = I850 I864A K226 K228F K250 K252 K254 K256 K260 K262 K264 K266 K270 K272 K274 K276 K280 K282 K284 K286 K290 K298A K625 K638B K638C K661 K838F K868G K920 K921 K922;
%let LPRGIbleed_ICD8        = "";
%let LPRLGIbleed            = "Gastrointestinal bleeding";

/* Gout - Rheumotoid diseases */
%let LPRGout             = M16 M17;
%let LPRGout_ICD8        = "";
%let LPRLGout            = "Rheumotoid diseases";

/* Gubleed - Genitourinary bleeding  */
%let LPRGubleed             = N830A N920 N924 N938 N939 N02 R31;
%let LPRGubleed_ICD8        = "";
%let LPRLGubleed            = "Genitourinary bleeding";

/* H */
/* Halluc - Hallucinogens */
%let LPRHalluc             = F13;
%let LPRHalluc_ICD8        = 30479;
%let LPRLHalluc            = "Hallucinogens";

/* Hbleed - Haematoma bleeding  */
%let LPRHbleed             = N488D N488E N501A N501B N501C N501D N501E N831A N837 N857 N857A N897A N908D S003A S378A S601A S902A T140D T140K T810A T876D;
%let LPRHbleed_ICD8        = "";
%let LPRLHbleed            = "Haematoma bleeding";

/* HCImp - Heart or cardiac implants or crafts (brug i kombination med procedurekode */
%let LPRHCImp             = Z95;
%let LPRHCImp_ICD8        = "";
%let LPRLHCImp            = "Heart or cardiac implants or crafts";

/* Htrauma - Head trauma  */
%let LPRHtrauma             = S06 S020 S021 S027 S029 ;
%let LPRHtrauma_ICD8        = 85099 85129 852 853 854 80099 801 80399;
%let LPRLHtrauma            = "Head trauma";

/* Hemi  - Hemiplegia */
%let LPRHemi             = G81 G82;
%let LPRHemi_ICD8        = 344;
%let LPRLHemi            = "Hemiplegia";

/* HF - Heart failure */
*%let LPRhf           = I50;
*%let LPRhf_ICD8      = ;
*%let LPRLhf          = "Heart Failure";

/* HF2 - Congestive heart failure */
%let LPRhf2           = I110 I130 I132 I420 I50;
%let LPRhf2_ICD8      = 42709 42710 42711 42719 42719 42899 78249;
%let LPRLhf2          = "Congestive Heart Failure";

/* Hipfrac - Hip fracture */
%let LPRhipfrac           = S72;
%let LPRhipfrac_ICD8      = "";
%let LPRLhipfrac          = "Congestive Heart Failure";

/* Hyplip - Hyperlipidemia/hypercholesterolemia */
%let LPRhyplip           = E780 E781 E782 E784 E785;
%let LPRhyplip_ICD8      = 272 27900 27901 ;
%let LPRLhyplip          = "Hyperlipidemia/hypercholesterolemia";

/* HypLPR - Hypertension */
*%let LPRHypLPR           = I10 I11 I12 I13 I15;
*%let LPRHypLPR_ICD8      = 400 401 402 403;
*%let LPRLHypLPR          = "Hypertension";

/* hypnep - hypertensive nephropathy */
%let LPRhypnep            = I120;
%let LPRhypnep_ICD8       = 40039 403 404;
%let LPRLhypnep           = "Hypertensive nephropathy";

/* HypThy - Hyperthyroidism */
%let LPRHypThy           = E05 E06;
%let LPRHypThy_ICD8      = 24200 24208 24209 24219 24220 24228 24229;
%let LPRLHypThy          = "Hyperthyroidism";


/* I */
/* IBleed - Haemorrhagic stroke = Intercranial bleeding */
%let LPRIbleed           = I60 I61 I62;
%let LPRIbleed_ICD8      = 430 431;
%let LPRLIbleed          = "Haemorrhagic Stroke - Intercranial Bleeding";

/* Icbleed - Intracranial bleeding  *//*Skal erstatte IBleed (ny blødningsdefinition okt 2020 - Line*/
%let LPRIcbleed             = I60 I61 I62 I690 I691 I692;
%let LPRIcbleed_ICD8        = "";
%let LPRLIcbleed            = "Intracranial bleeding";

/* ihd - Ischemic heart disease */
*%let LPRihd          = I20 I21 I23 I24 I25  ;
*%let LPRihd_ICD8     = ;
*%let LPRLihd         = "Ischemic heart disease";

/* Impbleed - Bleeding in other important organ system  */
%let LPRImpbleed            = E078B E274B G951A I312 I319A I230 J942 M250 R04 S259A S368A S368B S368D T143C T144A;
%let LPRImpbleed_ICD8        = "";
%let LPRLImpbleed           = "Bleeding in other important organ system";

/* intermit - Intermittent claudication */
%let LPRintermit         = I739;
%let LPRintermit_ICD8    = 44389 44390 44391 44392 44393 44394 44395 44396 44397 44398 44399;
%let LPRLintermit        = "Intermittent claudication";

/* ISCHD - Ischemic heart disease */
%let LPRischd            = I20 I21 I22 I23 I24 I25;
%let LPRischd_ICD8         = "";
%let LPRLischd             = "Ischemic heart disease";

/* Istroke - stroke */
%let LPRIstroke          = I63 I64  ;
%let LPRIstroke_ICD8     = 43300 43309 43409 43499 43601 43690;
%let LPRLIstroke         = "Stroke";


/* L */
/* Lbleed - Bleeding in respiratory/thorax (LPR)  */
%let LPRLbleed             = J942 R04 S259A;
%let LPRLbleed_ICD8        = "";
%let LPRLLbleed            = "Bleeding in respiratory/thorax (LPR)";

/* Liver - Moderate/severe liver disease */
*%let LPRLiver            = B150 B160 B162 B190 K704 K72 K766 I85;
*%let LPRLiver_ICD8       = 07000 07002 07004 07006 07008 57300 4560;
*%let LPRLLiver           = "Moderate/Severe Liver Disease";

/* LVD */
%let LPRlvd              = I501 I509;
%let LPRlvd_ICD8         = 4271;
%let LPRLlvd             = "LVD";


/* M */
/* Mbleed3 - Extracranial or unclassified major bleeding version 3 */
%let LPRMbleed3          = D62 J942 H113 H356 H431 N02 R04 R31 R58;
%let LPRMbleed3_ICD8     = "";
%let LPRLMbleed3         = "Extracranial or unclassified major bleeding";

/* MI - Myocardial infarction I23 er efterforløb komplikationer */
%let LPRmi               = I21 I23;
%let LPRmi_ICD8          = 410;
%let LPRLmi              = "Myocardial infarction";

/* MitSten - Mitral stenosis */
%let LPRMitSten          = I05;
%let LPRMitSten_ICD8     = "";
%let LPRLMitsten         = "Mitral Stenosis";

/* mdrug - Other and multiple drugs */
%let LPRmdrug           =  F18 F19;
%let LPRmdrug_ICD8      =  30489 30499;
%let LPRLmdrug          = "Other and multiple drugs";

/* Minbleed - Other/minor bleeding  */
%let LPRMinbleed             = H922 K089A K645 N921 N950 S098A;
%let LPRMinbleed_ICD8        = "";
%let LPRLMinbleed            = "Other/minor bleeding";

/* mrenal - Mild renal impairment - proteinuria */
%let LPRMrenal           = R809;
%let LPRMrenal_ICD8      = ;
%let LPRLMrenal          = "Mild renal impairment - proteinuria";


/* N */
/* Neoplasm */
%let LPRneoplasm         = C0 C1 C2 C3 C4 C5 C6 C7 C8 C90 C91 C92 C93 C94 C95 C96;
%let LPRneoplasm_ICD8    = 14 15 16 17 18 19 200 201 202 203 204 205 206 207 208 209;
%let LPRLneoplasm        = "Neoplasm";

/* neschren - Non-end-stage chronic renal disease */
%let LPRneschren            = E102 E112 E132 E142 I120 M321B M300 M313 M319 N02 N03 N04 N05 N06 N07 n08 N11 N12 N14 N158 N159 N160 N162 N163 N164 N168 N18 N19 N26 Q612 Q613 Q615 Q619;
%let LPRneschren_ICD8       = 25002 40039 403 404 581 582 583 584 59009 59320 75310 75311 75319;
%let LPRLneschren           = "Non-end-stage chronic kidney disease";


/* O */
/* Obese Obesity */
%let LPRobese            = E65 E66;
%let LPRobese_ICD8       = 27799;
%let LPRLobese           = "Obesity";

/* obese1 - Obesity */
%let LPRobese1            = E65 E66 E68;
%let LPRobese1_ICD8       = 277;
%let LPRLobese1           = "Obesity";

/* obese2 - Obesity/Adipositas */
%let LPRobese2            = E65 E66 E67 E68;
%let LPRobese2_ICD8       = ;
%let LPRLobese2           = "Adipositas";

/* Ocbleed - Intraocular bleeding  */
%let LPROcbleed             = H052A H313 H356 H431 H450;
%let LPROcbleed_ICD8        = "";
%let LPRLOcbleed            = "Intraocular bleeding";

/* Opbleed - Peroperative and postoperative bleeding  */
%let LPROpbleed             = T810B T810C T810E T810F T810G T810H T810I T810J T810K T811A T811B T818F;
%let LPROpbleed_ICD8        = "";
%let LPRLOpbleed            = "Peroperative and postoperative bleeding";

/* opio - Opioids */
%let LPRopio            = F11;
%let LPRopio_ICD8       = 30409 30419;
%let LPRLopio           = "Opioids";

/* othcedis - Other cerebrovascular disease */
%let LPRothcedis            = I62 I65 I66 I67 I68 I69 G46;
%let LPRothcedis_ICD8       = 432 437 438;
%let LPRLothcedis           = "Other cerebrovascular disease";

/* Othdem - Other dementia */
%let LPROthdem            = F02 F03 F1073 F1173 F1273 F1373 F1473 F1573 F1673 F1873 F1973 G231 G310A G310B G311 G318B G318E G3185;
%let LPROthdem_ICD8       = 09419 29011 29012 29013 29014 29015 29016 29017 29018 29019;
%let LPRLOthdem           = "Other dementia";

/* Othstim - Other stimulants */
%let LPROthstim            = F15;
%let LPROthstim_ICD8       = 30469;
%let LPRLOthstim           = "Other stimulants";

/* P */
/* PAD - Peripheral vascular/ischemic disease */
%let LPRpad             = I70 I71 I72 I73 I74 I77;
%let LPRpad_ICD8        = 440 441 442 443 444 445;
%let LPRLpad            = "Peripheral vascular/ischemic disease";

/* PAD2 - Peripheral vascular/ischemic disease version 2 limited codes */
%let LPRpad2             = I702 I703 I704 I705 I706 I707 I708 I709 I71 I739 I74;
%let LPRpad2_ICD8        = 440 441 442 443 444 445;
%let LPRLpad2            = "Peripheral vascular/ischemic disease";

/* PAD3 - Peripheral vascular/ischemic disease version 3 for all VASc in CHADVASc */
%let LPRpad3             = I702 I703 I704 I705 I706 I707 I708 I709 I71 I739;
%let LPRpad3_ICD8        = 440 441 442 443 444 445;
%let LPRLpad3            = "Peripheral vascular/ischemic disease";

/* Pain  */
%let LPRPain             = M796;
%let LPRPain_ICD8        = "";
%let LPRLPain            = "Pain";

/* PE - Pulmonary embolism */
%let LPRpe               = I26;
%let LPRpe_ICD8          = 450;
%let LPRLpe              = "Pulmonary embolism";

/* peta - Perikardie tamponade */
%let LPRpeta               = I30 I312 I313;
%let LPRpeta_ICD8          = ;
%let LPRLpeta              = "Perikardie temponade";

/* PMIcd part of HMImp - pacemaker */
%let LPRpmicd            = Z950;
%let LPRpmicd_ICD8       = "";
%let LPRLpmicd           = "Pacemaker";

/* Pneu - Pneumonomi */
%let LPRpneu               = J12 J13 J14 J15 J16 J17 J18 A481 A709 ;
%let LPRpneu_ICD8          = ;
%let LPRLpneu              = "Pneumonomi";

/* Pneu1 - Pneumonia */
*%let LPRpneu1           = J12 J13 J14 J15 J16 J17 J18;
*%let LPRpneu1_ICD8      = 480 481 482 483 484 485 486 073 471;
*%let LPRLpneu1          = "Pneumonia";

/* polyren - Adult polycystic renal disease */
%let LPRpolyren            = Q612 Q613 Q619;
%let LPRpolyren_ICD8       = 75310 75319;
%let LPRLpolyren           = "Adult polycystic kidney disease";

/* Pregbleed - Pregnancy-related bleeding  */
%let LPRPregbleed             = O081G O208 O209 O441 O438E O469 O717 O72 O902;
%let LPRPregbleed_ICD8        = "";
%let LPRLPregbleed            = "Pregnancy-related bleeding";

/* Pregnacy  */
%let LPRpregnacy         = O0 O1 O2 O3 O4 O5 O6 O7 O8 O9;
%let LPRpregnacy_ICD8    = 63 68; /* 630-680 */
%let LPRLpregnacy        = "Pregnancy";

/* Probleed - Procedure-related bleeding (LPR)  */
%let LPRProbleed             = J950C N986;
%let LPRProbleed_ICD8        = "";
%let LPRLProbleed            = "Procedure-related bleeding (LPR)";

/* pts - post thrombotic syndrome  */
%let LPRpts             = I870;
%let LPRpts_ICD8        = "";
%let LPRLpts            = "Post thrombotic syndrome";


/* R */
/* Renal - moderate/servere renal disease */
*%let LPRrenal            = I12 I13 N00 N01 N02 N03 N04 N05 N07 N11 N14 N17 N18 N19 Q61;
*%let LPRrenal_ICD8       = 581 582 583 584 59009 59320 59321 59322;
*%let LPRLrenal           = "Moderate/severe renal disease";

/* S */
/* SE - Systemic embolism */
%let LPRse               = I74;
%let LPRse_ICD8          = 444;
%let LPRLse              = "Systemic Embolism";

/* Sedat - Sedative/hypnotics */
%let LPRsedat               = F13;
%let LPRsedat_ICD8          = 30429 30439;
%let LPRLsedat              = "Sedative/hypnotics";

/* smoke - Active smoking */
%let LPRsmoke            = Z720 F17;
%let LPRsmoke_ICD8       = "";
%let LPRLsmoke           = "Active smoking";

/* sliver - severe liver disease (FSEID00001577 t011) */
%let LPRsliver            = B150 B160 B162 B190 K704 K72 K766 I85;
%let LPRsliver_ICD8       = 07000 07002 07004 07006 07008 57300 4560;
%let LPRLsliver           = "Severe Liver Disease";

/* Stroke - stroke (FSEID00001577 t011) */
%let LPRstroke           = I61 I63 I64;
%let LPRstroke_ICD8      = 431 432 433 434;
%let LPRLstroke          = "Stroke";

/* Swel - Swelling of the limb  */
%let LPRSwel             = R600 R224 R223;
%let LPRSwe1_ICD8        = "";
%let LPRLSwel            = "Swelling of the limb";


/* T */
/*  tachy - Atrial tachycardia */
%let LPRtachy           = I471 I479;
%let LPRtachy_ICD8      = "";
%let LPRLtachy          = "Atrial tachycardia";

/* Tbleed - Traumatic CNS bleeding  *//*Skal erstatte TIBleed (ny blødningsdefinition okt 2020 - Line*/
%let LPRTbleed               = S063C S064 S065 S066 S068B S068D S141C S141D S141E S241D S241E S241F S341D S341E S341F;
%let LPRTbleed_ICD8        = "";
%let LPRLTbleed              = "Traumatic CNS bleeding";

/* TIA - Transient ischemic disease */
%let LPRtia              = G45;
%let LPRtia_ICD8         = 43509 43599;
%let LPRLtia             = "Transient ischemic disease";

/* TIBleed - Traumatic intercranial bleeding */
%let LPRTIBleed           = S063C S064 S065 S066;
%let LPRTIBleed_ICD8      = "";
%let LPRLTIBleed          = "Traumatic intercranial bleeding";

/* Tobleed - Other traumatic bleeding  */
%let LPRTobleed             = S003A S098A S259A S368A S368B S368D S378A T143C T792A T792B;
%let LPRTobleed_ICD8        = "";
%let LPRLTobleed            = "Other traumatic bleeding";

/* Trauma- Fracture/trauma */
%let LPRtrauma           = S T10 T11 T12 T13 T14;
%let LPRtrauma_ICD8      = 8 90 91 920 921 922 923 934 935 936 937 938 929 950 951 952 953 954 955 956 957 958 959 ; /* 80000-92900 remove codes < 80000 manually */
%let LPRLtrauma          = "Fracture/Trauma";

/* U */
/* UA - Unstable Angina */
%let LPRua               = I20;
%let LPRua_ICD8          = 413;
%let LPRLua              = "Unstable Angina";

/* Ulcer - Ulcer disease */
%let LPRulcer            = K221 K25 K26 K27 K28;
%let LPRulcer_ICD8       = 53091 53098 531 532 533 534;
%let LPRLulcer           = "Ulcer disease";

/* unsnep - unknown type nephropathy */
%let LPRunsnep            = N04 N18 N19 N26;
%let LPRunsnep_ICD8       = 581 584;
%let LPRLunsnep           = "Nephropathy of unknown etiology";

/* ustroke - unspecified stroke */
%let LPRustroke            = I64;
%let LPRustroke_ICD8       = 436;
%let LPRLustroke           = "Unspecified stroke";

/* UTI - Urinary tract infection (blærebetændelse) */
%let LPRUTI               = N30;
%let LPRUTI_ICD8          = ;
%let LPRLUTI              = "Urinary tract infection";


/* V */
/* Valve - mekanisk hjerteklap, bør verificeres med procedurekode som ofte ligger tidligere */
%let LPRValve            = Z952 Z953 Z954;
%let LPRValve_ICD8       = "";
%let LPRLValve           = "Mechanical Heart Valve";

/* Varice - lower extremity varicose veins  */
%let LPRVarice             = I830 I831 I832 I839;
%let LPRVarice_ICD8        = "";
%let LPRLVarice            = "Lower extremity varicose veins";

/* Vascdem - Vascular dementia  */
%let LPRVascdem             = F01;
%let LPRVascdem_ICD8        = 29309 29319;
%let LPRLVascdem            = "Vascular dementia";

%let LPRvte                 = I26 I801 I802 I803 I808 I809 I81 I822 I823 I636 I676 H348E H348F  K751 O223 O225 O229 O871 O873 O879 O882;
%let LPRLvte                = "VTE";
%let LPRvte_ICD8            = 450 45100 45108 45109 45190 45192 45199 45299 45302 45304 321 67101 67102 67103 67108 67109 67309 67319 67399;
