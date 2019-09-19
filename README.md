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

### Applied Cases
The methodology within DAREL was piloted within the Carolinas Collaborative, a regional data research network across North and South Carolina. The specific use case was identifying overlap between institutions to determine the necessity of deduplicating patients when combining datasets from multiple institutions. The results of this pilot are available in the `AMIA-CI_CC_DEDUP_2018_v2.pdf` within this repository. These results were presented at the AMIA Clinical Informatics Conference in 2018.

### Academic Citations

If your group uses DAREL in support of a research project, please include the appropriate citation to help acknowledge DAREL and it's development.

#### For grant Submissions

> DAREL is a combination tools and processes to support institutions in performing deterministic linkages between healthcare systems in a deidentified, secure manner. DAREL utilizes patient identifiers common between participating sites to produce encrypted keys representing that data. The deterministic process can be performed in either a direct or probabalistic manner. DAREL was developed at the University of North Carolina is supported by the National Center for Advancing Translational Sciences (NCATS), National Institutes of Health, through Grant Award Number UL1TR002489.

#### Acknowledgement of DAREL in papers and presentations

> DAREL is a combination of tools and processes to support institutions in performing deterministic linkages between healthcare systems in a deidentified, secure manner. DAREL was developed at the University of North Carolina is supported by the National Center for Advancing Translational Sciences (NCATS), National Institutes of Health, through Grant Award Number UL1TR002489.

