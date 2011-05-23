#!/bin/sh

THISIP=`/sbin/ifconfig eth0 | grep 'inet addr' | sed 's/.*addr:\(.*\)\(  Bcast.*\)/\1/'`
. ~/.bash_profile
fullcmd=`readlink -f $0`
fullfod=${fullcmd%/*}
fullfod=${fullfod##*/}

cd `pwd`

[ -f build.config.mk   ] || ln -s $fullfod/config_jazz2.daily.mk build.config.mk
[ -f build.rules.mk    ] || ln -s $fullfod/config_jazz2.rules.mk build.rules.mk
[ -f Makefile          ] || ln -s $fullfod/Makefile.mk           Makefile
[ -f newbuild.sh       ] || ln -s $fullfod/newbuild.sh           newbuild.sh
[ -f html_generate.cgi ] || ln -s $fullfod/html_generate.cgi     html_generate.cgi

modules="xxx"
modules_jump="
devtools 
kernela2632 kernel kernelnand vivante hdmi
uboot jtag diag c2_goodies 
sw_media qt470 c2box 
facudisk usrudisk
xxx"
steps="help"
steps_jump="
src_get
src_package
src_install
src_config
src_build
bin_package
bin_install
"

DATE=`date +%y%m%d`

#wor folder settings
PKG_DIR=`make PKG_DIR`
DIST_DIR=`pwd`/log
log=${DIST_DIR}/$DATE.log
indexlog=${DIST_DIR}/$DATE.txt
mkdir -p  ${DIST_DIR}/$DATE ${DIST_DIR}/$DATE.log
[ -h $DIST_DIR/l ] && rm $DIST_DIR/l
[ -h $DIST_DIR/r ] && rm $DIST_DIR/r
[ -h $DIST_DIR/i ] && rm $DIST_DIR/i
ln -s $DIST_DIR/$DATE      $DIST_DIR/i
ln -s $DIST_DIR/$DATE.log  $DIST_DIR/l
ln -s $DIST_DIR/$DATE.txt  $DIST_DIR/r
make  mktest >$log/mktest.log
make  help   >$log/help.log
make  sdk_folders
make  backup

#these 4 exports are used by html_generate.cgi
export SDK_TARGET_ARCH=`make SDK_TARGET_ARCH`
export TREE_PREFIX=dev
export SDK_RESULTS_DIR=$DIST_DIR/
export SDK_CVS_USER=`echo $CVSROOT | sed 's/:/ /g' | sed 's/\@/ /g' | awk '{print $2}'`
[ $SDK_CVS_USER ] || export SDK_CVS_USER=`whoami`

