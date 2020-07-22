/*
*	UNC De-identified Patient Hashing Algorithm
*	@changelog : 
*		11-17-16 : Original Release
*		06-24-19 : Revised to include additional piece hashes
*		09-16-19 : Revised for dynamic or paramaterized construction of hashes
*		01-31-20 : Added additional fields for partial first and last names
*/
%global hash_keys;

%macro createHashDefinitionTable();
	data HashFieldDefinitions;
		length HASH_FIELD $50 HASH_LENGTH $50 HASH_INFORMAT $50 HASH_FORMAT $50 HASH_VALID 5;
	%if &hashConfig ne FILE %then %do;
		data HashDefinitions;
			length ID 5 HASH_ID $50 HASH_ENTITIES $200;
	%end;
%mend;

%macro hashFieldDefinition(hashField);
	%local len form inform valid values;
	%let valid = FALSE;
	
	%if &hashField eq FIRST_NAME %then %do;
		%let values = %str(('FIRST_NAME','$10.','$10.','$10.',10));
		%let valid = TRUE;
		proc sql;
			select 'Y' into :has_First from sashelp.class (obs=1);
		run;
	%end;
	%else %if &hashField eq LAST_NAME %then %do;
		%let values = %str(('LAST_NAME','$20.','$20.','$20.',10));
		%let valid = TRUE;
		proc sql;
			select 'Y' into :has_last from sashelp.class (obs=1);
		run;
	%end;
	%else %if &hashField eq MIDDLE_NAME %then %do;
		%let values = %str(('MIDDLE_NAME','$1.','$1.','$1.',1));
		%let valid = TRUE;
		proc sql;
			select 'Y' into :has_mid from sashelp.class (obs=1);
		run;
	%end;
	%else %if &hashField eq DATE_OF_SERVICE %then %do;
		%let values = %str(('DATE_OF_SERVICE','$10.','$10.','$10.',10));
		%let valid = TRUE;
	%end;
	%else %if &hashField eq MONTH_OF_SERVICE %then %do;
		%let values = %str(('MONTH_OF_SERVICE','$2.','$2.','$2.',2));
		%let valid = TRUE;
	%end;
	%else %if &hashField eq YEAR_OF_SERVICE %then %do;
		%let values = %str(('YEAR_OF_SERVICE','$4.','$4.','$4.',4));
		%let valid = TRUE;
	%end;
	%else %if &hashField eq DATE_OF_BIRTH %then %do;
		%let values = %str(('DATE_OF_BIRTH','$10.','$10.','$10.',10));
		%let valid = TRUE;
	%end;
	%else %if &hashField eq MONTH_OF_BIRTH %then %do;
		%let values = %str(('MONTH_OF_BIRTH','$2.','$2.','$2.',2));
		%let valid = TRUE;
	%end;
	%else %if &hashField eq YEAR_OF_BIRTH %then %do;
		%let values = %str(('YEAR_OF_BIRTH','$4.','$4.','$4.',4));
		%let valid = TRUE;
	%end;
	%else %if &hashField eq GENDER %then %do;
		%let values = %str(('GENDER','$1.','$1.','$1.',1));
		%let valid = TRUE;
	%end;
	%else %if &hashField eq PROVIDER_ID %then %do;
		%let values = %str(('PROVIDER_ID','$15.','$15.','$15.',15));
		%let valid = TRUE;
	%end;
	%else %if &hashField eq SSN4 %then %do;
		%let values = %str(('SSN4','$4.','$4.','$4.',4));
		%let valid = TRUE;
	%end;
	%else %if &hashField eq STREET_ADDRESS %then %do;
		%let values = %str(('STREET_ADDRESS','$50.','$50.','$50.',50));
		%let valid = TRUE;
	%end;
	%else %if &hashField eq ZIP_CODE %then %do;
		%let values = %str(('ZIP_CODE','$5.','$5.','$5.',5));
		%let valid = TRUE;
	%end;
	%else %if &hashField eq FIRST_NAME_FIRST3 %then %do;
		%let values = %str(('FIRST_NAME_FIRST3','$3.','$3.','$3.',3));
		%let valid = TRUE;
	%end;
	%else %if &hashField eq LAST_NAME_FIRST8 %then %do;
		%let values = %str(('LAST_NAME_FIRST8','$8.','$8.','$8.',8));
		%let valid = TRUE;
	%end;
	%else %if &hashField eq MULTI_PURPOSE_ID %then %do;
		%let values = %str(('MULTI_PURPOSE_ID','$20.','$20.','$20.',20));
		%let valid = TRUE;
	%end;
	%if &valid eq TRUE %then %do;
		proc sql;
			insert into HashFieldDefinitions (HASH_FIELD , HASH_LENGTH , HASH_INFORMAT , HASH_FORMAT, HASH_VALID) VALUES &values.;
		run;
	%end;
