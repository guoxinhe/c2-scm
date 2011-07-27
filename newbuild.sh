#!/bin/sh
#set -ex
#basic settings auto detect
#---------------------------------------------------------------
CONFIG_TODAY=`date +%y%m%d`
CONFIG_MYIP=`/sbin/ifconfig eth0|sed -n 's/.*inet addr:\([^ ]*\).*/\1/p'`
CONFIG_SCRIPT=`readlink -f $0`
CONFIG_STARTTIME=`date`
CONFIG_STARTTID=`date +%s`
if [ -t 1 -o -t 2 ]; then
CONFIG_TTY=y
TOP=`pwd`
else
TOP=/build2/jazz2-daily
fi
cd $TOP

#---------------------------------------------------------------
CONFIG_MAKEFILE=Makefile
CONFIG_GENHTML=`pwd`/scm/html_generate.cgi
CONFIG_ARCH=`make -f $CONFIG_MAKEFILE SDK_TARGET_ARCH`  #jazz2 jzz2t jazz2l
CONFIG_PKGDIR=`make -f $CONFIG_MAKEFILE PKG_DIR`
CONFIG_TREEPREFIX=sdkdev               #sdkdev sdkrel anddev andrel, etc, easy to understand
CONFIG_GCCPATH=/c2/local/c2/daily-jazz2/bin
CONFIG_GCC=`$CONFIG_GCCPATH/c2-linux-gcc --version`
CONFIG_KERNEL=`make -f $CONFIG_MAKEFILE SDK_KERNEL_VERSION`
CONFIG_LIBC=uClibc-0.9.27
CONFIG_BRANCH=master  #one of: master, devel, etc.
CONFIG_PROJECT=SDK    #one of: SDK, android
CONFIG_WEBFILE="${CONFIG_ARCH}_${CONFIG_TREEPREFIX}_${HOSTNAME}-sdk_daily.html"
CONFIG_WEBTITLE="${CONFIG_ARCH}_${CONFIG_TREEPREFIX}_${HOSTNAME}-sdk_daily build"
CONFIG_WEBSERVERS="build@10.16.13.195:/var/www/html/build/scriptdebug/$CONFIG_WEBFILE
                #build@10.0.5.193:/home/build/public_html/scriptdebug/$CONFIG_WEBFILE
                     #hguo@10.16.5.166:/var/www/html/hguo/scriptdebug/$CONFIG_WEBFILE
"
CONFIG_LOGSERVERS="build@10.16.13.195:/var/www/html/build/scriptdebug/${CONFIG_ARCH}_${CONFIG_TREEPREFIX}_${HOSTNAME}_logs/$CONFIG_TODAY.log
                #build@10.0.5.193:/home/build/public_html/scriptdebug/${CONFIG_ARCH}_${CONFIG_TREEPREFIX}_${HOSTNAME}_logs/$CONFIG_TODAY.log
                     #hguo@10.16.5.166:/var/www/html/hguo/scriptdebug/${CONFIG_ARCH}_${CONFIG_TREEPREFIX}_${HOSTNAME}_logs/$CONFIG_TODAY.log
"
CONFIG_PKGSERVERS="build@10.16.13.195:/sdk-b2/scriptdebug/jazz2/dev/weekly/$CONFIG_TODAY
                  #build@10.16.13.195:/sdk-b1/scriptdebug/jazz2/dev/weekly/$CONFIG_TODAY
