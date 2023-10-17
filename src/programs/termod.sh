#!/bin/sh
# Termux Modder
# an applet that customizes the unix environment of termux app
# powered by ayaka7452
# * binloader mod *

# imports env
modid=Termod
defpath=`cat /data/binloader/configs/defpath`
modpath=$defpath/mods/$modid
tfd=/data/data/com.termux/files/usr


if [ ! -d $modpath/tmods ]; then
 mkdir $modpath/tmods
fi

# change workdir
cd $defpath/tmp


# global variables
# core package data tags
reset_cpdt() {
 pkgname=""
 pkgtype=""
 pkgver=""
 restorable=""
}
reset_cpdt


# fore env checks
if [ ! -d /data/data/com.termux ]; then
 echo "err: termux app is not installed"
 exit
fi


# read_meta [pkginfo_file_path]
# $1 is for meta path
# $2 is for respones or not
# $2: 0-no_respones|1-get_ui_respones
# $3 is for confirmation choice ui
# $3: ui_choi-enabled|n/a-disabled
read_meta() {

 # file check
 if [ ! -f $1 ]; then
  echo "err: unable to locate metadata"
  exit
 fi
 
 # read core tags
 pkgname=`cat $1|grep pkgname|cut -d '[' -f2|cut -d ']' -f1`
 pkgtype=`cat $1|grep pkgtype|cut -d '[' -f2|cut -d ']' -f1`
 pkgver=`cat $1|grep version|cut -d '[' -f2|cut -d ']' -f1`
 restorable=`cat $1|grep restorable|cut -d '[' -f2|cut -d ']' -f1`
 
 # verify if core tags are exist
 if [ ! -n $pkgname -o ! -n $pkgtype -o ! -n $pkgver -o ! -n $restorable ]; then
  echo "err: invalid metadata format"
  exit
 fi

 # verify pkg type
 if [ "$pkgtype" != "tmod" ]; then
  echo "err: unsupported package type"
  exit
 fi
 
 # respones metadata
 case $2 in
 1)
  echo "patch package metadata:"
  echo "name: "$pkgname
  echo "version: "$pkgver
  echo "pkgtype: "$pkgtype
  echo "restorable: "$restorable
 ;;
 esac
 
 # confirmation ui
 case $3 in
 ui_choi)
  if [ -d $modpath/tmods/$pkgname ]; then
   echo "detected a installed version of this package"
   echo -n "replace the exist package?(y,n)"
  else
   echo -n "procceed installation?(y,n)"
  fi
  read choi
  case $choi in
   y)
    if [ -d $modpath/tmods/$pkgname ]; then
     echo "removed old package"
     rm -rf $modpath/tmods/$pkgname
    fi
   ;;
   *)
    echo "aborted"
    exit
   ;;
  esac
 ;;
 esac

}


# clean up
# hard cored pathes to avoid accidents
clean_up() {

 # removals
 if [ -f /data/binloader/tmp/preinst.tar ]; then
  rm /data/binloader/tmp/preinst.tar
 fi
 if [ -d /data/binloader/tmp/programs ]; then
  rm -rf /data/binloader/tmp/programs
 fi
 if [ -f /data/binloader/tmp/pkginfo ]; then
  rm /data/binloader/tmp/pkginfo
 fi
 

}