%mend;

%macro hashFieldValidator(value, field_name);
	%local valid_val;
	proc sql;
		select HASH_VALID into :n_valid_l
		from HashFieldDefinitions
		where HASH_FIELD = '&field_name.';
	run;
	%if %sysfunc(lengthn(&value))>10 %then %do;
		%let valid_val=%sysfunc(lowcase(substrn(trim(compress(&value,,'s')),1,10)));
	%end;
	%else %do;
		%let valid_val=%sysfunc(lowcase(trim(compress(&value,,'s'))));
	%end;
	proc sql;
		select VALID_VAL into :curr_hush_val from sashelp.class (obs=1);
	run;
%mend;

%macro HIPAAFileBuilder(data_fields);
	%local hash_len hash_inf hash_form data_length data_inf data_form data_input;
	%let data_length = length;
	%let data_inf = informat;
	%let data_form = format;
	%let data_input = input;
	%let hash_val_n = %sysfunc(countw(&data_fields));
	%put &hash_val_n;
	%if %length(&systemKey) gt 0 %then %do;
		%put System Key Defined : &systemKey;
		%let data_length = %sysfunc(catx(%str( ), &data_length, &systemKey, $100.));
		%let data_inf = %sysfunc(catx(%str( ), &data_inf, &systemKey, $100.));
		%let data_form = %sysfunc(catx(%str( ),&data_form, &systemKey, $100.));
		%let data_input = %sysfunc(catx(%str( ),&data_input, &systemKey, $));
	%end;
	%do i=1 %to &hash_val_n;
    	%let field = %upcase(%scan(&data_fields,&i));
		proc sql;
			select trim(HASH_LENGTH) , trim(HASH_INFORMAT) , trim(HASH_FORMAT)
				into :hash_len , :hash_inf , :hash_form
			from HashFieldDefinitions
			where HASH_FIELD = "&field.";
		run;
		%if %length(&hash_len) gt 0 %then %do;
			%let data_length = %sysfunc(catx(%str( ), &data_length, &field, &hash_len));
			%let data_inf = %sysfunc(catx(%str( ), &data_inf, &field, %trim(&hash_inf)));
			%let data_form = %sysfunc(catx(%str( ),&data_form, &field, %trim(&hash_form)));
			%let data_input = %sysfunc(catx(%str( ),&data_input, &field, $));
		%end;
	%end;
	%put &data_length;
	%put &data_inf;
	%put &data_form;
	%put &data_input;

	data RawDataInput;
		&data_length.;
		infile  "&localDir\in\&infileName..csv" delimiter = "&delimiter." MISSOVER DSD lrecl=32767 firstobs=2 ;
		&data_inf.;
		&data_form.;
		&data_input.;
		if _ERROR_ then call symputx("_EFIERR_",1); 
	run;
%mend;

%macro hashBuilder(data_fields);
	%local n_hashes /* Number of hashes that are defined */
			n_fields /*Number of hash fields */
			n_iters 
			n_length /* Full length statement for the given data step */
			n_informat /* Full informat statement for the given data step */
			n_format /* Full format statement for the given data step */
			n_rename /* Full rename statement for the given data step */
			n_data /* Full data logic for the data step*/
			n_drop 
			n_drop_hipaa
			n_drop_before
			n_data_before 
			n_data_hash 
			t_valid_l /* Given fields valid length */
			t_length  /* Given fields valid length in SAS format */
			t_informat /* Given fields valid informat in SAS format */
			t_format; /* Given fields valid format in SAS format */

	%let n_length = length;
	%let n_informat = informat;
	%let n_format = format;
	%let n_rename = rename;
	%let n_data = %str( );
	
	/* Build the length, informat, format, rename and drop statements for the hash fields */
	%do i=1 %to &hash_val_n;
    	%let field = %upcase(%scan(&data_fields,&i));
		%put &field - &i / &hash_val_n;
		proc sql;
			select HASH_LENGTH , HASH_INFORMAT , HASH_FORMAT, HASH_VALID into :t_length, :t_informat, :t_format, :t_valid_l
			from HashFieldDefinitions
			where HASH_FIELD = "&field.";
		run;
		%put &t_length, &t_informat, &t_format, &t_valid_l;
		%let t_substr = %sysfunc(cats(&field,_SUBSTR)); *Temp value to hold the name of the new substringd value ;
		%let n_length = %sysfunc(catx(%str( ), &n_length ,%str(&t_substr &t_length))); *Add temp substr variable and valid length to the length statement ;
		%let n_data = %sysfunc(cats(&n_data, &t_substr,%str(=lowcase(substrn(trim(&field),1,&t_valid_l));))); *Add the data definition for the substr to the data var ;
		%let n_informat = %sysfunc(catx(%str( ), &n_informat ,%str(&t_substr &t_informat))); 
		%let n_format =  %sysfunc(catx(%str( ), &n_format, %str(&t_substr &t_format)));
		%let n_rename =  %sysfunc(catx(%str( ), &n_rename, "&t_substr=&field")); *Rename the substr temp field to the full hash field ;
		%let n_drop = %sysfunc(catx(%str( ), &n_drop, %str(&field))); *Drop the original Hash Field ;;
	%end;
	%let n_drop_hipaa = %str(&n_drop);

    data HashReadyData;
		set RawDataInput;
		
		&n_length%str(;)
		&n_format%str(;)
		&n_data
		drop &n_drop%str(;)
		%sysfunc(compress(&n_rename,'"'));%str(;)
	run;
	
	proc sql;
		select count(*) into :n_hashes from HashDefinitions where ID > 0;
	run;
	proc sql;
		select count(*) into :n_fields from HashFieldDefinitions where length(HASH_FIELD) > 0;
	run;
	
	%let n_length = length; *reset the n_length variable for new data step;
	%let n_format = format; *reset the n_format variable for new data step;
	%let n_retain = retain; *reset the n_retain variable for new data step;
	%let n_drop = drop; *reset the n_drop variable for new data step;
	%let n_data_before = %str( );

	*If a systemKey is defined, add it to the list of things to make sure we keep;
	%if %length(&systemKey) gt 0 %then %do;
		%put System Key Defined : &systemKey;
		%let n_retain = %sysfunc(catx(%str( ), &n_retain, %str(&systemKey)));
		%let n_drop_hipaa = %sysfunc(catx(%str( ), &n_drop_hipaa, %str(&systemKey)));
	%end;
	
	/* Iterate through the hash definitions to build them */
	%do i=1 %to &n_hashes;
		%put N_HASHES : &i / &n_hashes;
		%local temp_hash temp_before;
		%let temp_before = %str( );
		proc sql;
			select HASH_ENTITIES into :temp_hash from HashDefinitions where ID=&i;
		run;
	
		%let n_length = %sysfunc(catx(%str( ), &n_length, %str(before_hash_&i $500 hash_value_&i $64)));
		%let n_format = %sysfunc(catx(%str( ), &n_format, %str(hash_value_&i $hex64.)));
		
		%let inner_fact = %sysfunc(countw(&temp_hash));

		%put Building Hash With Fields : &temp_hash;
		%put Number of entities : &inner_fact;

		%do k=1 %to &inner_fact;
			%put Inner Loop of Hash Fields : &k / &inner_fact of hash &temp_hash;
			%let temp2 = %scan(&temp_hash, &k);
			%let temp_before = %str(&temp_before, &temp2);
		%end;

		%put &temp_before;
		%let temp_before = %sysfunc(substr(&temp_before,3));
		%put After Substr : &temp_before;
 		%let n_data_before = %sysfunc(catx(%str( ), &n_data_before, %str(before_hash_&i = catx('|',%str(&temp_before));)));
		%let n_data_hash = %sysfunc(catx(%str( ), &n_data_hash, %str(hash_value_&i = sha256(before_hash_&i);)));
		%let n_drop_before = %sysfunc(catx(%str( ), &n_drop_before, %str(before_hash_&i)));
		
	%end;
	%put N_RETAIN : &n_retain;
	%put N_FORMAT : &n_format;
	%put N_LENGTH : &n_length;
	%put N_DATA_BEFORE : &n_data_before;
	%put N_DATA_HASH : &n_data_hash;

	data HashWithData;
		set HashReadyData;
		&n_retain %str(;)
		&n_length %str(;)
		&n_format %str(;)	
		&n_data_before
		&n_data_hash
	run;
	
	data HashOnly;
		set HashWithData;
		drop &n_drop_before &n_drop_hipaa;

