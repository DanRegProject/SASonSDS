/* Operation codes, use OPR and OPRL prefix', Official codes has prefix K which is NOT omitted */


/* arrhyo */
%let OPRarrhyo	      = KFP;
%let OPRLarrhyo	      = "Heart arrhythm operation";

/* cabg */
%let OPRcabg          = KFNA KFNC KFND KFNE;
%let OPRLcabg         = "Coronary artery bypass graft";

/* chopr */
%let OPRichopr	      = KAA;
%let OPRLichopr	      = "Intra cranial procedure";

/* fn */
%let OPRfn            = KFN;
%let OPRLfn           = "Percutanious coronary intervention or coronary artery bypass craft";

/* hip */
%let OPRhip           = KNFB KNFC KNFU;
%let OPRLhip          = "Hip replacement surgery";

/* kidtra */
%let OPRkidtra        = KKAS00 KKAS10 KKAS20;
%let OPRLkidtra       = "Kidney transplant";

/* knee */
%let OPRknee          = KNGB KNGC KNGU;
%let OPRLknee         = "Knee replacement surgery";

/* Lbleedopr */
%let OPRLbleedopr	      = KGWD KGWD02 KGWE;
%let OPRLLbleedopr	      = "Bleeding in respiratory/thorax (OPR)";

/* msurg */
%let OPRmsurg       = KA KB KD KF KG KH KJ KK KL KM KN KP;
%let OPRLmsurg      = "Major surgery";

/* pci */
%let OPRpci           = KFNG;
%let OPRLpci          = "Percutanious coronary intervention";

/* Probleedopr */
%let OPRProbleedopr	      = KAAB30 KAAD00 KAAD05 KAAD10 KAAD15 KABB40 KAWD KAWD00A KAWE KBWD KBWE KCKD90 KCWD KCWE KDWD KDWE KEWD KEWE KFWD KFWE KGWD KGWD02 KGWE KHWD KHWE KJWD KJWE KKEV KKEV02 KKWD KKWE KLWD KLWE KMBC40 KMWD KMWE KNAW79 KNAW89 KNBW79 KNBW89 KNCW79 KNCW89 KNDW79 KNDW89 KNEW79 KNEW89 KNFW79 KNFW89 KNGW79 KNGW89 KNHW79 KNHW89 KPWD KPWE KQWD KQWE;
%let OPRLProbleedopr	      = "Procedure-related bleeding (OPR)";

/* Surgery - any surgery */
/*
%let OPRsurgery       = K 0 1 2 3 4 5 6 7 8 9;
%let OPRLsurgery      = "Any surgery";
*/

/* valveo */
%let OPRvalveo	      = KFG KFK KFM;
%let OPRLvalveo	      = "Heart valve operation";


/*mechvalve - mechanical valve prothesis*/
%let OPRmechvalve 		= KFGE00 KFKD00 KFJF00 KFMD00;
%let OPRLmechvalve 		= "mechanical valve prothesis";
