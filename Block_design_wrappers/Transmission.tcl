
################################################################
# This is a generated script based on design: Transmission
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2023.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source Transmission_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# SpW_gen, spwr_ip, spwr_ip, FIFO_stream

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu7ev-ffvc1156-2-e
   set_property BOARD_PART xilinx.com:zcu104:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name Transmission

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axis_data_fifo:2.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
SpW_gen\
spwr_ip\
spwr_ip\
FIFO_stream\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set Clk [ create_bd_port -dir I Clk ]
  set Reset_n [ create_bd_port -dir I Reset_n ]

  # Create instance: SpW_gen_0, and set properties
  set block_name SpW_gen
  set block_cell_name SpW_gen_0
  if { [catch {set SpW_gen_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $SpW_gen_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: spwr_ip_0, and set properties
  set block_name spwr_ip
  set block_cell_name spwr_ip_0
  if { [catch {set spwr_ip_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $spwr_ip_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: spwr_ip_1, and set properties
  set block_name spwr_ip
  set block_cell_name spwr_ip_1
  if { [catch {set spwr_ip_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $spwr_ip_1 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_0 ]
  set_property -dict [list \
    CONFIG.HAS_TLAST {1} \
    CONFIG.HAS_TSTRB {1} \
  ] $axis_data_fifo_0


  # Create instance: FIFO_stream_1, and set properties
  set block_name FIFO_stream
  set block_cell_name FIFO_stream_1
  if { [catch {set FIFO_stream_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $FIFO_stream_1 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create interface connections
  connect_bd_intf_net -intf_net FIFO_stream_1_M_AXIS [get_bd_intf_pins axis_data_fifo_0/S_AXIS] [get_bd_intf_pins FIFO_stream_1/M_AXIS]

  # Create port connections
  connect_bd_net -net Clk_1 [get_bd_ports Clk] [get_bd_pins SpW_gen_0/Clk] [get_bd_pins spwr_ip_0/Clk] [get_bd_pins spwr_ip_1/Clk] [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins FIFO_stream_1/clk]
  connect_bd_net -net Data_Generator_1_Link_start_out [get_bd_pins SpW_gen_0/Link_start_out] [get_bd_pins spwr_ip_0/Link_start] [get_bd_pins spwr_ip_1/Link_start]
  connect_bd_net -net Data_Generator_1_auto_start_out [get_bd_pins SpW_gen_0/auto_start_out] [get_bd_pins spwr_ip_0/auto_start] [get_bd_pins spwr_ip_1/auto_start]
  connect_bd_net -net Data_Generator_1_link_Enabled_out [get_bd_pins SpW_gen_0/link_Enabled_out] [get_bd_pins spwr_ip_0/link_Enabled] [get_bd_pins spwr_ip_1/link_Enabled]
  connect_bd_net -net FIFO_stream_1_Rx_Rd_n [get_bd_pins FIFO_stream_1/Rx_Rd_n] [get_bd_pins spwr_ip_1/Rx_Rd_n]
  connect_bd_net -net Reset_n_1 [get_bd_ports Reset_n] [get_bd_pins SpW_gen_0/Reset_n] [get_bd_pins spwr_ip_0/Reset_n] [get_bd_pins spwr_ip_1/Reset_n] [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins FIFO_stream_1/reset_n]
  connect_bd_net -net SpW_gen_0_Din [get_bd_pins SpW_gen_0/Din] [get_bd_pins spwr_ip_0/Tx_Din]
  connect_bd_net -net SpW_gen_0_Din_2 [get_bd_pins SpW_gen_0/Din_2] [get_bd_pins spwr_ip_1/Tx_Din]
  connect_bd_net -net SpW_gen_0_Rx_Rd_n [get_bd_pins SpW_gen_0/Rx_Rd_n] [get_bd_pins spwr_ip_0/Rx_Rd_n]
  connect_bd_net -net SpW_gen_0_Send_Time_n [get_bd_pins SpW_gen_0/Send_Time_n] [get_bd_pins spwr_ip_0/Tx_Send_Time] [get_bd_pins spwr_ip_1/Tx_Send_Time]
  connect_bd_net -net SpW_gen_0_Time_Code [get_bd_pins SpW_gen_0/Time_Code] [get_bd_pins spwr_ip_0/Tx_Time_Code] [get_bd_pins spwr_ip_1/Tx_Time_Code]
  connect_bd_net -net SpW_gen_0_Wr_n [get_bd_pins SpW_gen_0/Wr_n] [get_bd_pins spwr_ip_0/Tx_Wr_n]
  connect_bd_net -net SpW_gen_0_Wr_n_2 [get_bd_pins SpW_gen_0/Wr_n_2] [get_bd_pins spwr_ip_1/Tx_Wr_n]
  connect_bd_net -net SpW_gen_0_data_in_FIFO [get_bd_pins SpW_gen_0/data_in_FIFO]
  connect_bd_net -net SpW_gen_0_wd_timeout [get_bd_pins SpW_gen_0/wd_timeout] [get_bd_pins spwr_ip_0/wd_timeout] [get_bd_pins spwr_ip_1/wd_timeout]
  connect_bd_net -net spwr_ip_0_Dout [get_bd_pins spwr_ip_0/Dout] [get_bd_pins spwr_ip_1/Din]
  connect_bd_net -net spwr_ip_0_Sout [get_bd_pins spwr_ip_0/Sout] [get_bd_pins spwr_ip_1/Sin]
  connect_bd_net -net spwr_ip_0_Tx_Full_n [get_bd_pins spwr_ip_0/Tx_Full_n] [get_bd_pins SpW_gen_0/Full_n]
  connect_bd_net -net spwr_ip_0_short_got_null_n [get_bd_pins spwr_ip_0/short_got_null_n]
  connect_bd_net -net spwr_ip_1_Dout [get_bd_pins spwr_ip_1/Dout] [get_bd_pins spwr_ip_0/Din]
  connect_bd_net -net spwr_ip_1_Rx_Dout [get_bd_pins spwr_ip_1/Rx_Dout] [get_bd_pins FIFO_stream_1/data_in_Rx]
  connect_bd_net -net spwr_ip_1_Rx_Empty_n [get_bd_pins spwr_ip_1/Rx_Empty_n] [get_bd_pins FIFO_stream_1/write_en]
  connect_bd_net -net spwr_ip_1_Sout [get_bd_pins spwr_ip_1/Sout] [get_bd_pins spwr_ip_0/Sin]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


