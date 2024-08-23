#!/bin/bash


### default setting variable
## First input value before running script
# engine dir name
KAF_ENG_DIR="kafka_2.13-3.7.0"
# solution user
SOL_USER="kafka"

# path setting
KAF_MAIN=/kafka
KAF_SRC=/kafka/src
KAF_APP=/kafka/app
KAF_DT=/kaf_data
ZOO_DT=/zoo_data
SVC_LOG=/svc_log

# unarchive file name
SET_KAFFILE="kafka_setting.tgz"

# user check now on
CHK_NOWACNT=`whoami`

# input value setting
SET_HOSTNAME=$1
SET_HOSTNUM=$2
SET_SERVERCNT=$3

### check SOL_USER exist
cat /etc/passwd | grep $SOL_USER


if [ $? != 0 ]
then
        echo ""
        echo "Check setting user : $SOL_USER"
        echo "Cannot find user"
        echo -e "Process Finish\n"
        
        exit;
fi

SOL_HOME=`cat /etc/passwd | grep $CHK_NOWACNT | awk -F ":" '{print $6}'`

### check handle user
if [ $CHK_NOWACNT != $SOL_USER ]
then
        echo -e "\nCannot run script different User"
        echo " - current user :  $CHK_NOWACNT"
        echo " - setting user : $SOL_USER"
        echo -e "Process Finish\n"

        exit;
fi


### make log file
LOG_DATE=$(date +"%Y-%m-%d")
LOG_NAME="process_kafka_setting_${LOG_DATE}"
seq_num=1

if ls ${SOL_HOME}/${LOG_NAME}_*.log 1> /dev/null
then
	seq_num=$(ls ${SOL_HOME}/${LOG_NAME}_*.log | awk -F '_' '{print $5}' | awk -F '.' '{print $1}' | sort -n | tail -1)
	seq_num=$((seq_num + 1))
fi

KAFKA_SETTING_LOG=$SOL_HOME/${LOG_NAME}_${seq_num}.log
touch $KAFKA_SETTING_LOG

echo "======================START Setting====================" | tee -a "$KAFKA_SETTING_LOG"
echo `date` | tee -a "$KAFKA_SETTING_LOG"


### check input value (total 4)

if [ e$SET_HOSTNAME = "e" ] || [ e$SET_HOSTNUM = "e" ] || [ e$SET_SERVERCNT = "e" ]
then
        echo "===================Error=================="
        echo "Input 3 valuse with space"
        echo "input 1 : broker hostname. ex) broker1, input 'broker' only"
	echo "input 2 : number of broker. ex) broker1, input '1' only"
	echo "input 3 : total configuration server total count. ex) plan to configure broker server 3, input '3' only"
        echo ""
	echo ">>>>>>>>>>> example <<<<<<<<<<<"
	echo " this server name iwill be broker1, and configure server 3ea for broker (broker1~3)"	
        echo "./kafka_def_setting.sh broker 1 3"
        echo ">>>>>>>>>>>>>>><<<<<<<<<<<<<<<<"
        echo "Finish Process" 
	echo -e "===========================================\n"
	echo " >> Input Value Check Fail" | tee -a "$KAFKA_SETTING_LOG"
	
        exit;
fi

echo ""
echo " >> Input Value Check Success" | tee -a "$KAFKA_SETTING_LOG"


### kafka setting file unarchive

CHK_LOCA=`pwd`
FIND_FILE=`find $SOL_HOME -type f -name $SET_KAFFILE | awk '{sub(/^\.\//, ""); print}'`


echo -e "\n >> Start Setting File Check\n" | tee -a "$KAFKA_SETTING_LOG"

if [ $CHK_LOCA = $SOL_HOME ]
then
       	echo -e "\nStart File unarchive\n" | tee -a "$KAFKA_SETTING_LOG"
	if [ e$FIND_FILE != e ]
        then
        	echo -e "\nStart File unarchive\n" | tee -a "$KAFKA_SETTING_LOG"
                tar -zxvf $FIND_FILE
                echo " >> Finish unarchive Success" | tee -a "$KAFKA_SETTING_LOG"
        else
                echo "Cannot Find File and unarchive"
                echo "Finish Process"
                echo " >> Cannot find file. unarchive Fail" | tee -a "$KAFKA_SETTING_LOG"
                exit;
        fi
else
        echo "Location Check First"
        echo "kafka_setting.tgz must be located $SOL_HOME"
        echo "Finish Process"
        echo " >> Starting Location Check Fail" | tee -a "$KAFKA_SETTING_LOG"
        exit;
fi


### check main dir and mapping owner

# Dir mount check
CHK_DIR1=`ls -ld $KAF_MAIN | awk '{print $NF}'`
CHK_DIR2=`ls -ld $KAF_DT | awk '{print $NF}'`
CHK_DIR3=`ls -ld $ZOO_DT | awk '{print $NF}'`
CHK_DIR4=`ls -ld $SVC_LOG | awk '{print $NF}'`