#web server folder settings
WWW_SERVER=${THISIP}
WWW_HTTPHEAD=http
WWW_ROOT=/var/www/html/$USER
WWW_LOGDIR=${SDK_TARGET_ARCH}_${TREE_PREFIX}_logs/$DATE.log
WWW_TITLE="-${TREE_PREFIX} SDK android-gcc-kernel daily Build Results"
HTML_REPORT=${SDK_TARGET_ARCH}_${TREE_PREFIX}_gcc_kernela2632_sdk_daily.html
SSH_SERVER=10.16.13.200
SSH_SCPDIR=/home/$USER/sdkdailybuild/$SDK_TARGET_ARCH/$TREE_PREFIX/weekly/$DATE
##  cron debug message code, these setting does not pass to Makefile
#----------------------------------------------------------------------
#export MISSION=`echo $0 | sed 's:.*/\(.*\):\1:'`
export MISSION=${0##*/}
export rlog=$HOME/rlog/rlog.$MISSION
recho()
{
    #progress echo, for debug during run as the crontab task.
    if [ ! -z "$rlog" ] ; then
    echo `date +"%Y-%m-%d %H:%M:%S"` " $@" >>$rlog.log.txt
    fi
    echo `date +"%Y-%m-%d %H:%M:%S"` " $@"
}
update_indexlog()
{
    #handle echo "Hdmi:1:$hdmilog">>$indexlog
    #to : update_indexlog "Devtools:1:$devtoolslog" $indexlog
    m=`echo $1 | sed 's,\([^:]*\).*,\1,'`
    x=`echo $1 | sed 's,[^:]*:\([^:]*\).*,\1,'`
    f=`echo $1 | sed 's,[^:]*:[^:]*:\([^:]*\).*,\1,'`
    l=`echo $f | sed 's:.*/\(.*\):\1:'`

    has=
    [ -f $2 ] && has=`grep ^$m: $2`
    if [ $has ];then
        sed -i "s,$m:.*,$1,g" $2
        recho "debug: $2 find $m and replaced $m:$x "
    else
        echo "$1" >>$2
        recho "debug: $2 not find $m, appended: $1"
    fi

    #create blame system
    if [ "$x" != "0" ]; then
        mkdir -p ${DIST_DIR}/$DATE/blame
        BLAME=${DIST_DIR}/$DATE/blame/$DATE-$m-${SDK_TARGET_ARCH}-${TREE_PREFIX}.log
        [ -f $BLAME ] || ln -s ${WWW_ROOT}/${WWW_LOGDIR}/$l  $BLAME;
    fi
}

addto_send()
{
    while [ $# -gt 0 ] ; do
        email=$1
        x=`echo $1 | grep "@"`
        if [ $? -ne 0 ]; then
            email=${email}@c2micro.com
        fi
        if [ "$SENDTO" = "" ]; then
            SENDTO=$email ;
        else
          r=`echo $SENDTO | grep $email`
          if [ "$r" = "" ]; then
            SENDTO=$SENDTO,$email ;
          fi
        fi
        shift
    done
    export SENDTO
}
addto_cc()
{
    while [ $# -gt 0 ] ; do
        email=$1
        x=`echo $1 | grep "@"`
        if [ $? -ne 0 ]; then
            email=${email}@c2micro.com
        fi
        if [ "$CCTO" = "" ]; then
            CCTO=$email ;
        else
          r=`echo $CCTO | grep $email`
          if [ "$r" = "" ]; then
            CCTO=$CCTO,$email ;
          fi
        fi
        shift
    done
    export CCTO
}
addto_fail()
{
    while [ $# -gt 0 ] ; do
        if [ "$FAILLIST" = "" ]; then
            FAILLIST=$1 ;
        else
          r=`echo $FAILLIST | grep $1`
          if [ "$r" = "" ]; then
            FAILLIST=$FAILLIST,$1 ;
          fi
        fi
        shift
    done
    export FAILLIST
}
addto_reportedfail()
{
    while [ $# -gt 0 ] ; do
        if [ "$REPORTEDFAILLIST" = "" ]; then
            REPORTEDFAILLIST=$1 ;
        else
          r=`echo $REPORTEDFAILLIST | grep $1`
          if [ "$r" = "" ]; then
            REPORTEDFAILLIST=$REPORTEDFAILLIST,$1 ;
          fi
        fi
        shift
    done
    export REPORTEDFAILLIST
}
recho_time_consumed()
{
    tm_b=`date +%s`
    tm_c=$((tm_b-$1))
    tm_h=$((tm_c/3600))
    tm_m=$((tm_c/60))
    tm_m=$((tm_m%60))
    tm_s=$((tm_c%60))
    shift
    echo "$@" "$tm_c seconds / $tm_h:$tm_m:$tm_s consumed."
}

blame_devtools="saladwang hguo"
blame_sw_media="jliu fzhang czheng kkuang summychen weli thang bcang lji qunyingli  codec_sw"
blame_qt="mxia dashanzhou txiang slu jzhang                                         sw_apps"
blame_c2box="mxia dashanzhou txiang slu jzhang                                      sw_apps"
blame_jtag="jsun"
blame_c2_goodies="jsun robinlee ali"
blame_diag="jsun"
blame_kernel="jsun robinlee ali roger llian simongao xingeng swine hguo janetliu    sys_sw"
blame_vivante="llian jsun"
blame_hdmi="jsun xingeng"
blame_uboot="ali jsun robinlee"
blame_facudisk="hguo"
blame_usrudisk="hguo"
blame_xxx="hguo"

checkadd_fail_send_list()
{
    #pickup the fail log's tail to email for a quick preview
    loglist=`cat $indexlog`
    nr_failmodule=0
    for i in $loglist ; do
        m=`echo $i | sed 's,\([^:]*\).*,\1,'`
        x=`echo $i | sed 's,[^:]*:\([^:]*\).*,\1,'`
        f=`echo $i | sed 's,[^:]*:[^:]*:\([^:]*\).*,\1,'`
        l=`echo $f | sed 's:.*/\(.*\):\1:'`
        if [ $x -ne 0 ]; then
	    addto_reportedfail $m
	    nr_failmodule=$(($nr_failmodule+1))
            case $m in
            devtools*    ) addto_send $blame_devtools   ;; 
            sw_media*    ) addto_send $blame_sw_media   ;; 
            qt*          ) addto_send $blame_qt         ;; 
            c2box*       ) addto_send $blame_c2box      ;; 
            jtag*        ) addto_send $blame_jtag       ;; 
            c2_goodies*  ) addto_send $blame_c2_goodies ;; 
            diag*        ) addto_send $blame_diag       ;; 
            kernel*      ) addto_send $blame_kernel     ;; 
            vivante*     ) addto_send $blame_vivante    ;; 
            hdmi*        ) addto_send $blame_hdmi       ;; 
            uboot*       ) addto_send $blame_uboot      ;; 
            facudisk*    ) addto_send $blame_facudisk   ;; 
            usrudisk*    ) addto_send $blame_usrudisk   ;; 
            xxx*         ) addto_send $blame_xxx        ;; 
            *)  	  ;;
            esac
        fi
    done
    [ $nr_failmodule -gt 0 ] && addto_cc robinlee@c2micro.com
}

