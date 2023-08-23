/*alcorel - alcohol related diseases*/
%let lpralcorel = e244 e529a f105 f106 f107 f108 f109 g312 g621 g721 i426 k292 k70 k852 k860 l278a o354 p043;
%let lprlalcorel = "alcohol related diseases";
%let lpralcorel_ICD8        = "";


/*alco - alcohol abuse*/
%let lpralco = f100 f101 f102 f103 f104 r780 t500a t51 x65 z714 z721 z358m10 z39310 z3932 z502 z714 z721;
%let lprlalco = "alcohol abuse";
%let lpralco_ICD8        = "";

/*copd - chronic obstructive pulmonary disorder (kol)*/
%let lprcopd = j44 alal21;
%let lprlcopd = "chronic obstructive pulmonary disorder (kol)";
%let lprcopd_ICD8        = "";

/*diaplpr - diabetes mellitus*/
%let lprdiablpr = e10 e11 e12 e13 e14 h360 o240 o241 o242 o243;
%let lprldiablpr = "diabetes mellitus";
%let lprdiablpr_ICD8        = "";

/*diabcomp - diabetes with chronic complications*/
%let lprdiabcomp = e102 e103 e104 e105 e106 e107 e108 e112 e113 e114 e115 e116 e117 e118 h360;
%let lprldiabcomp = "diabetes with chronic complications";
%let lprdiabcomp_ICD8        = "";

/*dvtall - deep venous thrombosis (inclusive)*/
%let lprdvtall = i636 i676 i801 i802 i803 i808 i809 i819 i822 i823 i828 i829 o223 o229 o871 o879;
%let lprldvtall = "deep venous thrombosis (inclusive)";
%let lprdvtall_ICD8        = "";

/*dvtstr - deep venous thrombosis (exclusive)*/
%let lprdvtstr = i801 i802 i803 i808 i809;
%let lprldvtstr = "deep venous thrombosis (exclusive)";
%let lprdvtstr_ICD8        = "";

/*hf - heart failure (inclusive cardiomyopathies)*/
%let lprhf = i110 i130 i132 i420 i50 i426 i427 i429;
%let lprlhf = "heart failure (inclusive cardiomyopathies)";
%let lprhf_ICD8        = "";

/*hfstr - heart failure strict version*/
%let lprhfstr = i110 i130 i132 i420 i50;
%let lprlhfstr = "heart failure strict version";
%let lprhfstr_ICD8        = "";

/*hyplpr - hypertension*/
%let lprhyplpr = i10 i11 i12 i13 i15;
%let lprlhyplpr = "hypertension";
%let lprhyplpr_ICD8        = "";

/*ihd - ischemic heart disease*/
%let lprihd = i20 i21 i23 i24 i25;
%let lprlihd = "ischemic heart diseasen";
%let lprihd_ICD8        = "";

/*liver - clinically relevant liver disease*/
%let lprliver = b150 b160 b162 b18 b190 i85 k700 k701 k702 k703 k704 k709 k71 k72 k73 k74 k760 k766;
%let lprlliver = "clinically relevant liver disease";
%let lprliver_ICD8        = "";

/*miall - myocardial infarction*/
%let lprmiall = i21 i23 i24;
%let lprlmiall = "myocardial infarction";
%let lprmiall_ICD8        = "";

/*mistr - myocardial infarction strict version*/
%let lprmistr = i21;
%let lprlmistr = "myocardial infarction strict version";
%let lprmistr_ICD8        = "";

/*mitrheu - rheumatic mitral valve disease*/
%let lprmitrheu = i05 i080a i081a i083a;
%let lprlmitrheu = "rheumatic mitral valve disease";
%let lprmitrheu_ICD8        = "";

/*mitstenspec - mitral stenosis rheumatic and nonrheumatic*/
%let lprmitstenspec = i050 i052 i342;
%let lprlmitstenspec = "mitral stenosis rheumatic and nonrheumatic";
%let lprmitstenspec_ICD8        = "";

/*obese25 - obesity (bmi = 25)*/
%let lprobese25 =e65 e66;
%let lprlobese25 = "obesity (bmi = 25)";
%let lprobese25_ICD8        = "";

/*obese30 - obesity (bmi = 30)*/
%let lprobese30 =e660b e660c e660d e660e e660f e660g e660h;
%let lprlobese30 = "obesity (bmi = 30)";
%let lprobese30_ICD8        = "";

/*obeseall - obesity (inklusiv foelger af overvaegt anden overvaegt)*/
%let lprobeseall = e65 e66 e67 e68;
%let lprlobeseall = "obesity (inklusiv foelger af overvaegt anden overvaegt)";
%let lprobeseall_ICD8        = "";

/*padall - peripheral arterial disease*/
%let lprpadall = i70 i73 i74;
%let lprlpadall = "peripheral arterial disease";
%let lprpadall_ICD8        = "";

/*padstr - peripheral arterial ischemic disease*/
%let lprpadstr = i702 i739a i739c i74;
%let lprlpadstr = "peripheral arterial ischemic disease";
%let lprpadstr_ICD8        = "";

/*padembo - peripheral arterial thromboemboli for s2 in cha2ds2vasc*/
%let lprpadembo = i74;
%let lprlpadembo = "peripheral arterial thromboemboli for s2 in cha2ds2vasc";
%let lprpadembo_ICD8        = "";

/*padvasc - peripheral vascular/ischemic disease and aortic plague for part of vasc in cha2ds2vasc*/
%let lprpadvasc = i700 i702 i708 i709 i739;
%let lprlpadvasc = "peripheral vascular/ischemic disease and aortic plague for part of vasc in cha2ds2vasc";
%let lprpadvasc_ICD8        = "";

/*pneu - pneumonia*/
%let lprpneu = j12 j13 j14 j15 j16 j17 j18;
%let lprlpneu = "pneumonia";
%let lprpneu_ICD8        = "";

/*renalchr - chronic kidney disease*/
%let lprrenalchr = e102 e112 e142 i120 i131 i132 i150 i151 n03 n04;
%let lprlrenalchr = "chronic kidney disease";
%let lprrenalchr_ICD8        = "";

/*renal - renal disease*/
%let lprrenal = i12 i13 n00 n01 n02 n03 n04 n05 n07 n11 n14 n18 n19 q61 n17;
%let lprlrenal = "renal disease";
%let lprrenal_ICD8        = "";

/*vteall - venous thromboembolism (inclusive)*/
%let lprvteall = h348e h348f i26 i636 i676 i801 i802 i803 i808 i809 i81 i822 i823 i828 i829 o223 o225 o229 o871 o879 o873 o882 t817c t817d;
%let lprlvteall = "venous thromboembolism (inclusive)";
%let lprvteall_ICD8        = "";

/*vtestr - venous thromboembolism (exclusive)*/
%let lprvtestr = i26 i801 i802 i803 i808 i809;
%let lprlvtestr = "venous thromboembolism (exclusive)";
%let lprvtestr_ICD8        = "";
