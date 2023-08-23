/* special cases */
%include "&macropath/sas/ICD_ATC_codes/ATCriskscores.sas";

/* sæt i alfabetisk rækkefølge efter bedste evne... */
/* A */
/* Alfa - Alfa adrenic block */
%let ATCalfa             = C02A C02B C02C;
%let ATCLalfa            = "Alfa adrenic block";

/* Amio - Amiodarone */
%let ATCamio             = C01BD01;
%let ATCLamio            = "Amiodarone";

/* Antidem - Anti-dementia medication */
%let ATCantidem             = N06D;
%let ATCLantidem            = "Anti-dementia medication";

/* Apixa - Apixaban */
%let ATCapixa            = B01AF02;
%let ATCLapixa           = "Apixaban";

/* Aspirin */
%let ATCaspirin          = B01AC06;
%let ATCLAspirin         = "Aspirin";


/* B */
/* Beta - Beta blocker */
%let ATCbeta             = C07;
%let ATCLbeta            = "Beta blocker";


/* C */
/* calcium - Calcium channel blocker */
%let ATCcalcium          = C07F C08 C09BB C09DB;
%let ATCLcalcium         = "Calcium channel blocker";

/* carba - Carbamazipine */
%let ATCcarba            = N03AF01;
%let ATCLcarba           = "Carbamizipine";

/* clarit - Clarithromycin */
%let ATCclarit           = J01FA09;
%let ATCLclarit          = "Clarithromycin";

/* Clopi - Clopidogrel */
%let ATCclopi            = B01AC04;
%let ATCLclopi           = "Clopidogrel";

/* cyclo - cyclosporine */
%let ATCcyclo            = L04AD01;
%let ATCLcyclo           = "Cyclosporine";

/* D */
/* Dbgtran - Dabigatran */
%let ATCDbgtran          = B01AE07;
%let ATCLDbgtran         = "Dabigatran";

/* diabatc - Diabetes mellitus */
%let ATCdiabatc          = A10;
%let ATCLdiabatc         = "Diabetes mellitus";

/* Digoxin */
%let ATCdigoxin          = C01AA05;
%let ATCLdigoxin         = "Digoxin";

/* donep - Donepezil */
%let ATCdonep            = N06DA02;
%let ATCLdonep           = "Donepezil";

/* drone - Dronedarone */
%let ATCdrone            = C01BD07;
%let ATCLdrone           = "Dronedarone";


/* E */
/* edoxa - Edoxaban */
%let ATCedoxa            = B01AF03; /* valid from 2017 */
%let ATCLedoxa           = "Edoxaban";

/* F */
/* Fleca - Flecainid */
%let ATCfleca            = C01BC04;
%let ATCLfleca           = "Flecainid";

/* fluco - Fluconazol */
%let ATCfluco            = J02AC01;
%let ATCLfluco           = "Fluconazol";

/* Fonda - Fondaparinux */
%let ATCfonda            = B01AX05;
%let ATCLfonda           = "Fondaparinux";

/* G */
/* Galant - Galantamin */
%let ATCgalant               = N06DA04;
%let ATCLgalant              = "Galantamin";

/* GP - GPIIb/IIIa antagonists (eptifibatide) */
%let ATCgp               = B01AC16;
%let ATCLgp              = "GPIIb/IIIa antagonists (eptifibatide)";

/* H */
/* H2 - H2 receptor antagonistis */
%let ATCh2               = A02BA;
%let ATCLh2              = "H2 receptor antagonistis";

/* Heparins - Low molecular weight heparins */
%let ATCheparins         = B01AB;
%let ATCLheparins        = "Low molecular weight heparins";

/* hfatc - congestive heart failure */ /* bemærk samme som loop diuretics */
%let ATChfatc            = C03C;
%let ATCLhfatc           = "Congestive heart failure";

/* hivprot - HIV-proteasehæmmere */
%let ATChivprot               = J05AE10 J05AE08 J05AR14 J05AR15;
%let ATCLhivprot              = "HIV-protease inhibitors";


/* I */
/* Itracon - Itraconazole */
%let ATCitracon          = J02AC02;
%let ATCLitracon         = "Itraconazole";

/* Ivabrad - Ivabradin */
%let ATCivabrad          = C01EB17;
%let ATCLivabrad         = "Ivabradin";

/* J */