list_fail_url_tail()
{
    #pickup the fail log's tail to email for a quick preview
    nr_failurl=0
    loglist=`cat $indexlog`
    for i in $loglist ; do
        m=`echo $i | sed 's,\([^:]*\).*,\1,'`
        x=`echo $i | sed 's,[^:]*:\([^:]*\).*,\1,'`
        f=`echo $i | sed 's,[^:]*:[^:]*:\([^:]*\).*,\1,'`
        l=`echo $f | sed 's:.*/\(.*\):\1:'`
        if [ $x -ne 0 ]; then
            nr_failurl=$((nr_failurl+1))
            case $m in
            *_udisk) #jump these
                ;;
            *)
                echo $m fail :
                echo "    " "${WWW_HTTPHEAD}://$WWW_SERVER/${USER}/${WWW_LOGDIR}/$l"
                ;;
            esac
        fi
    done
    for i in $loglist ; do
        m=`echo $i | sed 's,\([^:]*\).*,\1,'`
        x=`echo $i | sed 's,[^:]*:\([^:]*\).*,\1,'`
        f=`echo $i | sed 's,[^:]*:[^:]*:\([^:]*\).*,\1,'`
        l=`echo $f | sed 's:.*/\(.*\):\1:'`
        if [ $x -ne 0 ]; then
            case $m in
            *_udisk) #jump these
                ;;
            *)
                echo
                echo $m fail , tail of $l:
                tail -n 40 $f
                ;;
            esac
        fi
    done
    export nr_failurl
}

nr_totalerror=0
nr_totalmodule=0
tm_total=`date +%s`
build_modules_x_steps()
{
for i in ${modules}; do
  nr_merr=0
  tm_module=`date +%s`
  for s in ${steps}; do
      iserror=0
      echo -en `date +"%Y-%m-%d %H:%M:%S"` build ${s}_$i " "
      tm_a=`date +%s`
      echo `date +"%Y-%m-%d %H:%M:%S"` Start build  ${s}_$i >>$log/progress.log
      make ${s}_$i        >>$log/$i.log 2>&1
      if [ $? -ne 0 ];then
        nr_merr=$((nr_merr+1))
	iserror=$((iserror+1))
      fi
      echo `date +"%Y-%m-%d %H:%M:%S"` Done build  ${s}_$i, $nr_merr error >>$log/progress.log
      recho_time_consumed $tm_a "$s: $iserror error(s). "  
      if [ $nr_merr -ne 0 ];then
        break;
      fi
  done
  if [ $nr_merr -ne 0 ];then
      addto_fail $i
  fi
  nr_totalerror=$((nr_totalerror+nr_merr))
  nr_totalmodule=$((nr_totalmodule+1))
  #echo "$i:$nr_merr:$log/$i.log" >>$log/r.txt
  update_indexlog "$i:$nr_merr:$log/$i.log" $indexlog
  recho_time_consumed $tm_module "Build module $i $nr_merr error(s). "
  echo "    "
done
}

modules="xxx"
steps="src_get src_package src_install src_config src_build bin_package bin_install "
build_modules_x_steps

#modules="kernela2632"
#steps="src_get src_package src_install src_config src_build bin_package bin_install "
#build_modules_x_steps

#modules="vivante hdmi uboot jtag diag c2_goodies "
#steps="src_package src_install src_config src_build bin_package bin_install "
#build_modules_x_steps

#modules="sw_media qt470 c2box "
#steps="src_package src_install src_config src_build bin_package bin_install "
#build_modules_x_steps

recho_time_consumed $tm_total "Build all $nr_totalmodule module(s) $nr_totalerror error(s). "
## --------------------------- report part ----------------------------

