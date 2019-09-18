# DAREL
## Deidentifying All Records for Encrypted Linkages
### Overview
**DAREL** is a combination of SAS programs designed to allow for the linkage of identified patient information between organizations in a secure, encrypted manner. **DAREL** is composed of two components that allow for the responsibilities of the linkage process to be separated to allow for lower effort at sites that are not the lead:
1) Hashing Algorithm
2) Collision Algorithm


### Hashing
The intention of the hashing process is to produce a single or set of hashes that fall within the  HIPAA Privacy Rule definition for Safe Harbor data. The hashing process reads in a file containing HIPAA identifiers for a patient, combines then in a defined manner, and generates an encrypted key for those values. The encrypted key is then shareable under guidelines specified by [HIPAA Safe Harbor](https://www.hhs.gov/hipaa/for-professionals/privacy/special-topics/de-identification/index.html) and used in collision processes at another institution. This collision process can be used to deduplicate patients within a data set or to link patients between two different systems. The ability to generate multiple hashes composed of different identifiers allows for the ability to perform an encrypted probablistic match instead of the "all or nothing" approach when using a single hash.

### Collision
*Work in Progress in 2.1.x*

The collision process allows for the determination of what patients appear between different systems. The collision process is designed to run at a lead site that would receive all necessary hashes and perform the collisions. The output generated is a file that indicates what hashes occur at one or multiple sites and individual files for each site that descrive the collisions that occur. Because of the ability to generate multiple hashes through the hashing process above, users are able to weight the hashes used to provide a probability of a match between sites.


### 
