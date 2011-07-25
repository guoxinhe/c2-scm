#!/bin/sh

#basic settings
#auto detect
if [ -t 1 -o -t 2 ]; then
CONFIG_TTY=y
TOP=`pwd`
else
TOP=/build2/jazz2-daily
fi
cd $TOP
jobtimeout=6000
lock=`pwd`/${0##*/}.lock
if [ -f $lock ]; then
    burn=`stat -c%Z $lock`
    now=`date +%s`
    age=$((now-burn))
    #24 hour = 86400 seconds = 24 * 60 * 60 seconds.
    if [ $age -gt $jobtimeout ]; then
        rm -rf $lock
    else
        echo "an active task is running for $age seconds: `cat $lock`"
	echo "close it before restart: $lock"
        exit 1
    fi
fi
echo "`date` $(whoami)@$(hostname) `readlink -f $0` tid:$$ " >$lock

#detect env
TODAY=`date +%y%m%d`
THISIP=`/sbin/ifconfig eth0|sed -n 's/.*inet addr:\([^ ]*\).*/\1/p'`

CONFIG_SCRIPT=`readlink -f $0`
CONFIG_STARTTIME=`date`
CONFIG_STARTTID=`date +%s`
CONFIG_ARCH=`make SDK_TARGET_ARCH`  #jazz2 jzz2t jazz2l
CONFIG_PKGDIR=`make PKG_DIR`        
CONFIG_TREEPREFIX=sdkdev               #sdkdev sdkrel anddev andrel, etc, easy to understand
CONFIG_GCCPATH=/c2/local/c2/daily-jazz2/bin
CONFIG_GCC=`$CONFIG_GCCPATH/c2-linux-gcc --version`
CONFIG_KERNEL=`make SDK_KERNEL_VERSION`
CONFIG_LIBC=uClibc-0.9.27
CONFIG_BRANCH=master
CONFIG_PROJECT=SDK
CONFIG_WEBFILE="${CONFIG_ARCH}_${CONFIG_TREEPREFIX}_${HOSTNAME}-sdk_daily.html"
CONFIG_WEBTITLE="${CONFIG_ARCH}_${CONFIG_TREEPREFIX}_${HOSTNAME}-sdk_daily build"
CONFIG_WEBSERVERS="build@10.16.13.195:/var/www/html/build/scriptdebug/$CONFIG_WEBFILE"
CONFIG_LOGSERVERS="build@10.16.13.195:/var/www/html/build/scriptdebug/${CONFIG_ARCH}_${CONFIG_TREEPREFIX}_${HOSTNAME}_logs/$TODAY.log"
CONFIG_PKGSERVERS="build@10.16.13.195:/sdk-b2/scriptdebug/jazz2/dev/weekly/$TODAY"
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
    --noco)      CONFIG_BUILD_CHECKOUT= ; shift;;
    --help)       CONFIG_BUILD_HELP=y ; shift;;
    --set)   set | grep CONFIG_    ;   rm -rf $lock; exit 0; shift;;
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
addto_buildfail()
{
    while [ $# -gt 0 ] ; do
        if [ "$FAILLIST_BUILD" = "" ]; then
            FAILLIST_BUILD=$1 ;
        else
          r=`echo $FAILLIST_BUILD | grep $1`
          if [ "$r" = "" ]; then
            FAILLIST_BUILD=$FAILLIST_BUILD,$1 ;
          fi
        fi
        shift
    done
    export FAILLIST_BUILD
}
addto_resultfail()
{
    while [ $# -gt 0 ] ; do
        if [ "$FAILLIST_RESULT" = "" ]; then
            FAILLIST_RESULT=$1 ;
        else
          r=`echo $FAILLIST_RESULT | grep $1`
          if [ "$r" = "" ]; then
            FAILLIST_RESULT=$FAILLIST_RESULT,$1 ;
          fi
        fi
        shift
    done
    export FAILLIST_RESULT
}
BR=$CONFIG_BRANCH
c2androiddir=`make SOURCE_DIR`
checkout_script=$CONFIG_PKGDIR/checkout-gits-tags.sh
create_checkout_script(){
    #create checkout script of this build code
    echo '#!/bin/sh'                 >$checkout_script
    echo ""                         >>$checkout_script
    echo "repo start --all $BR"     >>$checkout_script
    echo ""                         >>$checkout_script
    repo forall -c "echo pushd \$(pwd); 
        echo -en 'git checkout '; 
        git  log -n 1 | grep ^commit\ | sed 's/commit //g';
        echo 'popd'; echo ' ';" >>$checkout_script
    sed -i -e "s,$c2androiddir/,,g"   $checkout_script
    chmod 755                         $checkout_script
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
	    addto_resultfail $m
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
nr_failurl=0
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
            addto_buildfail $i
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
modules="kernel kernelnand vivante hdmi uboot sw_media qt470 c2box jtag diag c2_goodies "
steps="src_get src_package src_install src_config src_build bin_package bin_install "
build_modules_x_steps

r=`grep ^c2box:0 $CONFIG_INDEXLOG`
#r=`grep ^uboot:0 $CONFIG_INDEXLOG`
#r=`grep ^kernel:0 $CONFIG_INDEXLOG`
if [ "$r" != "" ]; then
    modules=
    [ $CONFIG_BUILD_FACUDISK ] && modules="$modules facudisk"
    [ $CONFIG_BUILD_USRUDISK ] && modules="$modules usrudisk"
    steps="src_get src_package src_install src_config src_build bin_package bin_install "
    build_modules_x_steps
else
    echo can not build, depend steps: c2box
fi

create_checkout_script

#step operations
if test $CONFIG_BUILD_HELP; then
    echo help done.
fi

#generate web report
#these exports are used by html_generate.cgi
export SDK_RESULTS_DIR=${CONFIG_RESULT%/*}
export SDKENV_Title=$CONFIG_WEBTITLE
export SDKENV_Project="${CONFIG_ARCH} ${CONFIG_TREEPREFIX} daily build on $HOSTNAME"
export SDKENV_Overview="<pre>Project start on $CONFIG_STARTTIME, done on `date`
`recho_time_consumed $CONFIG_STARTTID all done`</pre>"
export SDKENV_Setting="<pre>Makefile settings:
`make lsvar`

build script settings:
`set | grep CONFIG_ `
</pre>"
export SDKENV_Server="`whoami` on $THISIP(`hostname`)"
export SDKENV_Script="`readlink -f $0`"
export SDKENV_URLPRE=http://`echo ${CONFIG_LOGSERVER%/*} | sed -e 's,/var/www/html,,g' -e 's,^.*@,,g'`
./html_generate.cgi  > $CONFIG_HTMLFILE

checkadd_fail_send_list
if [ $nr_failurl -gt 0 ] ; then
    CONFIG_BUILD_PUBLISH=
fi
if [ $nr_totalerror -gt 0 ] ; then
    CONFIG_BUILD_PUBLISH=
fi

#generate email
#addto_send ruishengfu@c2micro.com hguo@c2micro.com
CONFIG_EMAILTITLE="${CONFIG_ARCH} $CONFIG_TREEPREFIX $HOSTNAME $nr_totalmodule module(s) $nr_totalerror error(s)."
(
    echo "$CONFIG_EMAILTITLE"
    echo ""
    echo "Get build package at nfs service:"
    for i in $CONFIG_PKGSERVERS; do
	echo "    ${i##*@}"
    done
    echo ""
    [ $FAILLIST_BUILD            ] && echo "fail in this build: $FAILLIST_BUILD"
    [ $FAILLIST_RESULT    ] && echo "fail in all builds: $FAILLIST_RESULT"
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
    echo ""
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
        ip=`echo $CONFIG_LOGSERVERS | sed -e 's,.*@\(.*\):.*,\1,g'`
	if [ "$ip" = "$THISIP" ];then
            mkdir -p $p
	    echo "cp -rf $CONFIG_LOGDIR/* $p/"
	    cp -rf $CONFIG_LOGDIR/* $p/
	else
            ssh $h mkdir -p $p
	    scp -r $CONFIG_LOGDIR/* $i/
	fi
    done
    echo publish log done.
fi

#upload package
if [ $CONFIG_BUILD_PUBLISH ]; then
    for i in $CONFIG_PKGSERVERS; do
        h=${i%%:/*}
        p=${i##*:}
        ip=`echo $CONFIG_PKGSERVERS | sed -e 's,.*@\(.*\):.*,\1,g'`
	if [ "$ip" = "$THISIP" ];then
            mkdir -p $p
	    echo "cp -rf $CONFIG_PKGDIR/* $p/"
	    cp -rf $CONFIG_PKGDIR/* $p/
        else
            ssh $h mkdir -p $p
	    scp -r $CONFIG_PKGDIR/* $i/
        fi
    done
    echo publish package done.
fi

#upload web report
if [ $CONFIG_BUILD_PUBLISHHTML ]; then
    for i in $CONFIG_WEBSERVERS; do
        h=${i%%:/*}
        p=${i##*:}
	f=${p##*/}
	p=${p%/*}
        ip=`echo $CONFIG_WEBSERVERS | sed -e 's,.*@\(.*\):.*,\1,g'`
	if [ "$ip" = "$THISIP" ];then
            mkdir -p $p
            echo "cp -f $CONFIG_HTMLFILE $p/$f"
            cp -f $CONFIG_HTMLFILE $p/$f
        else
            ssh $h mkdir -p $p
	    scp -r $CONFIG_HTMLFILE $i
        fi
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

rm -rf $lock
