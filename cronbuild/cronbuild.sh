#!/bin/sh

#basic settings
#auto detect
TOP=`pwd`
TOP=/build2/jazz2-daily
cd $TOP
tm_toptask=`date +%s`
tm_date=`date`
TODAY=`date +%y%m%d`
THISSCR=`readlink -f $0`
THISIP==`/sbin/ifconfig eth0|sed -n 's/.*inet addr:\([^ ]*\).*/\1/p'`
[ -t 1 -o -t 2 ] && THISTTY=y
CONFIG_ARCH=`make SDK_TARGET_ARCH`
CONFIG_PKGDIR=`make PKG_DIR`
CONFIG_TREEPREFIX=dev
CONFIG_WEBSERVERS="build@10.16.13.195:/var/www/html/build/jazz2-dev-b2-sdk-daily.html"
CONFIG_LOGSERVERS="build@10.16.13.195:/var/www/html/build/jazz2-dev_logs/$TODAY.log"
CONFIG_PKGSERVERS="build@10.16.13.195:/sdk-b2/tempb2/jazz2/dev/weekly/$TODAY"
CONFIG_LOGSERVER=`echo $CONFIG_LOGSERVERS |awk '{print $1}'`
CONFIG_MAILLIST=hguo@c2micro.com
CONFIG_RESULT=$TOP/build_result/$TODAY
CONFIG_LOGDIR=$CONFIG_RESULT.log
CONFIG_INDEXLOG=$CONFIG_RESULT.txt
CONFIG_HTMLFILE=$CONFIG_LOGDIR/web.html
CONFIG_EMAILFILE=$CONFIG_LOGDIR/email.txt
CONFIG_EMAILTITLE="$CONFIG_ARCH $CONFIG_TREEPREFIX daily build pass"
CONFIG_PATH=/c2/local/c2/daily-jazz2/bin:$PATH
CONFIG_BUILD_DRY=1
CONFIG_BUILD_HELP=1
CONFIG_BUILD_LOCAL=1
CONFIG_BUILD_DOTAG=1
CONFIG_BUILD_CLEAN=1
CONFIG_BUILD_SDK=1
CONFIG_BUILD_CHECKOUT=
CONFIG_BUILD_PKGSRC=1
CONFIG_BUILD_PKGBIN=1
CONFIG_BUILD_DEVTOOLS=1
CONFIG_BUILD_SPI=1
CONFIG_BUILD_DIAG=1
CONFIG_BUILD_JTAG=1
CONFIG_BUILD_UBOOT=1
CONFIG_BUILD_C2GOODIES=1
CONFIG_BUILD_QT=1
CONFIG_BUILD_DOC=1
CONFIG_BUILD_KERNEL=1
CONFIG_BUILD_HDMI=1
CONFIG_BUILD_SWMEDIA=1
CONFIG_BUILD_VIVANTE=1
CONFIG_BUILD_C2APPS=1
CONFIG_BUILD_FACUDISK=1
CONFIG_BUILD_USRUDISK=1
CONFIG_BUILD_PUBLISH=
CONFIG_BUILD_PUBLISHLOG=1
CONFIG_BUILD_PUBLISHHTML=1
CONFIG_BUILD_PUBLISHEMAIL=1

#command line parse
while [ $# -gt 0 ] ; do
    case $1 in
    --help)       CONFIG_BUILD_HELP=y ; shift;;
    *) 	echo "not support option: $1"; CONFIG_BUILD_HELP=1;  shift  ;;
    esac
done
softlink()
{
    [ -h $2 ] && rm $2
    #[ -d ${2%/*} ] || mkdir -p ${2%/*}
    ln -s $1 $2
}
mkdir -p $CONFIG_RESULT $CONFIG_LOGDIR
touch $CONFIG_INDEXLOG
touch $CONFIG_HTMLFILE
touch $CONFIG_EMAILFILE
softlink $CONFIG_INDEXLOG r
softlink $CONFIG_LOGDIR   l
softlink $CONFIG_RESULT   i
#action parse
set | grep CONFIG_ >$CONFIG_LOGDIR/env.sh
cat $CONFIG_LOGDIR/env.sh
if [ $CONFIG_BUILD_CHECKOUT ];then
    /local/c2sdk/reposyncall
