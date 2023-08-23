/* Procedure codes, use UBE and UBEL prefix', Use full code */
/* getOPR is used to extract data, with option type=UBE */

/* A */
/* abla - Ablation */
%let UBEabla              = BFFB;
%let UBELabla             = "Ablation";

/* afliab - Atrial fibrillation ablation */
%let UBEafliab            = BFFB04;
%let UBELafliab           = "Atrial fibrillation ablation";

/* afluab - Atrial flutter ablation */
%let UBEafluab            = BFFB03;
%let UBELafluab           = "Atrial flutter ablation";

/* angio - Angiography */
%let UBEangio            = UXAG UXAC10;
%let UBELangio           = "Angiography";



/* B */

/* C */
/* ct - CT scan */
%let UBEct            = UXC;
%let UBELct           = "CT scan";

/* ctscan - CT scan head*/
%let UBEctscan            = UXCA;
%let UBELctscan           = "CT scan of the head";

/* ct1 - CT scan head*/
%let UBEct1               = UXCG UXCC;
%let UBELct1              = "CT scan";

/* ctlow - CT examination of lower extremities */
%let UBEctlow            = UXCG;
%let UBELctlow           = "CT examination of lower extremities";

/* D */
/* dialys - Dialysis */
%let UBEdialys            = BJFD;
%let UBELdialys           = "Chronic dialysis, haemo & peritoneal";

/* doppler - Doppler waveform analysis */
%let UBEdoppler            = UXUG05;
%let UBELdoppler           = "Doppler ultralyd";


/* E */
/* ec - Electrical cardioversion */
%let UBEec                = BFFA00 BFFA01 BFFA04;
%let UBELec               = "Electrical cardioversion";

/* ecco - Ultrasonography including echocardiography */
%let UBEecco                = UXUC80 UXUC81;
%let UBELecco               = "Ultrasonography including echocardiography";


/* M */
/* mrlow - MR examination of lower extremities */
%let UBEmrlow            = UXMG;
%let UBELmrlow           = "MR examination of lower extremities";

/* mrveno - MR venography */
%let UBEmrveno            = UXZ52;
%let UBELmrveno           = "MR venography";


/* P */
/* phlebo - phlebography of lower extremities */
%let UBEphlebo            = UXAG05;
%let UBELphlebo           = "phlebography of lower extremities";

/* pletys - venous plethysmography */
%let UBEpletys            = WPVST;
%let UBELpletys           = "plethysmography";

/* pm - Pacemaker */
%let UBEpm                = BFCA0 BFCA6 BFCA9;
%let UBELpm               = "Pacemaker";

/* S */
/* smosto - smoking prevention counselling */
%let UBEsmosto                = BQFT01 BQFS01;
%let UBELsmosto               = "Smoking prevention counselling";

/* smosta - Current or former smoking status */
%let UBEsmosta                = ZZP01A1A ZZP01A1B2 ZZP0020;
%let UBELsmosta               = "Current or former smoking status";

/* U */
/* Radiologiske procedurer */
%let UBEradio            = UX;
%let UBELradio           = "General radiological procedures";

/* ullow - Ultra sound examination of lower extremities */
%let UBEullow            = UXUG;
%let UBELullow           = "Ultrasound examination of lower extremities";

/* Ultra - Ultra sound examination */
%let UBEultra            = UXU;
%let UBELultra           = "Ultrasound examination";

/* V */
/* Ventperf - Ventilation-perfusion examination */
%let UBEventperf         = WLHGS;
%let UBELventperf        = "Ventilation-perfusion examination";







