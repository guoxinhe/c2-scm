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
[ -f bc.mk             ] || ln -s $fullfod/config_jazz2.daily.mk bc.mk
[ -f br.mk             ] || ln -s $fullfod/config_jazz2.rules.mk br.mk
[ -f html_generate.cgi ] || ln -s $fullfod/html_generate.cgi     html_generate.cgi

modules="
xxx
"
modules_jump="
devtools 
sw_media 
qt470 
kernel 
kernelnand 
uboot 
vivante 
hdmi 
c2box 
jtag 
diag 
c2_goodies 
facudisk 
usrudisk
xxx
"

steps="
clean
src_get
src_package
src_install
src_config
src_build
bin_package
bin_install
"

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
}

addto_send()
{
    while [ $# -gt 0 ] ; do
        if [ "$SENDTO" = "" ]; then
            SENDTO=$1 ;
        else
          r=`echo $SENDTO | grep $1`
          if [ "$r" = "" ]; then
            SENDTO=$SENDTO,$1 ;
          fi
        fi
        shift
    done
    export SENDTO
}
addto_cc()
{
    while [ $# -gt 0 ] ; do
        if [ "$CCTO" = "" ]; then
            CCTO=$1 ;
        else
          r=`echo $CCTO | grep $1`
          if [ "$r" = "" ]; then
            CCTO=$CCTO,$1 ;
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
    tm_c=$(($tm_b-$1))
    tm_h=$(($tm_c/3600))
    tm_m=$(($tm_c/60))
    tm_m=$(($tm_m%60))
    tm_s=$(($tm_c%60))
    shift
    echo "$@" "$tm_c seconds / $tm_h:$tm_m:$tm_s consumed."
}

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
            devtools*     ) addto_send hguo@c2micro.com saladwang@c2micro.com        ;;
            sw_media*     ) addto_send hguo@c2micro.com weli@c2micro.com fzhang@c2micro.com             ;;
            qt*           ) addto_send hguo@c2micro.com mxia@c2micro.com dashanzhou@c2micro.com txiang@c2micro.com             ;;
            c2box*        ) addto_send hguo@c2micro.com mxia@c2micro.com            ;;
            jtag*         ) addto_send hguo@c2micro.com jsun@c2micro.com             ;;
            c2_goodies*   ) addto_send hguo@c2micro.com robinlee@c2micro.com ali@c2micro.com             ;;
            diag*         ) addto_send hguo@c2micro.com jsun@c2micro.com             ;;
            kernel*       ) addto_send hguo@c2micro.com swine@c2micro.com jsun@c2micro.com robinlee@c2micro.com ali@c2micro.com roger@c2micro.com janetliu@c2micro.com llian@c2micro.com ;;
            vivante*      ) addto_send hguo@c2micro.com llian@c2micro.com            ;;
            hdmi*         ) addto_send hguo@c2micro.com jsun@c2micro.com             ;;
            uboot*        ) addto_send hguo@c2micro.com robinlee@c2micro.com ali@c2micro.com             ;;
            facudisk*     ) addto_send hguo@c2micro.com              ;;
            usrudisk*     ) addto_send hguo@c2micro.com              ;;

            Devtools)     addto_send  saladwang@c2micro.com ;;
            Buildroot)    addto_send  saladwang@c2micro.com ;;
            SPI)          addto_send       jsun@c2micro.com ;;
            Jtag)         addto_send       jsun@c2micro.com ;;
            Uboot)        addto_send   robinlee@c2micro.com ;;
            Hdmi)         addto_send  zhenzhang@c2micro.com ;;
            C2_goodies)   addto_send   robinlee@c2micro.com ;;
            Qt)           addto_send dashanzhou@c2micro.com ;;
            Kernel)       addto_send      swine@c2micro.com ;;
            Kernel2632)   addto_send      swine@c2micro.com ;;
            Sw_media)     addto_send       weli@c2micro.com ;;
            vivante)      addto_send      llian@c2micro.com ;;
            Sw_c2apps)    addto_send dashanzhou@c2micro.com ;;
            factory_udisk)addto_send       hguo@c2micro.com ;;
            user_udisk)   addto_send       hguo@c2micro.com ;;
            *)  	  ;;
            esac
        fi
    done
    #[ $nr_failmodule -gt 0 ] && addto_cc wdiao@c2micro.com
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
                echo "    " "http://$THISIP/${SDK_CVS_USER}/${SDK_TARGET_ARCH}_${TREE_PREFIX}_logs/$DATE.log/$l"
                #echo "    " "https://access.c2micro.com/~${SDK_CVS_USER}/${SDK_TARGET_ARCH}_${TREE_PREFIX}_logs/$DATE.log/$l"
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