fi
addto_send()
{
    while [ $# -gt 0 ] ; do
        email=$1
        x=`echo $1 | grep "@"`
        if [ $? -ne 0 ]; then
            email=${email}@c2micro.com
        fi
        if [ "$CONFIG_MAILLIST" = "" ]; then
            CONFIG_MAILLIST=$email ;
        else
          r=`echo $CONFIG_MAILLIST | grep $email`
          if [ "$r" = "" ]; then
            CONFIG_MAILLIST=$CONFIG_MAILLIST,$email ;
          fi
        fi
        shift
    done
    export CONFIG_MAILLIST
}
update_indexlog()
{
    #handle echo "Hdmi:1:$hdmilog">>$CONFIG_INDEXLOG
    #to : update_indexlog "Devtools:1:$devtoolslog" $CONFIG_INDEXLOG
    m=`echo $1 | sed 's,\([^:]*\).*,\1,'`
    x=`echo $1 | sed 's,[^:]*:\([^:]*\).*,\1,'`
    f=`echo $1 | sed 's,[^:]*:[^:]*:\([^:]*\).*,\1,'`
    l=`echo $f | sed 's:.*/\(.*\):\1:'`

    has=
    [ -f $2 ] && has=`grep ^$m: $2`
    if [ $has ];then
        sed -i "s,$m:.*,$1,g" $2
        echo "debug: $2 find $m and replaced $m:$x "
    else
        echo "$1" >>$2
        echo "debug: $2 not find $m, appended: $1"
    fi

    #create broken log system
    if [ "$x" != "0" ]; then
        mkdir -p ${CONFIG_RESULT}/blog
        BLOG=${CONFIG_RESULT}/blog/$DATE-${CONFIG_ARCH}-${CONFIG_TREEPREFIX}-$m.log
        [ -f $BLOG ] || ln -s $f  $BLOG;
    fi
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
    loglist=`cat $CONFIG_INDEXLOG`
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
    [ $nr_failmodule -gt 0 ] && addto_send robinlee@c2micro.com
}

list_fail_url_tail()
{
    #pickup the fail log's tail to email for a quick preview
    nr_failurl=0
    loglist=`cat $CONFIG_INDEXLOG`
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
		echo -en "    "
                echo "$SDKENV_URLPRE/${CONFIG_LOGSERVER##*/}/$l"
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


#set -ex
nr_totalerror=0
nr_totalmodule=0
tm_total=`date +%s`
modules=xxx
steps=help
build_modules_x_steps()
{
    for i in ${modules}; do
        nr_merr=0
        tm_module=`date +%s`
        for s in ${steps}; do
            iserror=0
            echo -en `date +"%Y-%m-%d %H:%M:%S"` build ${s}_$i " "
            tm_a=`date +%s`
            echo `date +"%Y-%m-%d %H:%M:%S"` Start build  ${s}_$i >>$CONFIG_LOGDIR/progress.log
            make ${s}_$i        >>$CONFIG_LOGDIR/$i.log 2>&1
            if [ $? -ne 0 ];then
              nr_merr=$((nr_merr+1))
              iserror=$((iserror+1))
            fi
            echo `date +"%Y-%m-%d %H:%M:%S"` Done build  ${s}_$i, $nr_merr error >>$CONFIG_LOGDIR/progress.log
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
        update_indexlog "$i:$nr_merr:$CONFIG_LOGDIR/$i.log" $CONFIG_INDEXLOG
        echo recho_time_consumed $tm_module "Build module $i $nr_merr error(s). "
        echo "    "
    done
}

modules="xxx"
#modules="devtools sw_media qt470 kernel kernelnand kernela2632 uboot vivante hdmi c2box jtag diag c2_goodies facudisk usrudisk"
#modules="kernel kernelnand vivante hdmi uboot jtag diag sw_media qt470" # c2box facudisk usrudisk"
modules="c2box facudisk usrudisk"
steps="src_get src_package src_install src_config src_build bin_package bin_install "
build_modules_x_steps

#step operations
if test $CONFIG_BUILD_HELP; then
    echo help done.
fi

#generate web report
#these exports are used by html_generate.cgi
export SDK_RESULTS_DIR=${CONFIG_RESULT%/*}
export SDKENV_Title="`make SDK_TARGET_ARCH` $CONFIG_TREEPREFIX on $HOSTNAME daily build"
export SDKENV_Project="${SDK_TARGET_ARCH} ${TREE_PREFIX} daily build"
export SDKENV_Overview="<pre>Project start on $tm_date
`recho_time_consumed $tm_toptask all done`</pre>"
export SDKENV_Setting="<pre>`make lsvar`</pre>"
export SDKENV_Server="`whoami` on $THISIP(`hostname`)"
export SDKENV_Script="`readlink -f $0`"
export SDKENV_URLPRE=http://`echo ${CONFIG_LOGSERVER%/*} | sed -e 's,/var/www/html,,g' -e 's,^.*@,,g'`
./html_generate.cgi  > $CONFIG_HTMLFILE


#generate email
#addto_send ruishengfu@c2micro.com hguo@c2micro.com
checkadd_fail_send_list
CONFIG_EMAILTITLE="`make SDK_TARGET_ARCH` $CONFIG_TREEPREFIX $HOSTNAME $nr_totalmodule module(s) $nr_totalerror error(s)."
(
    echo "$CONFIG_EMAILTITLE"
    echo ""
    echo "Get build package at nfs service:"
    for i in $CONFIG_PKGSERVERS; do
	echo "    ${i##*@}"
    done
    echo ""
    [ $FAILLIST            ] && echo "fail in this build: $FAILLIST"
    [ $REPORTEDFAILLIST    ] && echo "fail in all builds: $REPORTEDFAILLIST"
    echo "Click here to watch report:"
    for i in  $CONFIG_WEBSERVERS; do
	echo -en "    http://"
        echo "${i##*@}" | sed 's,:/var/www/html,,g'
    done
    echo "Click here to watch logs:"
    for i in $CONFIG_LOGSERVERS; do
	echo -en "    http://"
        echo "${i##*@}" | sed 's,:/var/www/html,,g'
    done
    list_fail_url_tail
    [ $nr_failurl -gt 0 -o $nr_totalerror -gt 0 ] && echo ""
    echo "More build environment reference info:"
    make lsvar
    echo ""
    echo "send to list: $CONFIG_MAILLIST"
    echo "You receive this email because you are in the relative software maintainer list"
    echo "For more other request about this email, please send contact with me"
    echo ""
    echo "For more reports: http://10.16.13.196/build/allinone.htm"
    echo "    or https://access.c2micro.com/~build/allinone.htm"
    #echo "Check broken log history:  http://10.16.13.196/${USER}/blog"
    echo ""
    echo "Regards,"
    echo "`whoami`,`hostname`($THISIP)"
    echo "`readlink -f $0`"
    date
) >$CONFIG_EMAILFILE 2>&1


#upload log
if [ $CONFIG_BUILD_PUBLISHLOG ]; then
    unix2dos -q $CONFIG_LOGDIR/*
    for i in $CONFIG_LOGSERVERS; do
        h=${i%%:/*}
        p=${i##*:}
        ssh $h mkdir -p $p
	scp -r $CONFIG_LOGDIR/* $i/
    done
    echo publish log done.
fi

#upload package
if [ $CONFIG_BUILD_PUBLISH ]; then
    if [ $nr_failurl -gt 0 -o $nr_totalerror -gt 0 ] ; then
        echo has errors, can not publish
    else
    for i in $CONFIG_PKGSERVERS; do
        h=${i%%:/*}
        p=${i##*:}
        ssh $h mkdir -p $p
	scp -r $CONFIG_PKGDIR/* $i/
    done
    echo publish package done.
    fi
fi

#upload web report
if [ $CONFIG_BUILD_PUBLISHHTML ]; then
    for i in $CONFIG_WEBSERVERS; do
        h=${i%%:/*}
        p=${i##*:}
	f=${p##*/}
	p=${p%/*}
        ssh $h mkdir -p $p
	scp -r $CONFIG_HTMLFILE $i
    done
    echo publish web done.
fi

#send email
if [ $CONFIG_BUILD_PUBLISHEMAIL ]; then
    echo email title "$CONFIG_EMAILTITLE" 
    echo send to: $CONFIG_MAILLIST
    #cat $CONFIG_EMAILFILE | mail -s"$CONFIG_EMAILTITLE" $CONFIG_MAILLIST
    cat $CONFIG_EMAILFILE | mail -s"$CONFIG_EMAILTITLE" hguo@c2micro.com
    echo send mail done.
fi

