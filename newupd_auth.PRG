clear all
nAnswer = messagebox("yes to continue, No to stop",4 + 32 + 256,"Did you run Iratime first?")
DO CASE
   CASE nAnswer = 6
     
   CASE nAnswer = 7
     
      return
ENDCASE
 
set dele on
lcrost = "\\192.168.0.6\netdrive\staffpay\timeshet\roster.csv"
lcjobs = "\\192.168.0.6\netdrive\staffpay\timeshet\thursday.txt"

IF DOW(DATE()) >= 4
	lddate = date()-dow(date())-1
ELSE
	lddate = date()-dow(date())-8
ENDIF

IF file(lcrost) and file(lcjobs)
	SET safety off
	CREATE table timetmp2 (home_dept c(6), emp_no c(6), name c(25), scd_hrs n(5,2), ;
		payrate1 n(7,4), payrate2 n(7,4), path c(4), exempt c(1), vchrs n(7,2), plhrs n(6,2),;
		skhrs n(7,2), descript c(20), jobtitle c(35), frienddate d, auth c(4), temp_dept c(6), main n(1))
	USE timetmp2 excl
	APPE from &lcrost type delimited
	GOTO top
	Dele
	PACK
	REPL all emp_no with repl("0",6-len(alltrim(emp_no))) + alltrim(emp_no), main with 1
	sele path,descript from \\192.168.1.6\netdrive\maintime\data\progjoin union;
	sele path,descript from \\192.168.0.6\netdrive\maintime\data\progjoin union;
	sele path,descript from \\adhep\netdrive\maintime\data\progjoin into cursor csrprogjoin
	sele csrprogjoin
	index on path tag path
	sele progjoin 
	use
	sele timetmp2
	set rela to path into csrprogjoin
	repl all descript with csrprogjoin.descript

secondjob = '\\192.168.0.6\netdrive\staffpay\timeshet\thursday.txt'

**11/20/2015**
create cursor secondguy (lname c(15), fname c(15), jobtitle c(40), jobcode c(4),empno n(4,0), extra c(40), home_dept c(6), location c(40), loc_code c(4), jobtitle2 c(35), jobcode2 c(3),secjpath c(4),secjtitle c(40), secjcode c(4))
create table csrthursday1 (lname c(15), fname c(15), empno n(6,0), jobtitle c(40),home_dept c(6), temp_dept c(6),  jobtitle2 c(35), nprimary n(3,0),secjpath c(4),secjtitle c(40), secjcode c(4))

SELECT secondguy
APPEND FROM &secondjob TYPE delimited with tab

**11/20/2015**
**Get all job title in from thursday.txt file (via secondguy cursor)
select secondguy
index on loc_code tag path
select timetmp2
set rela to path into secondguy
repl all jobtitle with secondguy.jobtitle

**For test only... to be removed AFTER test
**select secondguy
**set filt to lname='Alfano' &&narrow it down to one record so you can focus on that
**goto top

sele secondguy
do while ! eof()
	prevlname = lname
	prevfname = fname
	prevfile = empno
	prevdept = home_dept
	firstloop = .t.
	do while lname = prevlname and fname = prevfname and ! eof()
		if firstloop and alltrim(lname) != 'Last Name'
			sele csrthursday1
			appe blank
			**11/20/2015**
			repl lname with prevlname, fname with prevfname, empno with prevfile, home_dept with prevdept, jobtitle with secondguy.jobtitle, ;
			secjpath with secondguy.loc_code,secjtitle with secondguy.jobtitle2, secjcode with secondguy.jobcode2, nprimary with -1
			select secondguy
			firstloop = .f.
		endif
		if len(alltrim(secondguy.jobtitle2)) > 0 and alltrim(lname) != 'Last Name'
			sele csrthursday1
			appe blank
			**11/20/2015**
			repl lname with prevlname, fname with prevfname, empno with prevfile, home_dept with prevdept, temp_dept with secondguy.jobcode2, jobtitle with secondguy.jobtitle2,;
			secjpath with iif(len(alltrim(secondguy.secjtitle))=4,alltrim(secondguy.secjtitle),secondguy.loc_code),;
			secjtitle with secondguy.jobtitle2, secjcode with secondguy.jobcode2,nprimary with 0
			select secondguy
		endif
		select secondguy
		skip
	enddo
enddo
SELECT csrthursday1.*, padl(alltrim(str(csrthursday1.empno)),6,'0') AS emp_no, iif(isnull(timetmp2.scd_hrs),0,timetmp2.scd_hrs) as scd_hrs,;
	timetmp2.path,iif(len(alltrim(csrthursday1.temp_dept))=3,alltrim(csrthursday1.temp_dept),right(csrthursday1.home_dept,3)) as jobno from csrthursday1 left outer join timetmp2 on ;
	csrthursday1.empno = val(timetmp2.emp_no) and ;
	alltrim(csrthursday1.home_dept) = alltrim(timetmp2.home_dept) into table temprooster order by emp_no
