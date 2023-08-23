
%macro GetAvailableTables(lib);
proc sql;
connect to odbc as rawdata (datasrc=forskerdatabase);
create table &lib..tabeller as
select * from connection to rawdata (select * from sys.objects where
schema_id=Schema_ID('PDB00001220'))
order by name; 
disconnect from rawdata;
quit;
%mend;

/* Hent oversigten der viser hvornår tabellerne sidst blev opdateret */
/* TODO: find en måde at lave DataValidUntil baseret på datoerne i  oversigt */
%macro GetUpdateList(lib);
proc sql;
connect to odbc as rawdata (datasrc=forskerdatabase); 
create table &lib..OpdateringsOversigt as
select * from connection to rawdata (select * from PDB00001220.OpdateringsOversigt);
disconnect from rawdata;
quit;
%mend;


/* Get a list of the LMS tables with names and dates of last update */
%macro getLMSlist(lib);
  proc sql;
    connect to odbc as projdata (datasrc=forskerdatabase);
    create table &lib..LMS_FSEID00001577 as
    select * from connection to projdata (select * from sys.objects where
    schema_id=Schema_ID('FSEID00001577'))
    order by name; 
    disconnect from projdata;
  quit;
  proc sql;
    connect to odbc as projdata (datasrc=forskerdatabase);
    create table &lib..LMS_FSEID00002177 as
    select * from connection to projdata (select * from sys.objects where
    schema_id=Schema_ID('FSEID00002177'))
    order by name; 
    disconnect from projdata;
  quit;

  proc sql;
    connect to odbc as projdata (datasrc=forskerdatabase);
    create table &lib..LMS_Opdater_&LMSproject as
    select *, today() as rec_in format=date., &globalend as rec_out format=date. from connection to projdata (select * from &LMSproject..OpdateringsOversigt);
    disconnect from projdata;
  quit;
%mend;