if [ "$1" == "init" ]; then
  make clean
  rm -rf log
  lcp /sdk/jazz2/dev/weekly/110330 jazz2-sdk-110330
  make bin_install_devtools
  shift
fi

config_enable_clean=y
config_enable_src_get=y
config_enable_src_package=y
config_enable_src_install=y
config_enable_src_config=y
config_enable_src_build=y
config_enable_bin_package=y
config_enable_bin_install=y

DATE=`date +%y%m%d`
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

nr_totalerror=0
nr_totalmodule=0
tm_total=`date +%s`

for i in ${modules}; do
  nr_merr=0
  tm_module=`date +%s`
  for s in ${steps}; do
      jump=y
      iserror=0
      if [ "$s" == "src_get"     -a "$config_enable_src_get"     == "y" ]; then jump= ; fi
      if [ "$s" == "src_package" -a "$config_enable_src_package" == "y" ]; then jump= ; fi
      if [ "$s" == "src_install" -a "$config_enable_src_install" == "y" ]; then jump= ; fi
      if [ "$s" == "src_config"  -a "$config_enable_src_config"  == "y" ]; then jump= ; fi
      if [ "$s" == "src_build"   -a "$config_enable_src_build"   == "y" ]; then jump= ; fi
      if [ "$s" == "bin_package" -a "$config_enable_bin_package" == "y" ]; then jump= ; fi
      if [ "$s" == "bin_install" -a "$config_enable_bin_install" == "y" ]; then jump= ; fi

      echo -en `date +"%Y-%m-%d %H:%M:%S"` build ${s}_$i " "
      tm_a=`date +%s`
      echo `date +"%Y-%m-%d %H:%M:%S"` Start build  ${s}_$i >>$log/progress.log
      if [ "$jump" == "y" ]; then
          echo "make ${s}_$i jumped" >>$log/$i.log 2>&1
      else
          make ${s}_$i        >>$log/$i.log 2>&1
      fi
      if [ $? -ne 0 ];then
        nr_merr=$((nr_merr+1))
	iserror=$((iserror+1))
      fi
      echo `date +"%Y-%m-%d %H:%M:%S"` Done build  ${s}_$i, $nr_merr error >>$log/progress.log
      recho_time_consumed $tm_a "$s: $iserror error(s). "  
  done
  if [ $nr_merr -ne 0 ];then
      addto_fail $i
  fi
  nr_totalerror=$((nr_totalerror+nr_merr))
  nr_totalmodule=$((nr_totalmodule+1))
  #echo "$i:$nr_merr:$log/$i.log" >>$log/r.txt
  update_indexlog "$i:$nr_merr:$log/$i.log" $indexlog
  recho_time_consumed $tm_module "Build module $i $nr_merr error(s). "
done

recho_time_consumed $tm_total "Build all $nr_totalmodule module(s) $nr_totalerror error(s). "

#these 4 exports are used by html_generate.cgi
export SDK_TARGET_ARCH=`make SDK_TARGET_ARCH`
export TREE_PREFIX=dev
export SDK_RESULTS_DIR=$DIST_DIR/
export SDK_CVS_USER=`echo $CVSROOT | sed 's/:/ /g' | sed 's/\@/ /g' | awk '{print $2}'`
[ $SDK_CVS_USER ] || export SDK_CVS_USER=`whoami`

