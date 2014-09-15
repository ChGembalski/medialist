medialist
=========

Media organisation linux script

Ein kleines Tool (shell script) mit dem<br>
media und sonstige Dateien, die in unterschiedlichen<br>
Ordnern liegen zu einer unique liste organisiert werden können.<br>
<br>
Die Liste wird im home Ordner unter .medialist abgelegt.<br>
Die Liste kann exportiert werden.<br>
Ein diff aus einer anderen Liste kann erzeugt werden,<br>
sowie ein automatisches tar.gz der fehlenden Dateien.<br>

Syntax:
medialist [arg]

h		- hilfe<br>
?		- hilfe<br>
i [path]	- first time init db
		  [path] to first scan location<br>
a [path]	- add scan [path]<br>
u		- update db
		  rescan all pathes<br>
d [otherdb]	- create diff of missing files in [otherdb]
		  needed if you use the export function<br>
e		- create data export file from diff
		  this file may get large<br>
w [dbfilename]	- export local db so you can use it on an other
		  system with diff function of this tool<br>
m [filename]	- crate a m3u playlist<br>

