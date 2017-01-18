
# REQUACK
# REQUIREMENT-COVERAGE MAINTENANCE TOOL IN AWK
# DEC 2016
# USER FILE: req_config.txt		(declarative programming)
# RUN: gawk -f req.awk


# awk development key points

# all variables are global except for function args, which are local.
# https://www.gnu.org/software/gawk/manual/html_node/Regexp.html#Regexp
# ‘^’ does not match the beginning of a line (the point right after a ‘\n’ newline character) embedded in a string
# The ‘$’ is an anchor and does not match the end of a line (the point right before a ‘\n’ newline character) embedded in a string.
# some awk only support POSIX character classes, so \s is not matching whitespace, it's matching the letter s.



BEGIN {

	showcompleted=0
	showlowpri=0
	
	# if(test_functions()==0) exit
	
	load_configfile("req_config.txt")
	
	# visit class hierarchy
	
	print ""
	for(j in parentclass_obj) {
		visit_super(parentclass_chi[j],parentclass_chi[j],0)
	}

	print_hierarchy_and_status()

	hr="==================="
	
	print_stats()
	
	print "NON-APPLICABLE REQUIREMENTS"
	print "\t(ie no object derives from a class that these requirements are defined for)"
	print ""
	for (w in reqmt4class_reqmt) {
		if(w in reqmt4class_reqmt_visited) ; else {
			printf("%s\n",reqmt4class_class[w] "?" reqmt4class_reqmt[w])
		}
	}
	print hr
	print "IMPLEMENTED REQUIREMENTS WITH A DEPRECATED KEY"
	print "\t(ie the requirement or a class name has changed after implementation)"
	print ""
	for (k in there) {
		if(k in matchedthere) ; else if(!(k ~ /) 2/ && !showlowpri)) printf("%s\n",k)
		# if(k in matchedthere) ; else printf("%s\n",k)
	}
	print hr

	exit 0
}
	



function print_hierarchy_and_status() {
	for(rk in report_reqkey) {
		if(rk in there) { 
			rkx = ""
			thnote = "... " there[rk]
			matchedthere[rk]=1
			if(showcompleted) doshow=1; else doshow=0;
		} else {
			rkx = "TBC"
			thnote = ""
			++tbc
			doshow=1
		}
		if(doshow) {
			printf("%4d %-5s %s %s\n", ++rqnshown, rkx, rk, thnote)
		}
		++rqn
	}
}

function print_stats() {
	if(rqn>0){
		print ""
		print "stats=="
		ffmt="%-10s %5s\n"
		donepct=int((rqn-tbc)*100/rqn)
		printf(ffmt, "reqs DONE:", rqn-tbc)
		printf(ffmt, "reqs DONE%:", donepct "%")
		printf(ffmt, "reqs TBC:", tbc)
		printf(ffmt, "reqs TOT:", rqn)
		printf("\n")
		print hr
		print "showcompleted:" (showcompleted? "yes" : "no")
		print "showlowpri:" (showlowpri? "yes" : "no")
		print hr
	}
}

function parseline(r0) {
	r0=CC(r0)
	if(r0 == "")  {return 1}													# blank line
	if(r0 == "showcompleted") {showcompleted=1; return 3}						# switching showcomplete
	if(r0 == "showlowpri") {showlowpri=1; return 3}								# switching showlowpri
	operators=0
	if(index(r0,"=")>0) operators++		# this must be a {object1=class1 class2 class3} statement
	if(index(r0,":")>0) operators++		# this must be a {class1:subclass11 subclass12 subclass13} statement
	if(index(r0,"?")>0) operators++		# this must be a {class1?requirement1} statement
	if(index(r0,"!")>0) operators++		# this must be a {requirement1!implementation_notes} statement
	if(operators != 1) {print "more than one operator found in a line"; return 0}
	if(2==split(r0,kv,"=")) { t1=TT(kv[1]); t2=BB(kv[2]); update_parentclass(t1,t2,1); return 4}		# o:clist 	-> obj o is an instance of these classes
	if(2==split(r0,kv,":")) { t1=TT(kv[1]); t2=BB(kv[2]); update_parentclass(t1,t2,0); return 5}		# c:clist 	-> class c is related to these classes
	if(2==split(r0,kv,"!")) { t1=TT(kv[1]); t2=TT(kv[2]); there[t1]=t2; return 6}						# r!comment -> this requirement is implemented
	if(2==split(r0,kv,"?")) { t1=TT(kv[1]); t2=TT(kv[2]); update_reqmtclass(t1,t2); return 7}			# c?req		-> this class has got this requirement
	return 0
}



function load_configfile(fin) {
	while (getline < fin) {
		nr++
		if(parseline($0)==0) { print "ERROR on line " nr; exit}
	}
	close(fin)
}

														
function update_parentclass(t1,t2,is_t1_obj) {
	split(t2,a," ")
	for(i in a) {
		parentclass_chi[pcp]=t1 		# obj are never parents by definition
		if(is_t1_obj) parentclass_obj[pcp]=1
		parentclass_par[pcp]=a[i]
		pcp++
	}
	entc[t1]=t2;
	if(is_t1_obj) obj[t1]=t2;
}

function update_reqmtclass(t1,t2) {
	if(!(showlowpri==0 && t2 ~ /^2/)) {
		reqmt4class_class[reqn]=t1; 
		reqmt4class_reqmt[reqn]=t2; 
		reqn++; 
	}
}	
														
function visit_super( mychi, mybreadcrumbs, myi) {
	for (rq in reqmt4class_class) if(reqmt4class_class[rq] == mychi) {
		rkey = "(" mybreadcrumbs ") " reqmt4class_reqmt[rq]
		report_reqkey[rkey]=1
		reqmt4class_reqmt_visited[rq]=1
	}
	for(myi in parentclass_par) if(parentclass_chi[myi]==mychi) {
		visit_super( parentclass_par[myi], mybreadcrumbs "->" parentclass_par[myi], 0)
	}
	
}
														

#http://stackoverflow.com/questions/5209462/recursive-calls-with-awk-failing
#In AWK, all the variables you reference to in your functions are global variables. There is no such thing as "local variables".
#However, function arguments in AWK behave like local variables in the sense they are "hidden" when a nested or recursive function is called. 
#So you simply need to take all the "local variables" in your function and add them as extra arguments of your function.

# @include "test1" is also available in gawk

function TT(str) {					# trimming
	gsub(/^[[:blank:]]*/, "", str);
	gsub(/[[:blank:]]*$/, "", str);
	return str
}

function BB(s) {			# trimming and compacting the string intra-blanks ie replacing strings of blanks with one blank
	s=TT(s)
	gsub(/[[:blank:]]+/," ",s)
	return s
}

function CC(s) {			# removing the commented part of a line + trimming
	n123=index(s,"#")
	if(n123>0) s=substr(s,1,n123-1)	# line=line[1,hash)
	return TT(s)
}

function test_functions() {
	if("alpha \t beta"	!= TT("\t \t alpha \t beta \t \t")) return 0;
	if("alpha beta"		!= BB("\t \t alpha \t \t beta \t \t")) return 0;
	if("alpha" 			!= CC("\t \t alpha \t # \t beta \t \t")) return 0;
	return 1;
}