WWWROOT=/var/www/html/hguo
scp_upload_logs()
{
    SCP_TARGET=${WWWROOT}/${SDK_TARGET_ARCH}_${TREE_PREFIX}_logs/$DATE.log
    mkdir -p $SCP_TARGET
    cp $log/* $SCP_TARGET/
    pushd $SCP_TARGET;  
    unix2dos * ;
    popd
}

CONFIG_BUILD_PUBLISH=
CONFIG_BUILD_PUBLISHLOG=
CONFIG_BUILD_PUBLISHHTML=
CONFIG_BUILD_PUBLISHEMAIL=

PKG_DIR=`make PKG_DIR`
S200_DIR=/home/$SDK_CVS_USER/sdkdailybuild/$SDK_TARGET_ARCH/$TREE_PREFIX/weekly/$DATE
mkdir -p ${WWWROOT}

if [ $CONFIG_BUILD_PUBLISHLOG ]; then
    scp_upload_logs
fi

if [ $CONFIG_BUILD_PUBLISH ]; then
    ssh ${SDK_CVS_USER}@10.16.13.200     "mkdir -p $S200_DIR"
    scp -r $PKG_DIR/* ${SDK_CVS_USER}@10.16.13.200:$S200_DIR/
fi

if [ $CONFIG_BUILD_PUBLISHHTML ]; then
    HTML_REPORT=${SDK_TARGET_ARCH}_${TREE_PREFIX}_sdk_daily.html
#    #the cgi need 4 variable pre-defined. it need a tail '/' in SDK_RESULTS_DIR, otherwise, we need fix the dev_logs//100829.log
#    #SDK_RESULTS_DIR=$DIST_DIR/ SDK_CVS_USER=$SDK_CVS_USER SDK_TARGET_ARCH=$SDK_TARGET_ARCH TREE_PREFIX=dev
    ./html_generate.cgi  >$DIST_DIR/$HTML_REPORT
    #fix: // in url like:  href='https://access.c2micro.com/jazz2_msp_dev_logs//100829.log
    sed -i 's:_logs//1:_logs/1:g' $DIST_DIR/$HTML_REPORT
    sed -i 's:SDK Daily Build Results:SDK My Test Build Results:g' $DIST_DIR/$HTML_REPORT
    sed -i "s,https://access.c2micro.com/~${SDK_CVS_USER}/,http://${THISIP}/${SDK_CVS_USER}/,g" $DIST_DIR/$HTML_REPORT
    #cp $DIST_DIR/$HTML_REPORT  /home/${SDK_CVS_USER}/public_html/
    cp $DIST_DIR/$HTML_REPORT  ${WWWROOT}/
fi

    addto_send hguo@c2micro.com
    checkadd_fail_send_list
    mail_title="`make SDK_TARGET_ARCH` Build all $nr_totalmodule module(s) $nr_totalerror error(s)."
    (
	echo "$mail_title"
	echo ""
	echo "Get build package at: 10.16.13.200:$S200_DIR/"
        echo "Click here to watch report: http://${THISIP}/${SDK_CVS_USER}/$HTML_REPORT"
        echo "Click here to watch logs: http://${THISIP}/${SDK_CVS_USER}/${SDK_TARGET_ARCH}_${TREE_PREFIX}_logs/$DATE.log"
	list_fail_url_tail
	echo ""
	[ $FAILLIST            ] && echo "fail in this build: $FAILLIST"
	[ $REPORTEDFAILLIST    ] && echo "fail in all builds: $REPORTEDFAILLIST"
        [ $nr_failurl -gt 0 -o $nr_totalerror -gt 0 ] && echo ""
	echo "send to list: $SENDTO"
	echo ""
	echo "Regards,"
	echo "`whoami`@$THISIP":"`readlink -f $0`"
	date
    ) >$log/email.log 2>&1
if [ $CONFIG_BUILD_PUBLISHEMAIL ]; then
    cat $log/email.log | mail -s"$mail_title" $SENDTO
fi
