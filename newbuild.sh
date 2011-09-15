#!/bin/sh
#set -ex
#basic settings auto detect, all name with prefix CONFIG_ is reported to web
#---------------------------------------------------------------
CONFIG_SCRIPT=`readlink -f $0`
TOP=${CONFIG_SCRIPT%/*}
cd $TOP

CONFIG_DATE=`date +%y%m%d`
CONFIG_DATEH=`date +%y%m%d.%H`
CONFIG_MYIP=`/sbin/ifconfig eth0|sed -n 's/.*inet addr:\([^ ]*\).*/\1/p'`
CONFIG_STARTTIME=`date`
CONFIG_STARTTID=`date +%s`
if [ -t 1 -o -t 2 ]; then
CONFIG_TTY=y
fi

#---------------------------------------------------------------
CONFIG_BUILDTOP=$TOP
CONFIG_MAKEFILE=Makefile
CONFIG_GENHTML=`pwd`/scm/html_generate.cgi
SDK_VERSION_ALL=`make -f $CONFIG_MAKEFILE SDK_VERSION_ALL`
CONFIG_ARCH=`make -f $CONFIG_MAKEFILE SDK_TARGET_ARCH`  #jazz2 jzz2t jazz2l
CONFIG_PKGDIR=`make -f $CONFIG_MAKEFILE PKG_DIR`
CONFIG_TREEPREFIX=sdkdev               #sdkdev sdkrel anddev andrel, etc, easy to understand
CONFIG_C2GCC_PATH=`readlink -f c2/daily/bin`
CONFIG_C2GCC_VERSION=`$CONFIG_C2GCC_PATH/c2-linux-gcc --version`
CONFIG_KERNEL=`make -f $CONFIG_MAKEFILE SDK_KERNEL_VERSION`
CONFIG_LIBC=uClibc-0.9.27
CONFIG_BRANCH_C2SDK=master  #one of: master, devel, etc.
CONFIG_BRANCH_ANDROID=devel  #one of: master, devel, etc.
CONFIG_CHECKOUT_C2SDK=c2-$SDK_VERSION_ALL-c2sdk-tags.sh
CONFIG_CHECKOUT_ANDROID=c2-$SDK_VERSION_ALL-android-tags.sh
CONFIG_PROJECT=SDK    #one of: SDK, android
CONFIG_USER=$(whoami)
CONFIG_HOSTNAME=$(hostname)
CONFIG_WEBFILE="${CONFIG_ARCH}_${CONFIG_TREEPREFIX}_${HOSTNAME}-sdk_daily.html"
CONFIG_WEBTITLE="${CONFIG_ARCH}_${CONFIG_TREEPREFIX}_${HOSTNAME}-sdk_daily build"
CONFIG_WEBSERVERS="$CONFIG_USER@$CONFIG_MYIP:/var/www/html/$CONFIG_USER/$CONFIG_WEBFILE
                              #build@10.0.5.193:/home/build/public_html/$CONFIG_WEBFILE
"
CONFIG_LOGSERVERS="$CONFIG_USER@$CONFIG_MYIP:/var/www/html/$CONFIG_USER/${CONFIG_ARCH}_${CONFIG_TREEPREFIX}_${HOSTNAME}_logs/$CONFIG_DATE.log
                              #build@10.0.5.193:/home/build/public_html/${CONFIG_ARCH}_${CONFIG_TREEPREFIX}_${HOSTNAME}_logs/$CONFIG_DATE.log
"
CONFIG_PKGSERVERS="            build@10.16.13.195:/sdk-b2/${CONFIG_ARCH}/android-daily/android-${CONFIG_ARCH}-$CONFIG_DATEH
                              #build@10.16.13.195:/sdk-b1/${CONFIG_ARCH}/android-daily/android-${CONFIG_ARCH}-$CONFIG_DATEH
                                 #build@10.16.13.200:/sdk/${CONFIG_ARCH}/android-daily/android-${CONFIG_ARCH}-$CONFIG_DATEH
"
CONFIG_C2LOCALSERVERS="        build@10.16.13.200:/c2/local/c2/sw_media/$CONFIG_DATE-android
"
CONFIG_LOGSERVER=`echo $CONFIG_LOGSERVERS |awk '{print $1}'`
CONFIG_MAILLIST=hguo@c2micro.com
CONFIG_RESULTDIR=$TOP/build_result
CONFIG_RESULT=$CONFIG_RESULTDIR/$CONFIG_DATE
CONFIG_LOGDIR=$CONFIG_RESULTDIR/$CONFIG_DATE.log
CONFIG_INDEXLOG=$CONFIG_RESULTDIR/$CONFIG_DATE.txt
CONFIG_HTMLFILE=$CONFIG_LOGDIR/web.html
CONFIG_EMAILFILE=$CONFIG_LOGDIR/email.txt
CONFIG_EMAILTITLE="$CONFIG_ARCH $CONFIG_TREEPREFIX daily build pass"
CONFIG_PATH=$CONFIG_C2GCC_PATH:$PATH
CONFIG_DEBUG=
CONFIG_BUILD_DRY=
CONFIG_BUILD_HELP=
CONFIG_BUILD_LOCAL=
CONFIG_BUILD_DOTAG=
CONFIG_BUILD_CLEAN=1
CONFIG_BUILD_SDK=
CONFIG_BUILD_CHECKOUT=1
CONFIG_BUILD_PKGSRC=
CONFIG_BUILD_PKGBIN=1
CONFIG_BUILD_DEVTOOLS=
CONFIG_BUILD_SPI=
CONFIG_BUILD_DIAG=
CONFIG_BUILD_JTAG=
CONFIG_BUILD_UBOOT=1
CONFIG_BUILD_C2GOODIES=
CONFIG_BUILD_QT=
CONFIG_BUILD_DOC=
CONFIG_BUILD_KERNEL=
CONFIG_BUILD_HDMI=
CONFIG_BUILD_SWMEDIA=1
CONFIG_BUILD_VIVANTE=
CONFIG_BUILD_C2APPS=
CONFIG_BUILD_FACUDISK=
CONFIG_BUILD_USRUDISK=
CONFIG_BUILD_ANDROIDNAND=1
CONFIG_BUILD_ANDROIDNFS=1
CONFIG_BUILD_XXX=
CONFIG_BUILD_PUBLISH=
CONFIG_BUILD_PUBLISHLOG=1
CONFIG_BUILD_PUBLISHHTML=1
CONFIG_BUILD_PUBLISHEMAIL=
CONFIG_BUILD_PUBLISHC2LOCAL=

#command line parse
while [ $# -gt 0 ] ; do
    case $1 in
    --cp-server) CONFIG_PKGSERVERS=`echo $CONFIG_PKGSERVERS | sed s,#build@10.16.13.200,build@10.16.13.200,g`;shift;;
    --noco)      CONFIG_BUILD_CHECKOUT= ; shift;;
    --help | -h)      CONFIG_BUILD_HELP=y ; shift;;
    --set)
        set | grep CONFIG_ | sed -e 's/'\''//g' -e 's/'\"'//g' -e 's/ \+/ /g';
        exit 0; shift;;
    *) 	echo "not support option: $1"; CONFIG_BUILD_HELP=1;  shift  ;;
    esac
