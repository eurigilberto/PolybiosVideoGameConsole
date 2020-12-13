##!/bin/csh -f
##****************************************************************************
## (c) Copyright 2009 Xilinx, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of Xilinx, Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## Xilinx, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) Xilinx shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or Xilinx had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## Xilinx products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of Xilinx products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.
##
##****************************************************************************
##   ____  ____
##  /   /\/   /
## /___/  \  /    Vendor                : Xilinx
## \   \   \/     Version               : 3.92
##  \   \         Application           : MIG
##  /   /         Filename              : rem_files.bat
## /___/   /\     Date Last Modified    : $Date: 2011/06/02 07:17:21 $
## \   \  /  \    Date Created          : Fri Feb 06 2009
##  \___\/\___\
##
## Device            : Spartan-6
## Design Name       : DDR/DDR2/DDR3/LPDDR
## Purpose           : Batch file to remove files generated from ISE
## Reference         :
## Revision History  :
##****************************************************************************

rm -rf "../synth/__projnav" 
rm -rf "../synth/xst" 
rm -rf "../synth/_ngo" 

rm -rf tmp 
rm -rf _xmsgs
rm -rf ila_xdb 
rm -rf icon_xdb
rm -rf vio_xdb

rm -rf xlnx_auto_0_xdb 

rm -rf vio_xmdf.tcl
rm -rf vio_readme.txt
rm -rf vio_flist.txt
rm -rf vio.xise del
rm -rf vio.xco del
rm -rf vio.ngc del
rm -rf vio.ise del
rm -rf vio.gise del
rm -rf vio.cdc del

rm -rf coregen.cgp
rm -rf coregen.cgc
rm -rf coregen.log 
rm -rf ila.cdc 
rm -rf ila.gise 
rm -rf ila.ise 
rm -rf ila.ngc 
rm -rf ila.xco 
rm -rf ila.xise 
rm -rf ila_flist.txt 
rm -rf ila_readme.txt 
rm -rf ila_xmdf.tcl 

rm -rf icon.asy
rm -rf icon.gise
rm -rf icon.ise
rm -rf icon.ncf
rm -rf icon.ngc
rm -rf icon.xco
rm -rf icon.xise
rm -rf icon_flist.txt
rm -rf icon_readme.txt
rm -rf icon_xmdf.tcl

rm -rf ise_flow_results.txt 
rm -rf LPDDR_vhdl.prj 
rm -rf mem_interface_top.syr 
rm -rf LPDDR.ngc 
rm -rf LPDDR.ngr 
rm -rf LPDDR_xst.xrpt 
rm -rf LPDDR.bld 
rm -rf LPDDR.ngd 
rm -rf LPDDR_ngdbuild.xrpt 
rm -rf LPDDR_map.map 
rm -rf LPDDR_map.mrp 
rm -rf LPDDR_map.ngm 
rm -rf LPDDR.pcf 
rm -rf LPDDR_map.ncd 
rm -rf LPDDR_map.xrpt 
rm -rf LPDDR_summary.xml 
rm -rf LPDDR_usage.xml 
rm -rf LPDDR.ncd 
rm -rf LPDDR.par 
rm -rf LPDDR.xpi 
rm -rf LPDDR.ptwx 
rm -rf LPDDR.pad 
rm -rf LPDDR.unroutes 
rm -rf LPDDR_pad.csv 
rm -rf LPDDR_pad.txt 
rm -rf LPDDR_par.xrpt 
rm -rf LPDDR.twx 
rm -rf LPDDR.bgn 
rm -rf LPDDR.twr 
rm -rf LPDDR.drc 
rm -rf LPDDR_bitgen.xwbt
rm -rf LPDDR.bit 

# Files and folders generated by create ise
rm -rf test_xdb
rm -rf _xmsgs
rm -rf test.gise
rm -rf test.xise
rm -rf test.xise

# Files and folders generated by ISE through GUI mode
rm -rf _ngo
rm -rf xst
rm -rf LPDDR.lso 
rm -rf LPDDR.prj 
rm -rf LPDDR.xst 
rm -rf LPDDR.stx 
rm -rf LPDDR_prev_built.ngd 
rm -rf test.ntrc_log 
rm -rf LPDDR_guide.ncd 
rm -rf LPDDR.cmd_log 
rm -rf LPDDR_summary.html 
rm -rf LPDDR.ut 
rm -rf par_usage_statistics.html
rm -rf usage_statistics_webtalk.html
rm -rf webtalk.log
rm -rf device_usage_statistics.html 
