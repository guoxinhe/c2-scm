#!/bin/sh

. ~/.bash_profile

[ -h build.config ] || ln -s sdkmake/config_jazz2.daily.mk build.config
[ -h build.rules  ] || ln -s sdkmake/config_jazz2.rules.mk build.rules
[ -h Makefile     ] || ln -s sdkmake/Makefile.mk           Makefile
[ -h newbuild.sh  ] || ln -s sdkmake/newbuild.sh           newbuild.sh
[ -h bc.mk        ] || ln -s sdkmake/config_jazz2.daily.mk bc.mk
[ -h br.mk        ] || ln -s sdkmake/config_jazz2.rules.mk br.mk

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

if [ "$1" == "init" ]; then
  make clean
  rm -rf log
  lcp /sdk/jazz2/dev/weekly/110330 jazz2-sdk-110330
  make bin_install_devtools
  shift
fi

config_enable_clean=
config_enable_src_get=
config_enable_src_package=y
config_enable_src_install=
config_enable_src_config=
config_enable_src_build=
config_enable_bin_package=
config_enable_bin_install=
log=`pwd`/log   #/`date +%y%m%d`
mkdir -p $log 
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

      echo -en `date +"%Y-%m-%d %H:%M:%S"` build ${s}_$i
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
  nr_totalerror=$((nr_totalerror+nr_merr))
  nr_totalmodule=$((nr_totalmodule+1))
  #echo "$i:$nr_merr:$log/$i.log" >>$log/r.txt
  update_indexlog "$i:$nr_merr:$log/$i.log" $log/r.txt
  recho_time_consumed $tm_module "Build module $i $nr_merr error(s). "
done

recho_time_consumed $tm_total "Build all $nr_totalmodule module(s) $nr_totalerror error(s). "