done

#step operations
if test $CONFIG_BUILD_HELP; then
    set | grep CONFIG_ | sed -e 's/'\''//g' -e 's/'\"'//g' -e 's/ \+/ /g';

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
jobtimeout=9000 #new job need about  2.5hours
lock=`pwd`/${0##*/}.lock
unlock_job()
{
  #rm -rf $lock.log #if exist, left for check, will be removed next lock
  rm -rf $lock
}
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
	echo "`date` $CONFIG_USER@$CONFIG_HOSTNAME `readlink -f $0` tid:$$, lock age: $age, life: $jobtimeout" >>$lock.log
        exit 1
    fi
  fi
  rm -rf $lock.log
  echo "`date` $CONFIG_USER@$CONFIG_HOSTNAME `readlink -f $0` tid:$$ " >$lock
  trap unlock_job EXIT
}
remove_outofdate_files()
{(
    outofdate=$((86400*12)); #86400 = 24*60*60
    [ $CONFIG_BUILD_CLEAN ] || return 0

    for i in $CONFIG_ARCH-sdk-*; do
        burn=`stat -c%Z $i`
        now=`date +%s`
        age=$((now-burn))
        [ "$CONFIG_TTY" = "y" ] && echo "Checking $i"
        if [ $age -gt $outofdate ]; then
            [ "$CONFIG_TTY" = "y" ] && recho_time_consumed $burn "Delete file $i :"
            rm -rf $i
        fi
    done

    outofdate=$((86400*28)); #86400 = 24*60*60
    cd ${CONFIG_RESULTDIR}
    for i in `ls`; do
        burn=`stat -c%Z $i`
        now=`date +%s`
        age=$((now-burn))
        [ "$CONFIG_TTY" = "y" ] && echo "Checking $i"
        if [ $age -gt $outofdate ]; then
            [ "$CONFIG_TTY" = "y" ] && recho_time_consumed $burn "Delete file $i :"
            rm -rf $i
        fi
    done
)}
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
        BLOG=${CONFIG_RESULT}/blog/$CONFIG_DATE-${CONFIG_ARCH}-${CONFIG_TREEPREFIX}-$m.log
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
    tm_days=""
    if [ $tm_h -ge 24 ]; then
      if [ $tm_h -ge 48 ]; then
        tm_days="$((tm_h/24)) days"
      else
        tm_days="1 day"
      fi
        tm_h=$((tm_h%24))
    fi
    shift
    echo "$@" "$tm_c seconds / $tm_days $tm_h:$tm_m:$tm_s (duration)."
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
    if [ $CONFIG_BUILD_CHECKOUT ];then
        pushd `readlink -f source`
        BR=$CONFIG_BRANCH_C2SDK
        echo "ereport: `date` repo start --all $BR"
        repo start $BR --all
        echo "ereport: `date` Start repo sync"
        repo sync
        echo "ereport: `date` repo start --all $BR"
        repo start $BR --all
        echo "ereport: `date` repo forall -c 'git branch'"
        repo forall -c "git branch"
        popd

        pushd `readlink -f android`
        BR=$CONFIG_BRANCH_ANDROID
        echo "ereport: `date` repo start --all $BR"
        repo start $BR --all
        echo "ereport: `date` Start repo sync"
        repo sync
        echo "ereport: `date` repo start --all $BR"
        repo start $BR --all
        echo "ereport: `date` repo forall -c 'git branch'"
        repo forall -c "git branch"
        popd
    fi
}
clean_source_code()
{
    [ $CONFIG_BUILD_CLEAN ] || return 0
        pushd `readlink -f source`
        repo forall -c "git reset --hard; git clean -f -d -x"
        popd

        pushd `readlink -f android`
        repo forall -c "git reset --hard; git clean -f -d -x"
        rm -rf out nfs-droid nand-droid
        popd
}

