/* special cases */
/* chads2Vasc */
%let RISKLChads2Vasc = "CHA2DS2-VASc";

/* hypertension for risk calculation */
%let RISKhyp      = alfa nonloop vaso beta calcium renin;
%let RISKLhyp     = "Hypertension: (Alfa + Nonloop + Vaso + Beta + Calcium + Renin)>1";
%let RISKhypN     = %sysfunc(countw(&RISKhyp)); /* number of groups */
%let RISKhypW     = 1; /* weight of each group */

/* combination drugs - weight 2 */
%let RISKhypComp1  = C09BB04;
%let RISKLhypComp1 = "Combination of ACE inhibitors and calcium antagonists";
%let RISKhypComp2  = C09DA;
%let RISKLhypComp2 = "Combination of Angiotensin II antagonists and thiazide";
%let RISKhypComp3  = C09DB;
%let RISKLhypComp3 = "Combination of Angiotensin II receptor antagonists and calcium antagonists";
%let RISKhypComp4  = C09DX01;
%let RISKLhypComp4 = "Combination of Angiotensin II receptor antagonists, calcium antagonists and hydrochlorthiazid";
%let RISKhypComp5  = C09DX04;
%let RISKLhypComp5 = "Combination of Angiotensin II receptor antagonists and neprilysin inhibitor";
%let RISKhypComp6  = C07B;
%let RISKLhypComp6 = "Combination of beta blocker and thiazid";

%let RISKhypComp   = hypComp1 hypComp2 hypComp3 hypComp4 hypComp5 hypComp6;
%let RISKhypCompN  = %sysfunc(countw(&RISKhypComp)); /* number of combination drugs */
%let RISKLhypComp  = "Hypertension combination drugs";
%let RISKhypCompW  = 2; /* Each combination drug counts double */

/* special cases */
%let ATCchads2      = hfatc alfa nonloop vaso beta calcium renin diabatc;
%let ATCLchads2     = "CHADS2";
%let ATCcha2dsvasc  = hfatc Alfa nonloop vaso beta calcium renin diabatc;
%let ATCLcha2dsvasc = "CHA2DS2VASc";
%let ATChasbled     = alfa nonloop vaso beta calcium renin aspirin clopi nsaid;
%let ATCLhasbled    = "HAS-Bled";
