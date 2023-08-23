%macro getPOP(outdata, basedata);

%let globalstart = mdy(01,01,1920);

proc sql ;
  create table &outdata as
    select
    a.v_pnr_encrypted as pnr,
    a.c_kon as sex_txt, /* ændre til sex? */
	case
	    when a.c_kon = "M" then 0
            when a.c_kon = "K" then 1
	  else
		2 end
	  as sex,
      %if %varexist(raw.cpr3_t_person,d_fodaar) eq 1 %then  d_fodaar;
      %else year(d_foddato); as birthyear,
      %if %varexist(raw.cpr3_t_person,d_fodmaaned) eq 1 %then  d_fodmaaned;
      %else month(d_foddato); as birthmonth,
      %if %varexist(raw.cpr3_t_person,d_foddato) eq 1 %then  d_foddato;
      %else mdy(d_fodmaaned,15,d_fodaar);
	   as birthdate format=date., /* replace date with 15. */
      a.c_status as status,
	case
	    when a.c_status = "90" then "dead"
        when a.c_status = "80" then "out_of_country"
        when a.c_status = "01" then "active"
        when a.c_status = "03" then "active"     /* speciel vejkode */
        when a.c_status = "05" then "active"     /* bopæl i Grønlandsk folkeregister */
        when a.c_status = "07" then "active"     /* Special vejkode i Grønlandsk folkeregister */
	    when a.c_status = "70" then "not_active" /* forsvundet */
        when a.c_status = "60" then "not_active" /* ændret personnummer ved ændring af fødselsdato og køn */
        when a.c_status = "50" then "not_active" /* slettet personnummer ved dobbeltnummer */
        when a.c_status = "30" then "not_active" /* annulleret personnummer */
        when a.c_status = "20" then "not_active" /* uden bopæl i DK/Gl, pnr af skattehensyn */
	  else
        "none of the above" end
      as description,
	case
        when a.c_status = "90" then a.d_status_hen_start
	  else
        . end
      as deathdate format=date9.,
	a.d_status_hen_start as statusdate,
    %IF %sysfunc(exist(raw.Cpr3_dansk_ophold_periode_unik)) %THEN %DO;
	b.DK_ADRESSE_SLUT as inper_out_date,
	b.DK_ADRESSE_START as inper_in_date,
	b.rec_in as rec_in_ophold format=date9.,
	b.rec_out as rec_out_ophold format=date9.,
            %END;
    %ELSE %IF %sysfunc(exist(raw.cpr3_t_adresse_udland_hist)) %THEN %DO;
	b.d_udrejse_dato as out_date,
	b.d_indrejse_dato as in_date,
            %END;
        a.rec_in as rec_in_person format=date9.,
    a.rec_out as rec_out_person format=date9.

    from
%if &basedata ne %then 
&basedata c join  /* select pnr from basedata */
    raw.cpr3_t_person a on c.pnr=a.v_pnr_encrypted;
    %else raw.cpr3_t_person a;
    left join
    %IF %sysfunc(exist(raw.Cpr3_dansk_ophold_periode_unik)) %THEN %DO;
    raw.Cpr3_dansk_ophold_periode_unik b
    on
	a.v_pnr_encrypted=b.v_pnr_encrypted
    %END;
    %ELSE %IF %sysfunc(exist(raw.cpr3_t_adresse_udland_hist)) %THEN %DO;
    raw.cpr3_t_adresse_udland_hist b
    on
	a.v_pnr_encrypted=b.v_pnr_encrypted  and (b.d_udrejse_dato<b.d_indrejse_dato or b.d_indrejse_dato=.)
    %END;
	where (%if %varexist(raw.cpr3_t_person,d_foddato) eq 1 %then  d_foddato ne .;
           %else  d_fodmaaned ne . and d_fodaar ne .; )
     %IF %sysfunc(exist(raw.Cpr3_dansk_ophold_periode_unik)) %THEN %DO;
    	order by pnr, inper_in_date, inper_out_date, statusdate, rec_in_ophold;
        %END;
    %ELSE %IF %sysfunc(exist(raw.cpr3_t_adresse_udland_hist)) %THEN %DO;
	order by pnr, out_date, in_date, statusdate, rec_in_ophold;
        %END;

%sqlquit;
%mend;