"
CONFIG_LOGSERVER=`echo $CONFIG_LOGSERVERS |awk '{print $1}'`
CONFIG_MAILLIST=hguo@c2micro.com
CONFIG_RESULT=$TOP/build_result/$CONFIG_TODAY
CONFIG_LOGDIR=$CONFIG_RESULT.log
CONFIG_INDEXLOG=$CONFIG_RESULT.txt
CONFIG_HTMLFILE=$CONFIG_LOGDIR/web.html
CONFIG_EMAILFILE=$CONFIG_LOGDIR/email.txt
CONFIG_EMAILTITLE="$CONFIG_ARCH $CONFIG_TREEPREFIX daily build pass"
CONFIG_PATH=$CONFIG_GCCPATH:$PATH
CONFIG_DEBUG=1
CONFIG_BUILD_DRY=1
CONFIG_BUILD_HELP=
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
CONFIG_BUILD_FACUDISK=
CONFIG_BUILD_USRUDISK=
CONFIG_BUILD_XXX=1
CONFIG_BUILD_PUBLISH=1
CONFIG_BUILD_PUBLISHLOG=1
CONFIG_BUILD_PUBLISHHTML=1
CONFIG_BUILD_PUBLISHEMAIL=

#command line parse
while [ $# -gt 0 ] ; do
    case $1 in
    --noco)      CONFIG_BUILD_CHECKOUT= ; shift;;
    --help | -h)      CONFIG_BUILD_HELP=y ; shift;;
    --set)   set | grep CONFIG_  ;  exit 0; shift;;
    *) 	echo "not support option: $1"; CONFIG_BUILD_HELP=1;  shift  ;;
    esac
done

#step operations
if test $CONFIG_BUILD_HELP; then
    set | grep CONFIG_  ;

cat <<EOFHELP

Please support these in Makefile
    make SDK_TARGET_ARCH      : return arch name
    make SDK_KERNEL_VERSION   : return kernel version name
    make PKG_DIR              : return package folder name
    make SOURCE_DIR           : return source folder name
    make sdk_folders          : create build used folders
    make lsvar                : list Makefile's important config variables

module build ops used in Makefile, example module name is:xxx
    make src_get_xxx src_package_xxx src_install_xxx src_config_xxx src_build_xxx bin_package_xxx bin_install_xxx 
    make test_xxx clean_xxx help_xxx
EOFHELP
    exit 0;
fi