get_module_cosh()
{
    local mysrc=`readlink -f $1`;
    local mybranch="$2";
    local mycosh="$3";
    local mydbg=
    shift 3;
    local project_list="$@";
    local use_repo=

    pushd $mysrc >/dev/null 2>&1
    if [ "$project_list" = "" ]; then
        if [ -f .repo/project.list ]; then
            project_list=`cat .repo/project.list`
            use_repo="yes";
        else
            if [ -d .git ]; then
                project_list="."
            else
                if [ "$mydbg" = "on" ]; then
                              find . -name \.git -type d | sed -e 's,/.git,,g' -e 's,^./,,g'
                fi
                project_list=`find . -name \.git -type d | sed -e 's,/.git,,g' -e 's,^./,,g'`
            fi
        fi
    fi
    if [ "$project_list" = "" ]; then
        return 0
    fi

    mkdir -p ${mycosh%/*}
    echo "#!/bin/sh"  >$mycosh
    echo "#autocreated script, checkout git by hash ids" >>$mycosh
    echo "#please update code and switch to target branch before run this" >>$mycosh
    echo "#branch name: $mybranch" >>$mycosh
    if [ "$use_repo" = "yes" ]; then
    echo "repo start $mybranch --all" >>$mycosh
    fi
    chmod 755 $mycosh
    for pi in $project_list; do
        cd $mysrc/$pi;
        id=`git log -n 1 | grep ^commit\ | sed 's/commit //g'`;
        pad="$pi";
        while [ ${#pad} -lt 40 ]; do
            pad="$pad ";
        done
        echo "pushd $pad; git checkout $id; popd" >>$mycosh
    done
    popd >/dev/null 2>&1
}
get_module_coid()
{
    local mysrc=`readlink -f $1`
    local mymod=$2;
    local mydbg=
    shift 2
    local project_list="$@"

    pushd $mysrc >/dev/null 2>&1
    if [ "$project_list" = "" ]; then
        if [ -f .repo/project.list ]; then
            project_list=`cat .repo/project.list`
        else
            if [ -d .git ]; then
                project_list="."
            else
                if [ "$mydbg" = "on" ]; then
                              find . -name \.git -type d | sed -e 's,/.git,,g' -e 's,^./,,g'
                fi
                project_list=`find . -name \.git -type d | sed -e 's,/.git,,g' -e 's,^./,,g'`
            fi
        fi
    fi
    if [ "$project_list" = "" ]; then
        echo -en "1000000000_10000000_1000000000000000000000000000000000000000"
        return 0
    fi

    new_revid=0;
    new_revts=0;
    new_revpt=".";

    for pi in $project_list; do
        pushd $mysrc/$pi >/dev/null 2>&1
        revid=`git log -n 1 | grep ^commit\ | sed 's/commit //g'`;
        revts=`git log -n 1 --pretty=format:%ct`;
        if [ $revts -gt $new_revts ]; then
            new_revid=$revid
            new_revts=$revts
            new_revpt=$pi
        fi
        popd >/dev/null 2>&1
    done

    revid=$new_revid;
    pathid=`echo $new_revpt | /usr/bin/md5sum | awk '{printf $1}'`00000000;
    update_id=${new_revts}_${pathid:0:8}_${revid};
    if [ "$mymod" != "" ]; then
    if test -f $CONFIG_RESULTDIR/history/$mymod/coid.sh ; then
    pathid=`cat $CONFIG_RESULTDIR/history/$mymod/coid.sh | /usr/bin/md5sum | awk '{printf $1}'`;
    update_id=${new_revts}_${pathid};
    fi
    fi
    if [ "$mydbg" = "on" ]; then
        echo "The last check out id of module $mysrc is: $update_id"
    fi
    echo -en "$update_id" >$CONFIG_RESULTDIR/history/$mymod/coid
    touch $CONFIG_RESULTDIR/history
    popd >/dev/null 2>&1
}

save_checkout_history()
{
    local mymod=$1;
    local mysrc=$2;
    local mybrc=$3;
    local coid=;
    shift 3
    local all_projects="$@"
    if [ ! -d $mysrc ]; then
        return 0;
    fi
    get_module_cosh $mysrc $mybrc $CONFIG_RESULTDIR/history/$mymod/coid.sh $all_projects;
    get_module_coid $mysrc $mymod $all_projects;
    coid=`cat $CONFIG_RESULTDIR/history/$mymod/coid`;
    mkdir -p $CONFIG_RESULTDIR/history/$mymod/$coid;
    cp $CONFIG_RESULTDIR/history/$mymod/coid    $CONFIG_RESULTDIR/history/$mymod/$coid/
    cp $CONFIG_RESULTDIR/history/$mymod/coid.sh $CONFIG_RESULTDIR/history/$mymod/$coid/

    #for user only
    [ -h $CONFIG_RESULTDIR/history/$mymod/last ] && rm $CONFIG_RESULTDIR/history/$mymod/last
    ln -s $coid $CONFIG_RESULTDIR/history/$mymod/last
    touch $CONFIG_RESULTDIR/history
}
save_build_history()
{
    local mymod=$1;
    local coid=`cat $CONFIG_RESULTDIR/history/$mymod/coid`;
    
    mkdir -p $CONFIG_RESULTDIR/history/$mymod/built
    cp $CONFIG_RESULTDIR/history/$mymod/$coid/coid.sh $CONFIG_RESULTDIR/history/$mymod/built/$coid.sh
    echo "`date`: build done" >>$CONFIG_RESULTDIR/history/$mymod/$coid/progress.log
    touch $CONFIG_RESULTDIR/history
}
check_build_history()
{
    #return: 0: still not build yet
    #else will echo "built", means already built this module
    local mymod=$1;
    local coid=`cat $CONFIG_RESULTDIR/history/$mymod/coid`;
    if [ ! -f $CONFIG_RESULTDIR/history/$mymod/coid ]; then
        return 0;
    fi
    if [ ! -f $CONFIG_RESULTDIR/history/$mymod/coid.sh ]; then
        return 0;
    fi
    if [ ! -f $CONFIG_RESULTDIR/history/$mymod/built/$coid.sh ]; then
        return 0;
    fi
    diff -q $CONFIG_RESULTDIR/history/$mymod/coid.sh $CONFIG_RESULTDIR/history/$mymod/built/$coid.sh >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        return 0;
    fi
    echo -en "built"
}

package_repo_source_code(){(
    mytop=`pwd`
    rdir=`readlink -f $1`
    [ -f $rdir/.repo/project.list ] || return 0
    list=`cat $rdir/.repo/project.list`;
    mkdir -p $2
    p=`readlink -f $2`
    if [ "$CONFIG_TTY" = "y" ]; then
        echo repo dir: $rdir
        echo package dir: $p
    fi
    for i in $list; do
        pn=`echo $i | sed s,/,_,g`
        [ "$CONFIG_TTY" = "y" ] && echo Create: $pn.tar.gz
        case $i in
        prebuilt)
            cd $rdir
            tar czf  $p/$pn.tar.gz\
                    --exclude=.git* --exclude=CVS* \
                    --exclude=i686-unknown-linux-gnu-4.2.1 \
                    --exclude=mips-4.4.3     \
                    --exclude=c2-4.0.3       \
                    --exclude=arm-eabi-4.3.1 \
                    --exclude=arm-eabi-4.2.1 \
                    --exclude=android-arm    \
                    --exclude=android-mips   \
                    --exclude=android-mips   \
                    --exclude=sw_media*      \
                    --exclude=u-boot*        \
                    prebuilt;
                    ;;
        *)
            cd $rdir/$i
            git archive --format=tar --prefix=$i/ HEAD | gzip > $p/$pn.tar.gz
                    ;;
        esac
    done
    cd $mytop
)}
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
#set | grep CONFIG_ | sed -e 's/'\''//g' -e 's/'\"'//g' -e 's/ \+/ /g' >$CONFIG_LOGDIR/env.log;
#generate web report
#these exports are used by html_generate.cgi
export SDK_RESULTS_DIR=${CONFIG_RESULTDIR}
export SDKENV_Title=$CONFIG_WEBTITLE
export SDKENV_Project="${CONFIG_ARCH} ${CONFIG_TREEPREFIX} daily build on $HOSTNAME"
export SDKENV_Overview="<pre>Project start on $CONFIG_STARTTIME, report on `date`
`recho_time_consumed $CONFIG_STARTTID On report time:`</pre>"
export SDKENV_Setting="<pre>
`cat $CONFIG_LOGDIR/env.log`
</pre>"
export SDKENV_Server="$CONFIG_USER on $CONFIG_MYIP($CONFIG_HOSTNAME)"
export SDKENV_Script="`readlink -f $0`"
export SDKENV_URLPRE=http://`echo ${CONFIG_LOGSERVER%/*} | sed -e 's,/var/www/html,,g' -e 's,^.*@,,g'`
export SDKENV_URLPRE=${SDKENV_URLPRE##*/}
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
    echo ""
    echo "For monitor runtime build or rebuild the project: click one of"
    echo "    http://10.16.13.195/build/build.cgi"
    echo "    http://10.16.13.196/build/build.cgi"
    #echo "Check broken log history:  http://10.16.13.196/${USER}/blog"
    echo ""
    echo "Regards,"
    echo "$CONFIG_USER,$CONFIG_HOSTNAME($CONFIG_MYIP)"
    echo "`readlink -f $0`"
    date
  ) >$CONFIG_EMAILFILE 2>&1
}

