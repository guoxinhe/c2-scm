#!/bin/sh

#basic settings
#auto detect
TOP=`pwd`
cd $TOP
TODAY=`date +%y%m%d`
THISSCR=`readlink -f $0`
THISIP==`/sbin/ifconfig eth0|sed -n 's/.*inet addr:\([^ ]*\).*/\1/p'`
[ -t 1 -o -t 2 ] && THISTTY=y
CONFIG_ARCH=jazz2
CONFIG_TREEPREFIX=dev
CONFIG_WEBSERVER="build@10.16.13.195:/var/www/html/build/jazz2-dev-sdk-daily.html"
CONFIG_LOGSERVER="build@10.16.13.196:/var/www/html/build/jazz2-dev-log/$TODAY"
CONFIG_PKGSERVER="build@10.16.13.196:/sdk-b2/jazz2/dev/weekly/$TODAY"
CONFIG_MAILLIST=hguo@c2micro.com
CONFIG_RESULT=$TOP/build_result/$TODAY
CONFIG_LOGDIR=$CONFIG_RESULT.log
CONFIG_INDEXLOG=$CONFIG_RESULT.txt
CONFIG_HTMLFILE=$CONFIG_RESULT/web.html
CONFIG_EMAILFILE=$CONFIG_RESULT/email.txt
CONFIG_PATH=/c2/local/c2/daily-jazz2/bin:$PATH
CONFIG_BUILD_DRY=1
CONFIG_BUILD_HELP=1
CONFIG_BUILD_LOCAL=1
CONFIG_BUILD_DOTAG=1
CONFIG_BUILD_CLEAN=1
CONFIG_BUILD_SDK=1
CONFIG_BUILD_CHECKOUT=1
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
CONFIG_BUILD_PUBLISH=1
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

modules="uboot"
steps="src_get src_package src_install src_config src_build bin_package bin_install "
build_modules_x_steps

#step operations
if test $CONFIG_BUILD_HELP; then
    echo help done.
fi

#upload log
if [ $CONFIG_BUILD_PUBLISHLOG ]; then
    echo publish log done.
fi

#upload package
if [ $CONFIG_BUILD_PUBLISH ]; then
    echo publish package done.
fi

#upload web report
if [ $CONFIG_BUILD_PUBLISHHTML ]; then
    echo publish web done.
fi

#send email
if [ $CONFIG_BUILD_PUBLISHEMAIL ]; then
    echo send mail done.
fi

