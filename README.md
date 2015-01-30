# snapparse
Scripts to help with snaplogic SaaS
This script is to help parse out what snaps are impacted by an upgrade.  You need to have all the slp (pipelines) files in a directory for the script to work.  There is another script that will parse out the export.json file created by that export function of the snap interface`

The following scripts do the following tasks
generic project parse
	1. Can download a project from snapplane
	2. Parse out the project and gives you a report on 
		1. Number of pipelines
		2. Number of tasks
		3. Number of files
		4. Snappipelines, authors (based on who moved it), which snaps are used by that pipeline
			
snapcheck
	1. parses out from the project parse and identifies which pipeslines use snaps that have been identified as being upgraded or being used.
	2. generates a report showing piplelines affected and # of them.