upload_web_report()
{
  if [ $CONFIG_BUILD_PUBLISHHTML ]; then
    for sver in $CONFIG_WEBSERVERS; do
        [ "${sver:0:1}" = "#" ] && continue; #comment line, invalid
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
    unix2dos -q $CONFIG_LOGDIR/*
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

upload_install_sw_media()
{
    PKG_NAME_BIN_SW_MEDIA=c2-$SDK_VERSION_ALL-sw_media-bin.tar.gz
    #this only appears in ssh, no local enabled.
    if [ $CONFIG_BUILD_PUBLISHC2LOCAL ]; then
        for sver in $CONFIG_C2LOCALSERVERS; do
            [ "${sver:0:1}" = "#" ] && continue; #comment line, invalid
            h=${sver%%:/*}
            p=${sver##*:}
            ip=`echo $sver | sed -e 's,.*@\(.*\):.*,\1,g'`
            if [ "$ip" = "$CONFIG_MYIP" ];then
                echo "do nothing"
            else
                ssh $h mkdir -p $p
                echo "scp -r $CONFIG_PKGDIR/${PKG_NAME_BIN_SW_MEDIA} $sver/"
                scp -r $CONFIG_PKGDIR/${PKG_NAME_BIN_SW_MEDIA} $sver/
                ssh $h "cd $p; tar xzf ${PKG_NAME_BIN_SW_MEDIA}; rm ${PKG_NAME_BIN_SW_MEDIA};"
                scp $CONFIG_PKGDIR/$CONFIG_CHECKOUT_C2SDK  $sver/TARGET_LINUX_C2_JAZZ2T_RELEASE/
                ssh $h "cd $p; chmod -R g+w *"
                if test -d $p/TARGET_LINUX_C2_JAZZ2T_RELEASE/bin -a -d $p/TARGET_LINUX_C2_TANGO_RELEASE/bin; then
                    ssh $h  "cd ${p%/*}; rm daily-android; ln -s ${p##*/}  daily-android;"
                fi
            fi
        done
    fi
    echo publish sw_media package to ${p%/*} done.
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
    local xmod;
    local s;
    for xmod in ${modules}; do
        nr_merr=0
        tm_module=`date +%s`

        #let web know this module is in "doing" status:2
        update_indexlog "$xmod:2:$CONFIG_LOGDIR/$xmod.log" $CONFIG_INDEXLOG
        generate_web_report
        upload_web_report &

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
            upload_logs $CONFIG_LOGDIR/$xmod.log &
        fi
        nr_totalerror=$((nr_totalerror+nr_merr))
        nr_totalmodule=$((nr_totalmodule+1))
        update_indexlog "$xmod:$nr_merr:$CONFIG_LOGDIR/$xmod.log" $CONFIG_INDEXLOG

        echo recho_time_consumed $tm_module "Build module $xmod $nr_merr error(s). "
        echo "    "
    done
}

setup_build_sw_media_for_android_env_jazz2()
{
    [ -d android ] || echo "Error, no android project folder found"
    export ANDROID_HOME=`readlink -f android`
    export ANDROID_BUILD=1
    #next added by Ben Cang.
    export UPNP_SUPPORT=1
    export D_EN_RTP=Y
    #next added by Westwood
    export PATH=$CONFIG_C2GCC_PATH:$PATH
    export TARGET_ARCH=TANGO;
    export BUILD_TARGET=TARGET_LINUX_C2;
    export BUILD=RELEASE;
    export BOARD_TARGET=C2_CC289; #add this for safe build jazz2-android-sw_media
}

setup_build_sw_media_for_android_env_jazz2l()
{
    [ -d android ] || echo "Error, no android project folder found"
    export ANDROID_HOME=`readlink -f android`
    export ANDROID_BUILD=1
    #next added by Ben Cang.
    export UPNP_SUPPORT=1
    export D_EN_RTP=Y
    #next added by Westwood
    export PATH=$CONFIG_C2GCC_PATH:$PATH
    export TARGET_ARCH=JAZZ2L;
    export BUILD_TARGET=TARGET_LINUX_C2;
    export BUILD=RELEASE;
    export BOARD_TARGET=C2_CC289; #add this for safe build jazz2t-android-sw_media
}

setup_build_sw_media_for_android_env_jazz2t()
{
    [ -d android ] || echo "Error, no android project folder found"
    export ANDROID_HOME=`readlink -f android`
    export ANDROID_BUILD=1
    #next added by Ben Cang.
    export UPNP_SUPPORT=1
    export D_EN_RTP=Y
    #next added by Westwood
    export PATH=$CONFIG_C2GCC_PATH:$PATH
    export TARGET_ARCH=JAZZ2T;
    export BUILD_TARGET=TARGET_LINUX_C2;
    export BUILD=RELEASE;
    export BOARD_TARGET=C2_CC302; #add this for safe build jazz2t-android-sw_media
}
prepare_runtime_files()
{
    make -f $CONFIG_MAKEFILE sdk_folders
    mkdir -p $CONFIG_RESULT $CONFIG_LOGDIR
    touch $CONFIG_INDEXLOG
    touch $CONFIG_HTMLFILE
    touch $CONFIG_EMAILFILE
    softlink $CONFIG_INDEXLOG r
    softlink $CONFIG_LOGDIR   l
    softlink $CONFIG_RESULT   i
    softlink $CONFIG_INDEXLOG $CONFIG_RESULTDIR/r
    softlink $CONFIG_LOGDIR   $CONFIG_RESULTDIR/l
    softlink $CONFIG_RESULT   $CONFIG_RESULTDIR/i
    #action parse
    echo "Makefile settings:------------------------------------"  >$CONFIG_LOGDIR/env.log
    make -f $CONFIG_MAKEFILE lsvar >>$CONFIG_LOGDIR/env.log
    echo "Build script settings:--------------------------------" >>$CONFIG_LOGDIR/env.log
    set | grep CONFIG_ | sed -e 's/'\''//g' -e 's/'\"'//g' -e 's/ \+/ /g' >>$CONFIG_LOGDIR/env.log;
}

# let's go!
#---------------------------------------------------------------
lock_job
prepare_runtime_files
[ "$CONFIG_TTY" = "y" ] && cat $CONFIG_LOGDIR/env.log
checkout_from_repositories
get_module_cosh `readlink -f source`  $CONFIG_BRANCH_C2SDK   $CONFIG_PKGDIR/$CONFIG_CHECKOUT_C2SDK
get_module_cosh `readlink -f android` $CONFIG_BRANCH_ANDROID $CONFIG_PKGDIR/$CONFIG_CHECKOUT_ANDROID

save_checkout_history "sw_media" "source/sw_media"     "$CONFIG_BRANCH_C2SDK"
save_checkout_history "uboot"    "source/u-boot-1.3.0" "$CONFIG_BRANCH_C2SDK"
save_checkout_history "android"  "android"             "$CONFIG_BRANCH_C2SDK"

clean_source_code

cd $TOP
[ $CONFIG_BUILD_PKGSRC ] && package_repo_source_code android             $CONFIG_PKGDIR/src-android &

if [ $CONFIG_BUILD_SWMEDIA ]; then
    [ -h local.rules.mk ] && rm local.rules.mk
    case $CONFIG_ARCH in
    jazz2t*)
    ln -s jazz2t.rules.mk local.rules.mk
    setup_build_sw_media_for_android_env_jazz2t
        ;;
    jazz2l*)
        ln -s jazz2l.rules.mk local.rules.mk
        setup_build_sw_media_for_android_env_jazz2l
        ;;
    jazz2* | *)
        ln -s jazz2.rules.mk local.rules.mk
        setup_build_sw_media_for_android_env_jazz2
        ;;
    esac

    modules="sw_mediaandroid"
    steps="src_get src_package src_install src_config src_build bin_package bin_install "
    r=`grep ^sw_mediaandroid: $CONFIG_INDEXLOG`
    if [ "$r" != "" ]; then
        r=`check_build_history sw_media`
        if [ "$r" = "built" ]; then
        echo `date +"%Y-%m-%d %H:%M:%S"` $modules already built, jump rebuild  >>$CONFIG_LOGDIR/progress.log
        steps="help"
        fi
    fi
    build_modules_x_steps

    r=`grep ^sw_mediaandroid:0 $CONFIG_INDEXLOG`
    if [ "$r" != "" ]; then
    if [ "$steps" != "help" ]; then
        rm -rf android/c2sdkbuilt/sw_media
        mkdir -p android/c2sdkbuilt/sw_media
        tar xzf $CONFIG_PKGDIR/c2-*-sw_media*bin*.tar.gz -C android/c2sdkbuilt/sw_media
        sed -i "s,SW_MEDIA_PATH=.*,SW_MEDIA_PATH=`readlink -f android/c2sdkbuilt/sw_media`,g"   android/env.sh
        echo `date +"%Y-%m-%d %H:%M:%S"` sw_media: modify android using c2sdkbuilt/sw_media >>$CONFIG_LOGDIR/progress.log
        upload_install_sw_media &
        r="updated";
        save_build_history sw_media
    fi
    fi
    if [ "$r" != "updated" ]; then
        echo `date +"%Y-%m-%d %H:%M:%S"` no new sw_media used. >>$CONFIG_LOGDIR/progress.log
    fi
fi

if [ $CONFIG_BUILD_UBOOT ]; then
    modules="uboot"
    steps="src_get src_package src_install src_config src_build bin_package bin_install "
    r=`grep ^uboot: $CONFIG_INDEXLOG`
    if [ "$r" != "" ]; then
        r=`check_build_history uboot`
        if [ "$r" = "built" ]; then
        echo `date +"%Y-%m-%d %H:%M:%S"` $modules already built, jump rebuild  >>$CONFIG_LOGDIR/progress.log
        steps="help"
        fi
    fi
    build_modules_x_steps

    r=`grep ^uboot:0 $CONFIG_INDEXLOG`
    if [ "$r" != "" ]; then
    if [ "$steps" != "help" ]; then
        rm -rf   android/c2sdkbuilt/u-boot
        mkdir -p android/c2sdkbuilt/u-boot
        tar xzf $CONFIG_PKGDIR/c2-*-u-boot-bin.tar.gz -C android/c2sdkbuilt/u-boot
        echo `date +"%Y-%m-%d %H:%M:%S"` u-boot: extracted to c2sdkbuilt/u-boot/ >>$CONFIG_LOGDIR/progress.log
        r="updated";
        save_build_history uboot
    fi
    fi
    if [ "$r" != "updated" ]; then
        echo `date +"%Y-%m-%d %H:%M:%S"` no new u-boot used. >>$CONFIG_LOGDIR/progress.log
    fi
fi

if [ $CONFIG_BUILD_ANDROIDNFS ]; then
    modules="nfs_droid"
    steps="src_get src_package src_install src_config src_build bin_package bin_install "
    build_modules_x_steps
fi

if [ $CONFIG_BUILD_ANDROIDNAND ]; then
    modules="nand_droid"
    steps="src_get src_package src_install src_config src_build bin_package bin_install "
    build_modules_x_steps
    cat <<END >>android/nand-droid/run

NAND burn guide:
burn zvmlinux.bin ->NAND + offset   1MB
burn root.image   ->NAND + offset  16MB
burn system.image ->NAND + offset 112MB
burn data.image   ->NAND + offset 368MB

ref c2 wiki: https://access.c2micro.com/index.php/Android#Local_build_and_driver_update

END
    cd $TOP
    #check build result
    if [ -f android/nand-droid/root.image -a -f android/nand-droid/system.image -a -f android/nand-droid/data.image ]; then
        build_fail=
        update_indexlog "nfs_droid:0:$CONFIG_LOGDIR/nfs_droid.log" $CONFIG_INDEXLOG
        update_indexlog "nand_droid:0:$CONFIG_LOGDIR/nand_droid.log" $CONFIG_INDEXLOG

        cp $TOP/android/out/host/linux-x86/bin/mkyaffs2            $TOP/android/nand-droid/
        cp $TOP/android/c2sdkbuilt/u-boot/u-boot-utilities/mkimage $TOP/android/nand-droid/
        cp $TOP/android/build/tools/gen-nand-packages.sh           $TOP/android/nand-droid/
        #for ndk-r5b jazz2t only
        cd android/ndk-r5b
        ./build/tools/release-ndk.sh          -t3o $TOP/android/out/target/product/jazz2t
        cp $TOP/android/android-ndk-r5b-c2-linux.tar.bz2   $CONFIG_PKGDIR/android-ndk-r5b-c2-linux.tar.bz2

        ./build/tools/release-ndk.sh -pu      -t3o $TOP/android/out/target/product/jazz2t
        cp $TOP/android/android-ndk-r5b-c2-linux.tar.bz2   $CONFIG_PKGDIR/android-ndk-r5b-c2-linux-premium.tar.bz2

        ./build/tools/release-ndk.sh -win     -t3o $TOP/android/out/target/product/jazz2t
        cp $TOP/android/android-ndk-r5b-c2-windows.tar.bz2 $CONFIG_PKGDIR/android-ndk-r5b-c2-windows.tar.bz2

        cd $TOP
        cp $TOP/android/out/target/common/obj/JAVA_LIBRARIES/android_stubs_current_intermediates/classes.jar \
           $CONFIG_PKGDIR/android.jar
    else
        CONFIG_BUILD_PUBLISH=
        build_fail="yes"
        update_indexlog "nfs_droid:1:$CONFIG_LOGDIR/nfs_droid.log" $CONFIG_INDEXLOG
        update_indexlog "nand_droid:1:$CONFIG_LOGDIR/nand_droid.log" $CONFIG_INDEXLOG
        nr_totalerror=$((nr_totalerror+1))
        nr_totalerror=$((nr_totalerror+1))
    fi
    #package build files
    mkdir -p $CONFIG_PKGDIR/nand-droid
    cp $CONFIG_PKGDIR/$CONFIG_CHECKOUT_C2SDK   $TOP/android/nand-droid/
    cp $CONFIG_PKGDIR/$CONFIG_CHECKOUT_ANDROID $TOP/android/nand-droid/
    cp -rf $TOP/android/nand-droid/* $CONFIG_PKGDIR/nand-droid/

    nr_totalmodule=$((nr_totalmodule))
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

all_modules="sw_media qt470 kernel kernelnand uboot vivante hdmi c2box jtag diag c2_goodies"
    #                     xxx        source home folder    branch name             [proj list]
    save_checkout_history devtools   source/devtools              $CONFIG_BRANCH_C2SDK
    save_checkout_history sw_media   source/sw_media              $CONFIG_BRANCH_C2SDK
    save_checkout_history qt470      source/sw/Qt                 $CONFIG_BRANCH_C2SDK
    save_checkout_history kernel     source/kernel.sdk/linux-2.6  $CONFIG_BRANCH_C2SDK
    save_checkout_history kernelnand source/kernel.sdk/linux-2.6  $CONFIG_BRANCH_C2SDK
    save_checkout_history uboot      source/u-boot-1.3.0          $CONFIG_BRANCH_C2SDK
    save_checkout_history vivante    source/sw/bsp/vivante        $CONFIG_BRANCH_C2SDK
    save_checkout_history hdmi       source/sw/bsp/hdmi/jazz2hdmi $CONFIG_BRANCH_C2SDK
    save_checkout_history c2box      source/sw_c2apps             $CONFIG_BRANCH_C2SDK
    save_checkout_history jtag       source/sw/jtag               $CONFIG_BRANCH_C2SDK
    save_checkout_history diag       source/sw/prom/diag          $CONFIG_BRANCH_C2SDK
    save_checkout_history c2_goodies source/sw/c2_goodies         $CONFIG_BRANCH_C2SDK
for modules in $all_modules; do
    steps="src_get src_package src_install src_config src_build bin_package bin_install "
    r=`grep ^$modules: $CONFIG_INDEXLOG`
    if [ "$r" != "" ]; then #have already first built today
        r=`check_build_history $modules`
        if [ "$r" = "built" ]; then
        echo `date +"%Y-%m-%d %H:%M:%S"` $modules already built, jump rebuild  >>$CONFIG_LOGDIR/progress.log
        steps=""
        fi
    fi
    if [ "$steps" != "" ]; then
        build_modules_x_steps
        save_build_history $modules
    fi
done

if [ $CONFIG_BUILD_XXX ]; then  #script debug code
    modules="xxx"
    #modules="devtools sw_media qt470 kernel kernelnand kernela2632 uboot vivante hdmi c2box jtag diag c2_goodies facudisk usrudisk"
    steps="src_get src_package src_install src_config src_build bin_package bin_install "
    build_modules_x_steps
fi

checkadd_fail_send_list
[ $nr_failurl    -gt 0 ] && CONFIG_BUILD_PUBLISH=
[ $nr_totalerror -gt 0 ] && CONFIG_BUILD_PUBLISH=
generate_web_report
generate_email
upload_web_report
upload_packages
send_email
unlock_job
upload_logs &
remove_outofdate_files  &