CONFIG_BUILD_PUBLISH=
CONFIG_BUILD_PUBLISHLOG=1
CONFIG_BUILD_PUBLISHHTML=1
CONFIG_BUILD_PUBLISHEMAIL=

addto_send ruishengfu@c2micro.com hguo@c2micro.com
checkadd_fail_send_list
mail_title="`make SDK_TARGET_ARCH` Build all $nr_totalmodule module(s) $nr_totalerror error(s)."
(
    echo "$mail_title"
    echo ""
    echo "Get build package at:       ${SSH_SERVER}:$SSH_SCPDIR/"
    echo "Click here to watch report: ${WWW_HTTPHEAD}://${WWW_SERVER}/${USER}/$HTML_REPORT"
    echo "Click here to watch logs:   ${WWW_HTTPHEAD}://${WWW_SERVER}/${USER}/${WWW_LOGDIR}"
    list_fail_url_tail
    echo ""
    [ $FAILLIST            ] && echo "fail in this build: $FAILLIST"
    [ $REPORTEDFAILLIST    ] && echo "fail in all builds: $REPORTEDFAILLIST"
    [ $nr_failurl -gt 0 -o $nr_totalerror -gt 0 ] && echo ""
    echo "More build environment reference info:"
    make mktest
    echo ""
    echo "send to list: $SENDTO"
    echo "You receive this email because you are in the relative software maintainer list"
    echo "For more other request about this email, please send contact with me"
    echo ""
    echo "For more reports: ${WWW_HTTPHEAD}://${WWW_SERVER}/${USER}/allinone.htm"
    echo "    or https://access.c2micro.com/~${USER}/allinone.htm"
    echo "Check blame history: ${WWW_HTTPHEAD}://${WWW_SERVER}/${USER}/blame"
    echo ""
    echo "Regards,"
    echo "`whoami`,`hostname`($THISIP)"
    echo "`readlink -f $0`"
    date
) >$log/email.log 2>&1

#    #the cgi need 4 variable pre-defined. it need a tail '/' in SDK_RESULTS_DIR, otherwise, we need fix the dev_logs//100829.log
#    #SDK_RESULTS_DIR=$DIST_DIR/ SDK_CVS_USER=$USER SDK_TARGET_ARCH=$SDK_TARGET_ARCH TREE_PREFIX=dev
export SDKENV_Title="${SDK_TARGET_ARCH} ${TREE_PREFIX} daily build"
export SDKENV_Project="${SDK_TARGET_ARCH} ${TREE_PREFIX} daily build"
export SDKENV_Overview="No overview yet"
export SDKENV_Setting="<pre>`make mktest`</pre>"
export SDKENV_Server="`whoami` on $THISIP(`hostname`)"
export SDKENV_Script="`readlink -f $0`"
./html_generate.cgi  >$DIST_DIR/$HTML_REPORT
#fix: // in url like:  href='https://access.c2micro.com/jazz2_msp_dev_logs//100829.log
sed -i 's:_logs//1:_logs/1:g' $DIST_DIR/$HTML_REPORT
sed -i "s: SDK Daily Build Results:${WWW_TITLE}:g" $DIST_DIR/$HTML_REPORT
sed -i "s,https://access.c2micro.com/~${USER}/,${WWW_HTTPHEAD}://${WWW_SERVER}/${USER}/,g" $DIST_DIR/$HTML_REPORT

scp_upload_logs()
{
    SCP_TARGET=${WWW_ROOT}/${WWW_LOGDIR}
    mkdir -p $SCP_TARGET
    cp $log/* $SCP_TARGET/
    pushd $SCP_TARGET;  
    unix2dos * ;
    popd

    #copy these links to web server blame folder
    mkdir -p ${WWW_ROOT}/blame
    cp -a ${DIST_DIR}/$DATE/blame/* ${WWW_ROOT}/blame/
}

mkdir -p ${WWW_ROOT}

if [ $CONFIG_BUILD_PUBLISHLOG ]; then
    scp_upload_logs
fi

if [ $CONFIG_BUILD_PUBLISH ]; then
    ssh ${USER}@${SSH_SERVER}     "mkdir -p $SSH_SCPDIR"
    scp -r $PKG_DIR/* ${USER}@${SSH_SERVER}:$SSH_SCPDIR/
fi

if [ $CONFIG_BUILD_PUBLISHHTML ]; then
    cp $DIST_DIR/$HTML_REPORT  ${WWW_ROOT}/
fi

if [ $CONFIG_BUILD_PUBLISHEMAIL ]; then
    cat $log/email.log | mail -s"$mail_title" $SENDTO
fi
