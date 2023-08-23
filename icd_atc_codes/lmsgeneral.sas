/* alt generelt: stroke diabetes etc. */
%let LMSgeneral     = istroke mi diab hypA hypB hypC hypD hypE hypF hfA hfB hfC hfD;
%let LMSgeneralN    = %sysfunc(countw(&LMSgeneral));
%let LMSLgeneral    = "General indications of comorbidity";

%let LMSistroke     = B01AC06 B01AC04 B01AC30 B01AC07 C10AA;
%let LMSListroke    = "Previous stroke or transient ischemic attack";
%let LMSistrokeN    = 1;
%let LMSistrokeW    = 1;

%let LMSmi          = B01AC06 B01AC07 C10AA;
%let LMSLmi         = "Prior myocardial infarction";
%let LMSmiN         = 1;
%let LMSmiW         = 1;

%let LMSdiab        = A10;
%let LMSLdiab       = "Diabetes mellitus";
%let LMSdiabN       = 1;
%let LMSdiabW       = 1;

/* Spørg Peter om formålet med A-F */
%let LMShypA        = /*(A) */ C02A C02B CO2C;
%let LMShypB        = /*(B) */ C02DA C02L C03A C03B C03D C03E C03X C07C C07D C08G C09BA C09DA C09XA52;
%let LMShypC        = /*(C) */ C02DB C02DD C02DG C04 C05;
%let LMShypD        = /*(D) */ C07;
%let LMShypE        = /*(E) */ C07F C08 C09BB C09DB;
%let LMShypF		= /*(F) */ C09;                    
%let LMSLhyp        = "Hypertension (at least two)";
%let LMShypN        = 6;
%let LMShypW        = 2; /* weight:  at least two out of 6 */

%let LMShfA         = C03C C03AA C03AB C03DA01;
%let LMShfB         = C02DB C02DD C02DG C04 C05;
%let LMShfC         = C01AA;
%let LMShfD         = C07AB02 C07AB07 C07AG02;
%let LMSLhf         = "Heart failure";
%let LMShfN         = 4;
%let LMShfW         = 1; /* weight 1? Spørg Peter */

/* LMS specific (lægemiddelnavn): contraindicated drugs etc */
/* Dabigatran = dbgt */
%let LMSdrug      = dbgt;
%let LMSLdrug     = "Dabigatran";

%let LMSspecific  = drug cdDbgt phmDbgt cuDbgt;
%let LMSspecificN = %sysfunc(countw(&LMSspecific));
%let LMSLspecific = "Contraindications or hazardous medication when using &LMSLdrug";

%let LMScdDbgt    = J02AB02 L04AD01 J02AC02 L04AD02;
%let LMSLcdDbgt   = "Contraindicated drugs";
%let LMScdDbgtN   = 1;

%let LMSphmDbgt   = C01BD01 C01BD07 C08DA01 C08BA01 J01FA09;
%let LMSLphmDbgt  = "Potential hazardous medication";
%let LMSphmDbgtN  = 1;

%let LMScuDbgt    = B01AA B01AC06 B01AC04 B01AC24 B01AC22 B01AB B01AX05 B01AC16 M04 M01A;
%let LMSLcuDbgt   = "Concomitant use (potential risk of increased bleeding)";
%let LMScuDbgtN   = 1;