select secondguy
use
	sele temprooster
	use \\192.168.0.6\netdrive\staffpay\timeshet\second_job order jobcode in 0
	set relation to jobno into second_job
	**11/20/2015**
	**repl temp_dept with second_job_sathi.costcenter + jobno, scd_hrs with 0, path with second_job_sathi.path for nprimary = 0
	repl temp_dept with second_job.costcenter + jobno, scd_hrs with 0, path with secjpath for nprimary = 0
	index on emp_No for nprimary = -1 tag emp_no
	SELE timetmp2
	set relation to emp_no into temprooster
	REPL all frienddate with LDdate+14, jobtitle with temprooster.jobtitle
select second_job
use
	sele temprooster
	set order to
****** adpRATE FILE
	ldfriday = LDDATE+14
	lcweek = alltrim(str(week(ldfriday,1,7)))
	lcweek = padl(lcweek,2,"0")
	lchrfile = "\\192.168.0.6\netdrive\staffpay\timeshet\hr"+right(alltrim(str(year(ldfriday))),2)+ "_"+lcweek+".dbf"
	lcalias = "hr"+right(alltrim(str(year(ldfriday))),2)+ "_"+lcweek
	

*********************************
	SELE * from temprooster where nprimary = 0 into cursor csrtemp
	sele emp_no,payrate1,payrate2 from timetmp2 into cursor csr

	SELE csrtemp
	GOTO top
	DO while not eof()
		lcname = alltrim(lname) +', '+fname
		lnscdhrs = 0
		lcexempt = 'N'
		lchome_dept = csrtemp.home_dept
		lctemp_dept = csrtemp.temp_dept		
		lcpath = csrtemp.path
			sele csrprogjoin
			LOCATE for path = lcpath
			IF found()
				lcdescript = descript
			ELSE
				lcdescript = space(0)
			ENDIF
			sele csr
			locate for emp_no = csrtemp.emp_no
			IF found()
				if csr.payrate2 > 0
					lnrate = csr.payrate2
				else
					lnrate = csr.payrate1
				endif
			ELSE
				lnrate = 0
			ENDIF
			
			INSERT into timetmp2 (home_dept, emp_no , name, scd_hrs, ;
				path, exempt, descript, jobtitle, frienddate, temp_dept, payrate1 );
				values (lchome_dept, csrtemp.emp_no, lcname, lnscdhrs, lcpath, lcexempt,;
				lcdescript, csrtemp.jobtitle, LDdate+14, lctemp_dept, lnrate)
		SELE csrtemp
		Skip
	ENDDO
	sele timetmp2
*!*			**11/20/2015**
*!*	**Get all job title in from thursday.txt file (via secondguy cursor)
*!*	select secondguy
*!*	index on loc_code tag path
*!*	select timetmp2
*!*	set rela to path into secondguy
*!*	repl all jobtitle with secondguy.jobtitle

*!*		select timetmp2
	SET SAFETY OFF
	copy to &lchrfile 
	SET SAFETY ON
	CLOSE ALL DATABASES
	use &lchrfile excl in 0
	sele &lcalias
	index on emp_no tag emp_no
	index on emp_no + path tag emppath
	use
**	sele timetmp2
*********************************	
	USE \\192.168.0.6\netdrive\maintime\temp\authoriz IN 0
	SELE authoriz
	Delete for frienddate <= lddate
	goto bott 
	if authoriz.frienddate < lddate+14
		APPE from timetmp2 for left(path,1) = 'A' or left(path,1) = 'H' or left(path,1) = 'V' or left(path,1) = 'C'
	endif
	USE \\192.168.1.6\netdrive\maintime\temp\authoriz 
	Delete for frienddate <= lddate
	goto bott
	if authoriz.frienddate < lddate+14
		APPE from timetmp2 for left(path,1) = 'R' or left(path,1) = 'M'  or left(path,1) = 'V'
	endif
	USE \\adhep\netdrive\maintime\temp\authoriz
	Delete for frienddate <= lddate
	goto bott
	if authoriz.frienddate < lddate+14
		APPE from timetmp2 for left(path,1) = 'E'
	endif
	use f:\cm\sqlfiles\authoriz excl
	Delete for frienddate <= lddate
	pack
	if authoriz.frienddate < lddate+14
		set safety off
		zap
		set safety on
		APPE from timetmp2 for left(path,1) = 'E'
	endif
	
**	erase \\192.168.0.6\netdrive\staffpay\timeshet\roster.csv
**	erase \\192.168.0.6\netdrive\staffpay\timeshet\thursday.txt

ELSE
	IF used("tblerror")
		SELE tblerror
		REPL css with "Files not found " + lcrost + ' or ' + lcjobs, delauthact with "N"
	ELSE
		USE data\tblerror in 0
		SELE tblerror
		APPEND blank
		REPL css with "Files not found " + lcrost + ' or ' + lcjobs, delauthact with "N"
	ENDIF
ENDIF
IF used("timetmp2")
	USE in timetmp2
ENDIF
erase timetmp2.dbf

***Bring contract workers into authoriz table at HEP
do \\adhep\netdrive\maintime\progs\copyhepcontractwkrs2authoriz.prg