#---------------------------------------------------------------
jobtimeout=6000
lock=`pwd`/${0##*/}.lock
lock_job()
{
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
	echo "`date` $(whoami)@$(hostname) `readlink -f $0` tid:$$, lock age: $age, life: $jobtimeout" >>$lock.log
        exit 1
    fi
  fi
  >$lock.log
  echo "`date` $(whoami)@$(hostname) `readlink -f $0` tid:$$ " >$lock
}
softlink()
{
    [ -h $2 ] && rm $2
    #[ -d ${2%/*} ] || mkdir -p ${2%/*}
    ln -s $1 $2
}
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
checkout_from_repositories()
{
    /local/c2sdk/reposyncall
}
create_repo_checkout_script()
{
    BR=$CONFIG_BRANCH
    c2androiddir=$1
    checkout_script=$2

    pushd $c2androiddir
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
    popd
}

checkadd_fail_send_list()
{
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

generate_web_report()
{
#generate web report
#these exports are used by html_generate.cgi
export SDK_RESULTS_DIR=${CONFIG_RESULT%/*}
export SDKENV_Title=$CONFIG_WEBTITLE
export SDKENV_Project="${CONFIG_ARCH} ${CONFIG_TREEPREFIX} daily build on $HOSTNAME"
export SDKENV_Overview="<pre>Project start on $CONFIG_STARTTIME, done on `date`
`recho_time_consumed $CONFIG_STARTTID all done`</pre>"
export SDKENV_Setting="<pre>Makefile settings:
`make -f $CONFIG_MAKEFILE lsvar`

build script settings:
`set | grep CONFIG_ `
</pre>"
export SDKENV_Server="`whoami` on $CONFIG_MYIP(`hostname`)"
export SDKENV_Script="`readlink -f $0`"
export SDKENV_URLPRE=http://`echo ${CONFIG_LOGSERVER%/*} | sed -e 's,/var/www/html,,g' -e 's,^.*@,,g'`
$CONFIG_GENHTML  > $CONFIG_HTMLFILE
}

generate_email()
{
  #addto_send hguo@c2micro.com
  CONFIG_EMAILTITLE="${CONFIG_ARCH} $CONFIG_TREEPREFIX $HOSTNAME $nr_totalmodule module(s) $nr_totalerror error(s)."
  (
    echo "$CONFIG_EMAILTITLE"
    echo ""
    echo "Get build package at one of these nfs service:"
    for i in $CONFIG_PKGSERVERS; do
        [ "${i:0:1}" = "#" ] && continue; #comment line, invalid
	echo "    ${i##*@}"
    done
    echo ""
    [ $FAILLIST_BUILD            ] && echo "fail in this build: $FAILLIST_BUILD"
    [ $FAILLIST_RESULT    ] && echo "fail in all builds: $FAILLIST_RESULT"
    echo "Click one of these to watch report:"
    for i in  $CONFIG_WEBSERVERS; do
        [ "${i:0:1}" = "#" ] && continue; #comment line, invalid
        echo $i | grep "10.0.5" >/dev/null; #SJ server
        if [ $? -eq 0  ]; then
            u=`echo "${i##*/home/}" | sed 's,/public_html/.*,,g'`
	    echo -en "    https://access.c2micro.com/~$u"
            echo "${i##*/public_html}"
        else
	    echo -en "    http://"
            echo "${i##*@}" | sed 's,:/var/www/html,,g'
        fi
    done
    echo "Click one of these to watch logs:"
    for i in $CONFIG_LOGSERVERS; do
        [ "${i:0:1}" = "#" ] && continue; #comment line, invalid
        echo $i | grep "10.0.5" >/dev/null; #SJ server
        if [ $? -eq 0  ]; then
            u=`echo "${i##*/home/}" | sed 's,/public_html/.*,,g'`
	    echo -en "    https://access.c2micro.com/~$u"
            echo "${i##*/public_html}"
        else
	    echo -en "    http://"
            echo "${i##*@}" | sed 's,:/var/www/html,,g'
        fi
    done
    list_fail_url_tail
    echo ""
    echo "More build environment reference info:"
    make -f $CONFIG_MAKEFILE lsvar
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
    echo "`whoami`,`hostname`($CONFIG_MYIP)"
    echo "`readlink -f $0`"
    date
  ) >$CONFIG_EMAILFILE 2>&1
}

upload_web_report()
{
  if [ $CONFIG_BUILD_PUBLISHHTML ]; then
    for sver in $CONFIG_WEBSERVERS; do
        [ "${i:0:1}" = "#" ] && continue; #comment line, invalid
        h=${sver%%:/*}
        p=${sver##*:}
	f=${p##*/}
	p=${p%/*}
        ip=`echo $sver | sed -e 's,.*@\(.*\):.*,\1,g'`
	if [ "$ip" = "$CONFIG_MYIP" ];then
            mkdir -p $p
            echo "cp -f $CONFIG_HTMLFILE $p/$f"
            cp -f $CONFIG_HTMLFILE $p/$f
        else
            ssh $h mkdir -p $p
	    echo "scp -r $CONFIG_HTMLFILE $sver"
	    scp -r $CONFIG_HTMLFILE $sver
        fi
    done
    echo publish web done.
  fi
}

upload_logs()
{
  if [ $CONFIG_BUILD_PUBLISHLOG ]; then
            if [ $# -gt 0 ]; then
	       echo "logs: $@"
            fi
    unix2dos -q $CONFIG_LOGDIR/*
        [ "${sver:0:1}" = "#" ] && continue; #comment line, invalid
    for sver in $CONFIG_LOGSERVERS; do
        [ "${sver:0:1}" = "#" ] && continue; #comment line, invalid
        h=${sver%%:/*}
        p=${sver##*:}
        ip=`echo $sver | sed -e 's,.*@\(.*\):.*,\1,g'`
	if [ "$ip" = "$CONFIG_MYIP" ];then
            mkdir -p $p
            if [ $# -gt 0 ]; then
	       echo "cp -rf $@ $p/"
	       cp -rf $@ $p/
            else
	       echo "cp -rf $CONFIG_LOGDIR/* $p/"
	       cp -rf $CONFIG_LOGDIR/* $p/
            fi
	else
            ssh $h mkdir -p $p
            if [ $# -gt 0 ]; then
	       echo "scp -r $@ $sver/"
	       scp -r $@ $sver/
            else
	       echo "scp -r $CONFIG_LOGDIR/* $sver/"
	       scp -r $CONFIG_LOGDIR/* $sver/
            fi
	fi
    done
    echo publish log done.
  fi
}

upload_packages()
{
    if [ $CONFIG_BUILD_PUBLISH ]; then
        for sver in $CONFIG_PKGSERVERS; do
            [ "${sver:0:1}" = "#" ] && continue; #comment line, invalid
            h=${sver%%:/*}
            p=${sver##*:}
            ip=`echo $sver | sed -e 's,.*@\(.*\):.*,\1,g'`
            if [ "$ip" = "$CONFIG_MYIP" ];then
                mkdir -p $p
                echo "cp -rf $CONFIG_PKGDIR/* $p/"
                cp -rf $CONFIG_PKGDIR/* $p/
            else
                ssh $h mkdir -p $p
                echo "scp -r $CONFIG_PKGDIR/* $sver/"
                scp -r $CONFIG_PKGDIR/* $sver/
            fi
        done
        echo publish package done.
    fi
}

send_email()
{
    echo email title "$CONFIG_EMAILTITLE"
    if [ $CONFIG_BUILD_PUBLISHEMAIL ]; then
        echo "send to: $CONFIG_MAILLIST"
        cat $CONFIG_EMAILFILE | mail -s"$CONFIG_EMAILTITLE" $CONFIG_MAILLIST
    else
        echo "send to: hguo@c2micro.com(for test only)"
        cat $CONFIG_EMAILFILE | mail -s"$CONFIG_EMAILTITLE" hguo@c2micro.com
    fi
    echo send mail done.
}

#set -ex
nr_failurl=0          #set in list_fail_url_tail
nr_totalerror=0       #set in build_modules_x_steps
nr_totalmodule=0      #set in nr_totalmodule
tm_total=`date +%s`   #for time stat
modules=xxx           #for place holder
steps=help            #for place holder
build_modules_x_steps()
{
    for xmod in ${modules}; do
        nr_merr=0
        tm_module=`date +%s`

        #let web know this module is in "doing" status:2
        update_indexlog "$xmod:2:$CONFIG_LOGDIR/$xmod.log" $CONFIG_INDEXLOG
        generate_web_report
        upload_web_report

        for s in ${steps}; do
            iserror=0
            echo -en `date +"%Y-%m-%d %H:%M:%S"` build ${s}_$xmod " "
            tm_a=`date +%s`
            echo `date +"%Y-%m-%d %H:%M:%S"` Start build  ${s}_$xmod >>$CONFIG_LOGDIR/progress.log
            make -f $CONFIG_MAKEFILE ${s}_$xmod        >>$CONFIG_LOGDIR/$xmod.log 2>&1
            if [ $? -ne 0 ];then
                nr_merr=$((nr_merr+1))
                iserror=$((iserror+1))
            fi
            echo `date +"%Y-%m-%d %H:%M:%S"` Done build  ${s}_$xmod, $nr_merr error >>$CONFIG_LOGDIR/progress.log
            recho_time_consumed $tm_a "$s: $iserror error(s). "  
            if [ $nr_merr -ne 0 ];then
                break;
            fi
        done
        if [ $nr_merr -ne 0 ];then
            addto_buildfail $xmod
            upload_logs $CONFIG_LOGDIR/$xmod.log
        fi
        nr_totalerror=$((nr_totalerror+nr_merr))
        nr_totalmodule=$((nr_totalmodule+1))
        update_indexlog "$xmod:$nr_merr:$CONFIG_LOGDIR/$xmod.log" $CONFIG_INDEXLOG

        echo recho_time_consumed $tm_module "Build module $xmod $nr_merr error(s). "
        echo "    "
    done
}

setup_build_jazz2t_sw_media_env()
{
[ -d android ] || echo "Error, no android project folder found"
export ANDROID_HOME=`readlink -f android`
export ANDROID_BUILD=1
#next added by Ben Cang.
export UPNP_SUPPORT=1
export D_EN_RTP=Y
#next added by Westwood
export PATH=/c2/local/c2/sw_media/android_toolchain_jazz2t/bin/:$PATH
export TARGET_ARCH=JAZZ2T; 
export BUILD_TARGET=TARGET_LINUX_C2; 
export BUILD=RELEASE;
export BOARD_TARGET=C2_CC302; #add this for safe build jazz2t-android-sw_media
}

# let's go!
#---------------------------------------------------------------
lock_job
make -f $CONFIG_MAKEFILE sdk_folders
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
    checkout_from_repositories
fi
create_repo_checkout_script `make -f $CONFIG_MAKEFILE SOURCE_DIR` $CONFIG_PKGDIR/checkout-gits-tags.sh

if [ $CONFIG_BUILD_SWMEDIA ]; then
    [ -h local.rules.mk ] && rm local.rules.mk
    ln -s jazz2t.rules.mk local.rules.mk
    modules="sw_mediaandroid"
    steps="src_get src_package src_install src_config src_build bin_package bin_install "
    setup_build_jazz2t_sw_media_env
    build_modules_x_steps

    r=`grep ^sw_mediaandroid:0 $CONFIG_INDEXLOG`
    if [ "$r" != "" ]; then
        rm -rf android/prebuilt/sw_media
        mkdir -p android/prebuilt/sw_media
        tar xzf $CONFIG_PKGDIR/c2-*-sw_media*bin*.tar.gz -C android/prebuilt/sw_media
    fi
fi

if [ $CONFIG_BUILD_XXX ]; then  #script debug code
    modules="xxx"
    #modules="devtools sw_media qt470 kernel kernelnand kernela2632 uboot vivante hdmi c2box jtag diag c2_goodies facudisk usrudisk"
    steps="src_get src_package src_install src_config src_build bin_package bin_install "
    build_modules_x_steps
fi
modules=
[ $CONFIG_BUILD_FACUDISK ] && modules="$modules facudisk"
[ $CONFIG_BUILD_USRUDISK ] && modules="$modules usrudisk"
steps="src_get src_package src_install src_config src_build bin_package bin_install "
if [ "$modules" != "" ]; then
    dep_fail=0
    r=`grep ^c2box:0 $CONFIG_INDEXLOG`
    j=`grep ^uboot:0 $CONFIG_INDEXLOG`
    k=`grep ^kernel:0 $CONFIG_INDEXLOG`
    [ "$r" = "" ] && dep_fail=$((dep_fail+1))
    [ "$j" = "" ] && dep_fail=$((dep_fail+1))
    [ "$k" = "" ] && dep_fail=$((dep_fail+1))
    if [ $dep_fail -eq 0 ]; then
        build_modules_x_steps
    else
        echo can not build facudisk or usrudisk, depend steps: c2box uboot kernel
    fi
fi

checkadd_fail_send_list
[ $nr_failurl    -gt 0 ] && CONFIG_BUILD_PUBLISH=
[ $nr_totalerror -gt 0 ] && CONFIG_BUILD_PUBLISH=
generate_web_report
generate_email
upload_web_report
send_email
upload_packages
upload_logs
rm -rf $lock