# installs patches to loader
# $1 is for patch package path
install() {

 clean_up
 
 # error checks
 if [ ! -f $1 ]; then
  echo "err: file not found"
  exit
 fi
 case $1 in
 "")
  echo "err: empty target"
  exit
  ;;
 esac
 
 # unpack package
 cp $1 $defpath/tmp/preinst.tar
 tar -xvf $defpath/tmp/preinst.tar >/dev/null
 
 # check core files
 if [ ! -d $defpath/tmp/programs ]; then
  echo "err: broken package arch"
  exit
 fi
 if [ ! -f $defpath/tmp/programs/patch.sh ]; then
  echo "err: patcher not found"
  exit
 fi
 
 read_meta $defpath/tmp/pkginfo 1 ui_choi
 
 # installs
 echo "installing patch package "$pkgname
 # create moddir
 mkdir $modpath/tmods/$pkgname
 cp -r $defpath/tmp/programs/* $modpath/tmods/$pkgname/
 cp $defpath/tmp/pkginfo $modpath/tmods/$pkgname/pkginfo
 chmod -R 0755 $modpath/tmods/$pkgname/*
 
 echo "successfully installed "$pkgname
 clean_up
 exit
 

}


# remove a installed package
# $1 is for target modid
remove() {

 # blank detection
 case $1 in
 "")
  echo "err: empty modid"
  exit
  ;;
 esac

 if [ -d $modpath/tmods/$1 ]; then
  rm -rf $modpath/tmods/$1
 else
  echo "err: no such mod"
  exit
 fi
 
 echo "removed tmod package "$1
 
 exit

}


# perform patch to termux
# $1 is for target modid
patch() {

 # error checks
 if [ ! -d $modpath/tmods/$1 ]; then
  echo "err: mod not found"
  exit
 fi
 case $1 in
 "")
  echo "err: missing operand"
  exit
  ;;
 esac
 
 # security confirmation
 reset_cpdt
 read_meta $modpath/tmods/$1/pkginfo 0
 case $restorable in
 False)
  echo "warn: this patch cannot be undone unless resetting the appdata of termux"
  echo -n "procceed this patch?(y,n)"
  read choi
  case $choi in
  y)
   :
  ;;
  *)
   echo "aborted"
   exit
  ;;
  esac
 ;;
 esac
 
 $modpath/tmods/$1/patch.sh
 echo "executed the patcher of "$1
 
 exit 0

}


# injects specified executables to termux
# $1 is for tmodid
# $2 is for execname/path
# $3 is for target folder
# $3: eg. bin,lib,etc
# $4 is for removal mode(0,1)
inject_bin() {

 # tmod check
 case $1 in
 "")
  echo "err: internal code: INJE1"
  exit
  ;;
 esac
 if [ ! -d $modpath/tmods/$1 ]; then
  echo "err: no such termod patch"
  exit
 fi
 
 # exec check
 case $2 in
 "")
  echo "err: internal code: INJE2"
  exit
  ;;
 esac
 if [ ! -f $modpath/tmods/$1/$2 ]; then
  echo "err: no such executable"
  exit
 fi
 
 # target folder check
 case $3 in
 "")
  echo "err: internal code: INJE3"
  exit
  ;;
 esac
 if [ ! -d $tfd/$3 ]; then
  echo "err: no such target folder"
  exit
 fi
 
 
 bin_exist=0
 # check if exist
 if [ -f $tfd/$3/$2 ]; then
  bin_exist=1
 fi
 
 # removal mode
 case $4 in
 1)
  rm $tfd/$3/$2 # remove old file
  echo "removed exec "$2
  exit
  ;;
 esac
 
 cp $modpath/tmods/$1/$2 $tfd/$3/$2
 
 # perform injection
 case $bin_exist in
 0)
  echo "injected exec "$2
 ;;
 1)
  echo "replaced exec "$2
 ;;
 esac
 
 exit 0
 

}


helpdocs() {

 echo "TERMOD - patch termux with mod packager"
 echo "Usage: termod [Options] [Param]"
 echo "   install - installs a tmod"
 echo "   remove - removes a tmod"
 echo "   patch - perform patch"
 echo "   ls - lists exist pkgs"
 echo "   inject - inject files to termux"
 echo "   help - show help screen"
 echo "Powered by Ayaka7452"
 
 exit 0

}


lspkg() {

 ls $modpath/tmods

}


# commandline responder
case $1 in
ls)
 lspkg
 ;;
install)
 install $2
 ;;
remove)
 remove $2
 ;;
patch)
 patch $2
 ;;
inject)
 inject_bin $2 $3 $4 $5
 ;;
help)
 helpdocs
 ;;
*)
 echo "invalid options"
 ;;
esac

exit 0



