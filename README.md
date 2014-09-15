medialist
=========

Media organisation linux script

Ein kleines Tool (shell script) mit dem
media und sonstige Dateien, die in unterschiedlichen
Ordnern liegen zu einer unique liste organisiert werden können.

Die Liste wird im home Ordner unter .medialist abgelegt.
Die Liste kann exportiert werden.
Ein diff aus einer anderen Liste kann erzeugt werden,
sowie ein automatisches tar.gz der fehlenden Dateien.

Syntax:
medialist [arg]

h		- hilfe
?		- hilfe
i [path]	- first time init db
		  [path] to first scan location
a [path]	- add scan [path] 
u		- update db
		  rescan all pathes
d [otherdb]	- create diff of missing files in [otherdb]
		  needed if you use the export function
e		- create data export file from diff
		  this file may get large
w [dbfilename]	- export local db so you can use it on an other
		  system with diff function of this tool
m [filename]	- crate a m3u playlist