#echo $CHK_DIR1
#echo $CHK_DIR2
#echo $CHK_DIR3
#echo $CHK_DIR4

if [ $CHK_DIR1 != $KAF_MAIN ] || [ $CHK_DIR2 != $KAF_DT ] || [ $CHK_DIR3 != $ZOO_DT ] || [ $CHK_DIR4 != $SVC_LOG ]
then
	echo -e "\nCheck below main directory exist or mount appropriately"
	echo ">> /kafka, /kaf_data, /zoo_data, /svc_log"
	echo -e "Finish Process\n"
	echo " >> Directory Mount Check Fail" | tee -a "$KAFKA_SETTING_LOG"
	
        exit;
fi


echo -e "\nDir Mount Check Finish"
echo " >> Directory Mount Check Success" | tee -a "$KAFKA_SETTING_LOG" 
echo ""

## Dir owner account check
#CHK_OWN1=`ls -ld $KAF_MAIN | awk '{print $3}'`
#CHK_OWN2=`ls -ld $KAF_DT | awk '{print $3}'`
#CHK_OWN3=`ls -ld $ZOO_DT | awk '{print $3}'`
#CHK_OWN4=`ls -ld $SVC_LOG | awk '{print $3}'`

CHK_OWN1=`stat -c "%U" $KAF_MAIN`
CHK_OWN2=`stat -c "%U" $KAF_DT`
CHK_OWN3=`stat -c "%U" $ZOO_DT`
CHK_OWN4=`stat -c "%U" $SVC_LOG`


if [ $CHK_OWN1 != $SOL_USER ] || [ $CHK_OWN2 != $SOL_USER ] || [ $CHK_OWN3 != $SOL_USER ] || [ $CHK_OWN4 != $SOL_USER ]
then
        echo -e "\nCheck below main directory owner same with control account"
        echo ">> /kafka, /kaf_data, /zoo_data, /svc_log"
        echo "control account : $SOL_USER"
        echo "Finish Process"

        echo " >> Directory Owner Check Fail" | tee -a "$KAFKA_SETTING_LOG"
	
        exit;
fi


echo -e "\nDir Owner Check Finish"
echo " >> Directory Owner Check Success" | tee -a "$KAFKA_SETTING_LOG"

# Dir mode bit check
CHK_MODE1=`stat -c "%a" $KAF_MAIN`
CHK_MODE2=`stat -c "%a" $KAF_DT`
CHK_MODE3=`stat -c "%a" $ZOO_DT`
CHK_MODE4=`stat -c "%a" $SVC_LOG `

if [ $CHK_MODE1 != "755" ] || [ $CHK_MODE2 != "755" ] || [ $CHK_MODE3 != "755" ] || [ $CHK_MODE4 != "755" ]
then
        echo ""
        echo "Check below main directory mode bit 755"
        echo ">> /kafka, /kaf_data, /zoo_data, /svc_log"
        echo "Finish Process"
        echo ""
        echo " >> Directory Mode Check Fail" | tee -a "$KAFKA_SETTING_LOG"
        exit;
fi

echo ""
echo "Directory Mode Check Finish"
echo " >> Directory Mode Check Success" | tee -a "$KAFKA_SETTING_LOG"
echo ""


### Sub Dir exist check and make

# check sub dir exit under main dir
CHK_SUBDIR1=`ls -l $KAF_MAIN | awk 'NR > 1'`
CHK_SUBDIR2=`ls -l $ZOO_DT | awk 'NR > 1'`
CHK_SUBDIR3=`ls -l $SVC_LOG | awk 'NR > 1'`

if [ e$CHK_SUBDIR1 != "e" ]
then
        echo -e "\nSub Dir Create Fail : /kafka/app, /kafka/src"
        echo "Check Main Dir : ls -l /kafka"
        echo "Finish Process"
        echo " >>Sub Dir Create Fail : /kafka/app, /kafka/src" | tee -a "$KAFKA_SETTING_LOG"
        exit;
fi

echo -e "\nSub Dir Create Start: /kafka/app, /kafka/src"
mkdir -p $KAF_APP $KAF_SRC
chmod -R 755 $KAF_APP $KAF_SRC
ls -l $KAF_MAIN
echo " >> Sub Dir Create Success : /kafka/app, /kafka/src" | tee -a "$KAFKA_SETTING_LOG"


if [ e$CHK_SUBDIR2 != "e" ]
then
        echo ""
        echo "Sub Dir Create Fail : /zoo_data/snapshot /zoo_data/transdata"
        echo "Check Main Dir : ls -l /zoo_data"
        echo "Finish Process"
        echo " >>Sub Dir Create Fail : /zoo_data/snapshot /zoo_data/transdata" | tee -a "$KAFKA_SETTING_LOG"
        echo ""
        exit;
fi

mkdir -p $ZOO_DT/snapshot $ZOO_DT/transdata
chmod -R 755 $ZOO_DT/snapshot $ZOO_DT/transdata
ls -l $ZOO_DT
echo " >> Sub Dir Create Success : /zoo_data/snapshot /zoo_data/transdata" | tee -a "$KAFKA_SETTING_LOG"



