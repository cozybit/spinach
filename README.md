Plantmesh:
==========

This project contains all the necessary components for the PlantMesh project.

Components:
===========

scripts/	- set of script to make the dev process fast.
targets/	- different config files, tools, etc needed by each target.
kernel/		- external kernel based on open80211s.

Initial Setup:
==============

- Fetch the code:

   $ ./scripts/fetch.sh

Building:
=========

- Select a target you are going to work with and  configure it:

  $ ./scripts/configure -t <target>

  Supported targets: node, station and core

- Build it:

  $ ./scripts/build.sh

  If everything went well, the firmware will be available in the next folder:
  
  openwrt/bin/ar71xx

- Push it:

  $ ./scripts/push.sh -h <spinach host> -f <sysupgrade fw .bin>

- Creat a release:

  $ ./scripts/release.sh -t <node type> -v <version>

  The openwrt images will end up in "releases/<version>/<type>/"



Development:
============

OpenWrt imports the different configurations directly from the /targets/<name>
folder.

Developers can work directly in that folder when updating the configuration,
packages, etc

Compat-Wireles:
===============

In order to bring the latest mesh features to the openwrt kernel, a
compat-wireless drop has been generated. This compat-wireless drop is based on the
last release of wireless-testing/open80211s kernels.

Before creating a release, the maintainer should create a new drop of
compat-wireless, test it and commit it to the project.

Other Documentation:
===================

For documentation about this project, please visit the Wiki on the github site:

