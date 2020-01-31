%global delimiter localDir infileName institution hashConfigDef hashConfig systemKey version;

/*
*	UNC De-identified Patient Hashing Algorithm 
*/  %let version = 2.1.4;
/*	@desc : Generates de-identified hashes of patient identifiers for de-duplication or linkage processes
*	@authors : Robert Bradford, Wonhee Yang, Kira Bradford, Ashok Krishnamurthy 
*	@contributors : Emily Pfaff, Sofia Dard
*	@input : Formatted identified patient data CSV file
*	@output : De-identified, encrypted hashes of patient identifiers
*			1. Local crosswalk file with patient identifiers and hashes
*			2. List of unique hashes
*			3. Hash Definitions
*	@changelog : 
*		11-17-16 1.0.0 : Original Release
*		06-24-19 2.0.0: Revised to include additional piece hashes
*		09-16-19 2.1.3: Revised for dynamic or paramaterized construction of hashes
*		01-31-20 2.1.4: Added additional fields for partial first and last names
*/

%let localDir = H:\Collaborative DeDup ; /* Do not include trailing Slash */
%let infileName = pplUNCtest; 	/* Do not include file extension. File must be CSV */
%let institution = UNC;
%let delimiter = |;

/* Configure Hash Settings
@hashConfig : Defines the type of hash configuration to use.
	SINGLE : Produces a single hash composed of the keys specified in hashConfigDef
	N_PLUS_1 : Uses values set in "hashKeys" to dynamically creates N plus 1 hashes (N = number of hashable identifiers in the file).
		Hash 1 = Composite hash of all permissable identifiers
		Hash 2 through (n+1) = Hash of "leave one out" identifiers
	FILE : Reads a hash definition file where any number of hashes or combinations can be defined

Permissable Identifiers
	Options : FIRST_NAME , LAST_NAME, MIDDLE_NAME, GENDER, DATE_OF_BIRTH, DATE_OF_SERVICE, STREET_ADDRESS, ZIP_CODE, SSN4, PROVIDER_ID
*/
%let hashConfig = N_PLUS_1;
/* 
	If hashConfig = SINGLE then set hashConfigDef to the space delimited list of identifiers to be used in the hash
	If hashConfig = N_MINUS_1 then set hashConfigDef to a space delimited list of identifiers.
	If hashConfig = FILE then set hashConfigDef to a has definition file located in the &infileDir
*/
%let hashConfigDef = FIRST_NAME DATE_OF_BIRTH DATE_OF_SERVICE GENDER;

* Define a system key for the patient/record to be hashed. This will not be included in the Hash or the Hash output file;
%let systemKey = PATIENT_ID;
*TO RUN THIS PROGRAM =CRTL+A, CRTL+S, F8 ;

%include "&localDir\hashMacro.sas" /nosource;
%hashController(&systemKey);