if [ e$CHK_SUBDIR3 != "e" ]
then
        echo -e "\nSub Dir Create Fail : /svc_log/kaf_log /svc_log/zoo_log"
        echo "Check Main Dir : ls -l /svc_log"
        echo "Finish Process"
        echo " >>Sub Dir Create Fail : /svc_log/kaf_log /svc_log/zoo_log" | tee -a "$KAFKA_SETTING_LOG"
        exit;
fi

mkdir -p $SVC_LOG/kaf_log $SVC_LOG/zoo_log
chmod -R 755 $SVC_LOG/kaf_log $SVC_LOG/zoo_log
ls -l $SVC_LOG
echo " >> Sub Dir Create Success : /svc_log/kaf_log /svc_log/zoo_log" | tee -a "$KAFKA_SETTING_LOG"

### setting file check and copy

echo -e "\nCustom and Origin Kafka Engine File Copy Move \n" | tee -a "$KAFKA_SETTING_LOG"

# /home/soluser/kafka_setting --> /kafka or /kafka/app
cp -aR $SOL_HOME/kafka_setting/$KAF_ENG_DIR $KAF_MAIN
cp -aR $SOL_HOME/kafka_setting/configuration $KAF_APP
cp -aR $SOL_HOME/kafka_setting/env $KAF_APP
cp -aR $SOL_HOME/kafka_setting/script $KAF_APP

# engine origin file backup to /kafka/src
cp -aR $SOL_HOME/kafka_setting/$KAF_ENG_DIR $KAF_SRC

echo -e " Check File move well"

ls -ald $KAF_MAIN/* | tee -a "$KAFKA_SETTING_LOG"
ls -ald $KAF_APP/* | tee -a "$KAFKA_SETTING_LOG"
ls -ald $KAF_SRC/* | tee -a "$KAFKA_SETTING_LOG"

echo ""
echo " >> Dir Copy Move Finish : /kafka/$KAF_ENG_DIR, /kafka/app/~" | tee -a "$KAFKA_SETTING_LOG"
echo ""


echo -e "\nkafka config properties copy\n" | tee -a "$KAFKA_SETTING_LOG"

cp -a $KAF_MAIN/$KAF_ENG_DIR/config/server.properties $KAF_APP/configuration/server.properties_org
cp -a $KAF_MAIN/$KAF_ENG_DIR/config/zookeeper.properties $KAF_APP/configuration/zookeeper.properties_org

CHK_MODISET=`ls -l $KAF_APP/configuration/*modiset | wc -l`

if [ $CHK_MODISET != 2 ]
then
	
	echo " >> Configuration Setting File Missing" | tee -a "$KAFKA_SETTING_LOG"
	echo "Process Finish"
	exit;
else
	mv $KAF_APP/configuration/server.properties_modiset $KAF_APP/configuration/server.properties
	mv $KAF_APP/configuration/zookeeper.properties_modiset $KAF_APP/configuration/zookeeper.properties

fi

ls -l $KAF_APP/configuration/server.properties*
ls -l $KAF_APP/configuration/zookeeper.properties*


echo " >> kafka config properties copy Success" | tee -a "$KAFKA_SETTING_LOG"

echo "Start File Modify : server.properties" | tee -a "$KAFKA_SETTING_LOG"

. $SOL_HOME/kafka_setting/modify_property_broker.sh

echo "Finish File Modify : server.properties" | tee -a "$KAFKA_SETTING_LOG"
echo "-------------------------------------------------"

echo "Start File Modify : zookeeper.properties" | tee -a "$KAFKA_SETTING_LOG"

. $SOL_HOME/kafka_setting/modify_property_zookeeper.sh

echo "Finish File Modify : zookeeper.properties" | tee -a "$KAFKA_SETTING_LOG"
echo "-------------------------------------------------"


echo -e "\nStart create myid File for zookeeper" | tee -a "$KAFKA_SETTING_LOG"
echo $SET_HOSTNUM > $ZOO_DT/snapshot/myid

echo -e "Finish create myid file for zookeeper" | tee -a "$KAFKA_SETTING_LOG"
ls -l $ZOO_DT/snapshot/
cat $ZOO_DT/snapshot/myid


echo -e "\nStart $SOL_USER bash_profile edit" | tee -a "$KAFKA_SETTING_LOG"
CP_FILE=$SOL_HOME/kafka_setting/alias

cat "$CP_FILE" >> $SOL_HOME/.bash_profile
cat $SOL_HOME/.bash_profile
. $SOL_HOME/.bash_profile 

echo -e "\nFinish $SOL_USER bash_profile edit " | tee -a "$KAFKA_SETTING_LOG"

echo `date` | tee -a "$KAFKA_SETTING_LOG"
echo -e "\n======================Finish Setting=====================" | tee -a "$KAFKA_SETTING_LOG"

