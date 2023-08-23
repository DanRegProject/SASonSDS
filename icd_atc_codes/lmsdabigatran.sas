/* LMS specific (lægemiddelnavn): contraindicated drugs etc */
/* Dabigatran = dbgt */
%let LMSdrug      = Dbgt;
%let LMSLdrug     = "Dabigatran";
%let LMSspecific  = LMScdDbgt LMSphmDbt LMScuDbt;

%let LMScdDbgt    = J02AB02 L04AD01 J02AC02 L04AD02;
%let LMSLcdDbgt   = "Contraindicated drugs";
%let LMScdDbgtN   = 1;

%let LMSphmDbgt   = C01BD01 C01BD07 C08DA01 C08BA01 J01FA09;
%let LMSLphmDbgt  = "Potential hazardous medication";
%let LMSphmDbgtN  = ;

%let LMScuDbgt    = B01AA B01AC06 B01AC04 B01AC24 B01AC22 B01AB B01AX05 B01AC16 M04 M01A;
%let LMSLcuDbgt   = "Concomitant use (potential risk of increased bleeding)";
%let LMScuDbgtN   = ;