/* K */
/* keto - Systemic ketoconazole */
%let ATCketo             = J02AB02;
%let ATCLketo            = "Systemic ketoconazole";

/* L */
/* Loop - Loop diuretics */
%let ATCloop             = C03C C03EB;
%let ATCLloop            = "Loop diuretics";

/* M */
/* Mecil - Mecillinam */
%let ATCmecil             = J01CA08;
%let ATCLmecil            = "Mecillinam";

/* Mema - Memantin */
%let ATCmema             = N06DX01;
%let ATCLmema            = "Memantin";


/* N */
/* Nitro - Nitrofurantoin */
%let ATCnitro             = J01XE01;
%let ATCLnitro            = "Nitrofurantoin";

/* Nonloop - Non-loop diuretics C08G taget ud - findes ikke jf promedicin - rettet C03XA til C03X i 2020*/
%let ATCnonloop          = C02DA C02L C03A C03B C03D C03E C03X C07C C07D C09BA C09DA C09XA52;
%let ATCLnonloop         = "Non-loop diuretics";

/* nsaid */
%let ATCnsaid            = M01AA M01AB M01AC M01AE M01AG M01AH M01AX01  ;
%let ATCLnsaid           = "nsaid";

/* O */

/* P */
/* Persantin */
%let ATCpersantin        = B01AC07;
%let ATCLpersantin       = "Persantin";

/* Phen - Phenprocoumon */
%let ATCphen             = B01AA04;
%let ATCLphen            = "Phenprocoumon";

/* Prasugrel */
%let ATCprasu            = B01AC22;
%let ATCLprasu           = "Prasugrel";

/* Proton - Proton-pump inhibitors */
%let ATCproton           = A02BC;
%let ATCLproton          = "Proton-pump inhibitors";


/* Q */
/* Quin - Quinidine (sikkert ikke i brug) */
%let ATCquin             = C01BA01;
%let ATCLquin            = "Quinidine";


/* R */
/* Renin - Renin-angiotensin inhibitor (ARB or ACE inhibitor) */
%let ATCrenin            = C09;
%let ATCLrenin           = "Renin-angiotensin inhibitor (ARB or ACE inhibitor)";

/* Riva - Rivaroxoban */
%let ATCriva             = B01AF01;
%let ATCLriva            = "Rivaroxoban";

/* Rivast - Rivastigmin */
%let ATCrivast             = N06DA03;
%let ATCLrivast            = "Rivastigmin";

/* S */
/* Sota - Sotalol */
%let ATCsota             = C07AA07;
%let ATCLsota            = "Sotalol";

/* SSRI - Selective serotonin reuptake inhibitors (lykkepiller) */
%let ATCssri             = N06AB;
%let ATCLssri            = "Selective serotonin reuptake inhibitors";

/* Statins */
%let ATCstatins          = C10;
%let ATCLstatins         = "Statins";

/* Sulfa - Sulfamethizole */
%let ATCsulfa             = J01EB02;
%let ATCLsulfa            = "Sulfamethizole";

/* sulfin - Sulfinpyrazone */
%let ATCsulfin           = M04;
%let ATCLsulfin          = "Sulfinpyrazone";

/* syscort - Systemic corticosteroids */
%let ATCsyscort           = H02;
%let ATCLsyscort          = "Systemic corticosteroids";

/* T */
/* Tacrol - TAcrolimus */
%let ATCtacrol           = L04AD02;
%let ATCLtacrol          = "Tacrolimus";

/* Thien - Thienopyridines (clopidogel, ticagrelor, prasugrel) */ /* findes også seperate */
%let ATCthien            = B01AC04 B01AC24 B01AC22;
%let ATCLthien           = "Thienopyridines (clopidogrel, ticagrelor, prasugrel)";

/* Tica - Ticagrelor */
%let ATCtica             = B01AC24;
%let ATCLtica            = "Ticagrelor";

/* TMP - Trimethoprim */
%let ATCtmp             = J01EA01;
%let ATCLtmp            = "Trimethoprim";


/* V */
/* Vaso - Vasodilator */
%let ATCvaso             = C02DB C02DD C02DG C04 C05;
%let ATCLvaso            = "Vasodilator";

/* vera - Verapamil */
%let ATCvera             = C08DA01;
%let ATCLvera            = "Verapamil";

/* W */
/* warfarin */
%let ATCwarfarin         = B01AA03;
%let ATCLwarfarin        = "Warfarin";




