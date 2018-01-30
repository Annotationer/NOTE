#!/bin/sh
. ~/apphome/aic_export.sh
db2 connect to $BMPDB user $BMPUSR using $BMPPWD
db2 set schema=$BMPSMA
if [ $# -ne 2 ]
then
	echo "sh 1.sh param_class xmlobject"
fi
class=$1
xmlobject=$2

###替换数据库的/n/r
##多行数据并称以行
str=`db2 -x "select id ,replace(replace(replace(o.PARAM_OBJECT,CHR(10),''),CHR(13),''),' ','') from TM_PRM_OBJECT o  where o.param_class = '${class}' and o.org = '${org}'"`

num=1
temp='param_class='${class}' -  xmlobject='${xmlobject}'\n'
for var in ${str};  
do  
	let result=$(($num%2))
	if [ ${result} == 1 ]; then 
		temp=$temp'id :'$var
	else 
		count=`echo $var | awk -F $xmlobject '{print NF-1}'`
		temp=$temp' count: '$count'\n'
	fi
	let num=$(($num+1))

done 
echo -e $temp > a.bat
echo 'check,execute cat a.bat!'
db2 connect reset