%mend ;

%macro hashFileGenerator();
	proc export data=HashOnly  
		outfile= "&localDir\out\&institution._HashOnly_&infileName..csv" 
		dbms=csv replace ;
		putnames=yes;
	run;
	proc export data=HashWithData  
		outfile= "&localDir\out\&institution._HIPAA_&infileName..csv" 
		dbms=csv replace ;
		putnames=yes;
	run;
	proc export data=HashDefinitions  
		outfile= "&localDir\out\&institution._HashDefinitions_&infileName..csv" 
		dbms=csv replace ;
		putnames=yes;
	run;
%mend;

%macro garbageCollect(library, dataset);
	/* Cleanup Data */
	proc datasets library=&library.;
   		delete &dataset.;
	run;
%mend;

%macro readHashConfig();
	%put Reading Hash Definition File : &hashConfigDef;
	data HashDefinitions;
		length HASH_ID $50 HASH_ENTITIES $200;
		infile  "&localDir\in\&hashConfigDef..csv" delimiter = "&delimiter." MISSOVER DSD lrecl=32767 firstobs=2;
		informat HASH_ID $50. HASH_ENTITIES $200.;
		format HASH_ID $50. HASH_ENTITIES $200.;
		input HASH_ID $ HASH_ENTITIES $;
	run;
	data HashDefinitions;
		set HashDefinitions;
		length ID 5 HASH_ID $50 HASH_ENTITIES $200;
		ID = _N_;
	run;
	proc sql;
		select HASH_ENTITIES into :hash_keys from HashDefinitions where HASH_ID = 'ALL';
	run;
%mend;

%macro initialize();
	%let runDate = &SYSDATE;
	dm "log; clear; ";
	proc printto log="&localDir\out\&institution._HASH_&runDate..txt" NEW;
	run;
	%put @VERSION : &version;
	%put INITIALIZING...;
	options nodate pageno=1 mergenoby=warn ls=72 formchar="|----|+|---+=|-/\<>*";
	%createHashDefinitionTable();
	%put INITIALIZATION COMPLETE;
%mend;

%macro cleanup();
	%garbageCollect(WORK, HashFieldDefinitions);
	%garbageCollect(WORK, HashDefinitions);
	%garbageCollect(WORK, RawDataInput);
	%garbageCollect(WORK, HashReadyData);
	%garbageCollect(WORK, DataWithHash);
	%garbageCollect(WORK, HashWithData);
	%garbageCollect(WORK, HashOnly);
%mend;

%macro hashController(record_key);
	%put Starting UNC Hashing for De-Identified Linkage Program...;
	%initialize();

	%if %upcase(&hashConfig) eq FILE %then %do;
		%readHashConfig();
	%end;
	%else %do;
		proc sql;
			insert into HashDefinitions (ID, HASH_ID, HASH_ENTITIES) values (1, 'ALL', "&hashConfigDef.");
		run;
		proc sql;
			select HASH_ENTITIES into :hash_keys from HashDefinitions where HASH_ID='ALL';
		run;
	%end;
	
	%let hash_val_n = %sysfunc(countw(&hash_keys));

	%if %upcase(&hashConfig) eq N_PLUS_1 %then %do;
		%do i=1 %to &hash_val_n;
			%let n = %eval(&i + 1);
			%let temp = %scan(&hash_keys, &i);
			%let trans_temp = %sysfunc(tranwrd(&hash_keys, &temp, %str( )));
			%put values (&n, 'H&i.', "&trans_temp.");
			proc sql;
				insert into HashDefinitions (ID, HASH_ID, HASH_ENTITIES) values (&n, "H&i.", "&trans_temp.");
			run;
		%end;
	%end;

	%let hash_val_n = %sysfunc(countw(&hash_keys)); 
	%put &hash_val_n;

	%do i=1 %to &hash_val_n;
    	%let field = %upcase(%scan(&hash_keys,&i));
		%hashFieldDefinition(&field);
	%end;
	%HIPAAFileBuilder(&hash_keys);
	%hashBuilder(&hash_keys);
	%hashFileGenerator();
	%cleanup();
%mend;
