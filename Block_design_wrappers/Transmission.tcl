
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
# Slicer, Concat, Rx, Tx, fsm, twodomainclock, RMAP_Decoder, FIFO_stream, FIFO_stream, SpW_gen, spwr_ip, spwr_ip, Rx_Fifo, Tx_Fifo, Data_Generator

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
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
Slicer\
Concat\
Rx\
Tx\
fsm\
twodomainclock\
RMAP_Decoder\
FIFO_stream\
FIFO_stream\
SpW_gen\
spwr_ip\
spwr_ip\
Rx_Fifo\
Tx_Fifo\
Data_Generator\
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

  # Create instance: Slicer_0, and set properties
  set block_name Slicer
  set block_cell_name Slicer_0
  if { [catch {set Slicer_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $Slicer_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: Concat_0, and set properties
  set block_name Concat
  set block_cell_name Concat_0
  if { [catch {set Concat_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $Concat_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: Rx_0, and set properties
  set block_name Rx
  set block_cell_name Rx_0
  if { [catch {set Rx_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $Rx_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: Tx_0, and set properties
  set block_name Tx
  set block_cell_name Tx_0
  if { [catch {set Tx_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $Tx_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: fsm_0, and set properties
  set block_name fsm
  set block_cell_name fsm_0
  if { [catch {set fsm_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $fsm_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: twodomainclock_0, and set properties
  set block_name twodomainclock
  set block_cell_name twodomainclock_0
  if { [catch {set twodomainclock_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $twodomainclock_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.N_short_to_width {2} \
    CONFIG.N_short_to_width_n {2} \
    CONFIG.N_width_to_short {2} \
    CONFIG.N_width_to_short_n {9} \
    CONFIG.use_width_to_short_n {1} \
  ] $twodomainclock_0


  # Create instance: RMAP_Decoder_0, and set properties
  set block_name RMAP_Decoder
  set block_cell_name RMAP_Decoder_0
  if { [catch {set RMAP_Decoder_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $RMAP_Decoder_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: FIFO_stream_0, and set properties
  set block_name FIFO_stream
  set block_cell_name FIFO_stream_0
  if { [catch {set FIFO_stream_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $FIFO_stream_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
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
    set_property CONFIG.WITH_DECODER {"0"} $FIFO_stream_1


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
  
  # Create instance: Rx_Fifo_0, and set properties
  set block_name Rx_Fifo
  set block_cell_name Rx_Fifo_0
  if { [catch {set Rx_Fifo_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $Rx_Fifo_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.LENGTH {128} \
    CONFIG.MAX_CREDIT {56} \
    CONFIG.WIDTH {9} \
  ] $Rx_Fifo_0


  # Create instance: Tx_Fifo_0, and set properties
  set block_name Tx_Fifo
  set block_cell_name Tx_Fifo_0
  if { [catch {set Tx_Fifo_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $Tx_Fifo_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.LENGTH {128} \
    CONFIG.MAX_CREDIT {56} \
    CONFIG.WIDTH {9} \
  ] $Tx_Fifo_0


  # Create instance: Data_Generator_0, and set properties
  set block_name Data_Generator
  set block_cell_name Data_Generator_0
  if { [catch {set Data_Generator_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $Data_Generator_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create port connections
  connect_bd_net -net Clk_1 [get_bd_ports Clk] [get_bd_pins Rx_0/Clk] [get_bd_pins fsm_0/Clk] [get_bd_pins twodomainclock_0/Clk_speed] [get_bd_pins RMAP_Decoder_0/clk] [get_bd_pins FIFO_stream_0/clk] [get_bd_pins FIFO_stream_1/clk] [get_bd_pins SpW_gen_0/Clk] [get_bd_pins spwr_ip_0/Clk] [get_bd_pins spwr_ip_1/Clk] [get_bd_pins Tx_0/Tx_Clk] [get_bd_pins Rx_Fifo_0/Clk] [get_bd_pins Tx_Fifo_0/Clk] [get_bd_pins Data_Generator_0/Clk]
  connect_bd_net -net Concat_0_output_vector [get_bd_pins Concat_0/output_vector] [get_bd_pins twodomainclock_0/in_width_pulse_n]
  connect_bd_net -net Data_Generator_0_Din [get_bd_pins Data_Generator_0/Din] [get_bd_pins Tx_Fifo_0/Din]
  connect_bd_net -net Data_Generator_0_Remote_Reset_n [get_bd_pins Data_Generator_0/Remote_Reset_n] [get_bd_pins Rx_0/Reset_n]
  connect_bd_net -net Data_Generator_0_Send_Time_n [get_bd_pins Data_Generator_0/Send_Time_n] [get_bd_pins Tx_0/Send_Time_n]
  connect_bd_net -net Data_Generator_0_Time_Code [get_bd_pins Data_Generator_0/Time_Code] [get_bd_pins Tx_0/Time_Code]
  connect_bd_net -net Data_Generator_0_Wr_n [get_bd_pins Data_Generator_0/Wr_n] [get_bd_pins Tx_Fifo_0/Wr_n]
  connect_bd_net -net Data_Generator_0_data_in_Rx [get_bd_pins Data_Generator_0/data_in_Rx] [get_bd_pins FIFO_stream_0/data_in_Rx]
  connect_bd_net -net Data_Generator_0_in_short_pulse [get_bd_pins Data_Generator_0/in_short_pulse] [get_bd_pins twodomainclock_0/in_short_pulse]
  connect_bd_net -net Data_Generator_0_in_short_pulse_n [get_bd_pins Data_Generator_0/in_short_pulse_n] [get_bd_pins twodomainclock_0/in_short_pulse_n]
  connect_bd_net -net Data_Generator_0_in_width_pulse [get_bd_pins Data_Generator_0/in_width_pulse] [get_bd_pins twodomainclock_0/in_width_pulse]
  connect_bd_net -net Data_Generator_0_linkEnabled [get_bd_pins Data_Generator_0/linkEnabled] [get_bd_pins fsm_0/linkEnabled]
  connect_bd_net -net Data_Generator_0_m_axis_tready [get_bd_pins Data_Generator_0/m_axis_tready] [get_bd_pins FIFO_stream_0/m_axis_tready]
  connect_bd_net -net Data_Generator_0_send_esc [get_bd_pins Data_Generator_0/send_esc] [get_bd_pins Tx_0/send_esc]
  connect_bd_net -net Data_Generator_0_wd_timeout [get_bd_pins Data_Generator_0/wd_timeout] [get_bd_pins Rx_0/wd_timeout]
  connect_bd_net -net Data_Generator_1_Link_start_out [get_bd_pins SpW_gen_0/Link_start_out] [get_bd_pins spwr_ip_0/Link_start] [get_bd_pins spwr_ip_1/Link_start]
  connect_bd_net -net Data_Generator_1_auto_start_out [get_bd_pins SpW_gen_0/auto_start_out] [get_bd_pins spwr_ip_0/auto_start] [get_bd_pins spwr_ip_1/auto_start]
  connect_bd_net -net Data_Generator_1_link_Enabled_out [get_bd_pins SpW_gen_0/link_Enabled_out] [get_bd_pins spwr_ip_0/link_Enabled] [get_bd_pins spwr_ip_1/link_Enabled]
  connect_bd_net -net FIFO_stream_0_full [get_bd_pins FIFO_stream_0/full] [get_bd_pins RMAP_Decoder_0/buffer_full]
  connect_bd_net -net FIFO_stream_1_Rx_Rd_n [get_bd_pins FIFO_stream_1/Rx_Rd_n] [get_bd_pins spwr_ip_1/Rx_Rd_n]
  connect_bd_net -net RMAP_Decoder_0_Rx_Rd_n [get_bd_pins RMAP_Decoder_0/Rx_Rd_n] [get_bd_pins Rx_Fifo_0/Rd_n]
  connect_bd_net -net RMAP_Decoder_0_buffer_data [get_bd_pins RMAP_Decoder_0/buffer_data] [get_bd_pins FIFO_stream_0/data_in_decoder]
  connect_bd_net -net RMAP_Decoder_0_buffer_wr_en1 [get_bd_pins RMAP_Decoder_0/buffer_wr_en] [get_bd_pins FIFO_stream_0/write_en]
  connect_bd_net -net Reset_n_1 [get_bd_ports Reset_n] [get_bd_pins Tx_0/Reset_n] [get_bd_pins fsm_0/Reset_n] [get_bd_pins twodomainclock_0/Rst] [get_bd_pins RMAP_Decoder_0/reset_n] [get_bd_pins FIFO_stream_0/reset_n] [get_bd_pins FIFO_stream_1/reset_n] [get_bd_pins SpW_gen_0/Reset_n] [get_bd_pins spwr_ip_0/Reset_n] [get_bd_pins spwr_ip_1/Reset_n] [get_bd_pins Rx_Fifo_0/Reset_n] [get_bd_pins Tx_Fifo_0/Reset_n] [get_bd_pins Data_Generator_0/Reset_n]
  connect_bd_net -net Rx_0_Error_Dis_n [get_bd_pins Rx_0/Error_Dis_n] [get_bd_pins Concat_0/in1]
  connect_bd_net -net Rx_0_Error_ESC_n [get_bd_pins Rx_0/Error_ESC_n] [get_bd_pins Concat_0/in2]
  connect_bd_net -net Rx_0_Error_Par_n [get_bd_pins Rx_0/Error_Par_n] [get_bd_pins Concat_0/in3]
  connect_bd_net -net Rx_0_Rx_FIFO_D [get_bd_pins Rx_0/Rx_FIFO_D] [get_bd_pins Rx_Fifo_0/Din]
  connect_bd_net -net Rx_0_Rx_FIFO_Wr_n [get_bd_pins Rx_0/Rx_FIFO_Wr_n] [get_bd_pins Concat_0/in0]
  connect_bd_net -net Rx_0_got_EOP_n [get_bd_pins Rx_0/got_EOP_n] [get_bd_pins Concat_0/in8]
  connect_bd_net -net Rx_0_got_FCT_n [get_bd_pins Rx_0/got_FCT_n] [get_bd_pins Concat_0/in7]
  connect_bd_net -net Rx_0_got_NChar_n [get_bd_pins Rx_0/got_NChar_n] [get_bd_pins Concat_0/in5]
  connect_bd_net -net Rx_0_got_NULL_n [get_bd_pins Rx_0/got_NULL_n] [get_bd_pins Concat_0/in6]
  connect_bd_net -net Rx_0_got_Time_n [get_bd_pins Rx_0/got_Time_n] [get_bd_pins Concat_0/in4]
  connect_bd_net -net Rx_Fifo_0_Credit_Empty_n [get_bd_pins Rx_Fifo_0/Credit_Empty_n] [get_bd_pins Tx_0/Rx_FIFO_Credit_Empty_n]
  connect_bd_net -net Rx_Fifo_0_Dout [get_bd_pins Rx_Fifo_0/Dout] [get_bd_pins RMAP_Decoder_0/Rx_Dout]
  connect_bd_net -net Rx_Fifo_0_Empty_n [get_bd_pins Rx_Fifo_0/Empty_n] [get_bd_pins RMAP_Decoder_0/Rx_Empty_n]
  connect_bd_net -net Rx_Fifo_0_credit_error_n [get_bd_pins Rx_Fifo_0/credit_error_n] [get_bd_pins fsm_0/Rx_credit_error_n]
  connect_bd_net -net Slicer_0_out0 [get_bd_pins Slicer_0/out0] [get_bd_pins Rx_Fifo_0/Wr_n]
  connect_bd_net -net Slicer_0_out1 [get_bd_pins Slicer_0/out1] [get_bd_pins fsm_0/short_Error_Dis_n]
  connect_bd_net -net Slicer_0_out2 [get_bd_pins Slicer_0/out2] [get_bd_pins fsm_0/short_Error_ESC_n]
  connect_bd_net -net Slicer_0_out3 [get_bd_pins Slicer_0/out3] [get_bd_pins fsm_0/short_Error_Par_n]
  connect_bd_net -net Slicer_0_out4 [get_bd_pins Slicer_0/out4] [get_bd_pins fsm_0/short_got_Time_n]
  connect_bd_net -net Slicer_0_out5 [get_bd_pins Slicer_0/out5] [get_bd_pins fsm_0/short_got_NChar_n]
  connect_bd_net -net Slicer_0_out6 [get_bd_pins Slicer_0/out6] [get_bd_pins fsm_0/short_got_null_n] [get_bd_pins Data_Generator_0/short_got_null_n]
  connect_bd_net -net Slicer_0_out7 [get_bd_pins Slicer_0/out7] [get_bd_pins fsm_0/short_got_fct_n] [get_bd_pins Tx_Fifo_0/fct_n]
  connect_bd_net -net Slicer_0_out8 [get_bd_pins Slicer_0/out8] [get_bd_pins Rx_Fifo_0/short_got_EOP_n]
  connect_bd_net -net SpW_gen_0_Din [get_bd_pins SpW_gen_0/Din] [get_bd_pins spwr_ip_0/Tx_Din]
  connect_bd_net -net SpW_gen_0_Din_2 [get_bd_pins SpW_gen_0/Din_2] [get_bd_pins spwr_ip_1/Tx_Din]
  connect_bd_net -net SpW_gen_0_Rx_Rd_n [get_bd_pins SpW_gen_0/Rx_Rd_n] [get_bd_pins spwr_ip_0/Rx_Rd_n]
  connect_bd_net -net SpW_gen_0_Send_Time_n [get_bd_pins SpW_gen_0/Send_Time_n] [get_bd_pins spwr_ip_0/Tx_Send_Time] [get_bd_pins spwr_ip_1/Tx_Send_Time]
  connect_bd_net -net SpW_gen_0_Time_Code [get_bd_pins SpW_gen_0/Time_Code] [get_bd_pins spwr_ip_0/Tx_Time_Code] [get_bd_pins spwr_ip_1/Tx_Time_Code]
  connect_bd_net -net SpW_gen_0_Wr_n [get_bd_pins SpW_gen_0/Wr_n] [get_bd_pins spwr_ip_0/Tx_Wr_n]
  connect_bd_net -net SpW_gen_0_Wr_n_2 [get_bd_pins SpW_gen_0/Wr_n_2] [get_bd_pins spwr_ip_1/Tx_Wr_n]
  connect_bd_net -net SpW_gen_0_data_in_FIFO [get_bd_pins SpW_gen_0/data_in_FIFO] [get_bd_pins FIFO_stream_1/data_in_decoder]
  connect_bd_net -net SpW_gen_0_m_axis_tready [get_bd_pins SpW_gen_0/m_axis_tready] [get_bd_pins FIFO_stream_1/m_axis_tready]
  connect_bd_net -net SpW_gen_0_wd_timeout [get_bd_pins SpW_gen_0/wd_timeout] [get_bd_pins spwr_ip_0/wd_timeout] [get_bd_pins spwr_ip_1/wd_timeout]
  connect_bd_net -net Tx_0_Dout [get_bd_pins Tx_0/Dout] [get_bd_pins Rx_0/Din]
  connect_bd_net -net Tx_0_Rx_FIFO_Credit_Rd_n [get_bd_pins Tx_0/Rx_FIFO_Credit_Rd_n] [get_bd_pins Rx_Fifo_0/Credit_Rd_n]
  connect_bd_net -net Tx_0_Sout [get_bd_pins Tx_0/Sout] [get_bd_pins Rx_0/Sin]
  connect_bd_net -net Tx_0_Tx_FIFO_Rd_n [get_bd_pins Tx_0/Tx_FIFO_Rd_n] [get_bd_pins Tx_Fifo_0/Rd_n]
  connect_bd_net -net Tx_0_send_eop_n [get_bd_pins Tx_0/send_eop_n] [get_bd_pins Tx_Fifo_0/short_send_eop_rising]
  connect_bd_net -net Tx_0_time_id_sended_n [get_bd_pins Tx_0/time_id_sended_n] [get_bd_pins Data_Generator_0/time_id_sended_n]
  connect_bd_net -net Tx_Fifo_0_Credit_Empty_n [get_bd_pins Tx_Fifo_0/Credit_Empty_n] [get_bd_pins Tx_0/Tx_Credit_Empty_n]
  connect_bd_net -net Tx_Fifo_0_Dout [get_bd_pins Tx_Fifo_0/Dout] [get_bd_pins Tx_0/Tx_FIFO_Din]
  connect_bd_net -net Tx_Fifo_0_Empty_n [get_bd_pins Tx_Fifo_0/Empty_n] [get_bd_pins Tx_0/Tx_FIFO_Empty_n]
  connect_bd_net -net Tx_Fifo_0_Full_n [get_bd_pins Tx_Fifo_0/Full_n] [get_bd_pins Data_Generator_0/Full_n]
  connect_bd_net -net Tx_Fifo_0_fct_Full_n [get_bd_pins Tx_Fifo_0/fct_Full_n] [get_bd_pins fsm_0/Tx_credit_error_n]
  connect_bd_net -net fsm_0_State [get_bd_pins fsm_0/State] [get_bd_pins Rx_0/State] [get_bd_pins Tx_0/State] [get_bd_pins Rx_Fifo_0/State] [get_bd_pins Tx_Fifo_0/State] [get_bd_pins Data_Generator_0/State]
  connect_bd_net -net fsm_0_before_errorwait [get_bd_pins fsm_0/before_errorwait] [get_bd_pins Data_Generator_0/before_errorwait]
  connect_bd_net -net fsm_0_signal_errorwait [get_bd_pins fsm_0/signal_errorwait] [get_bd_pins Rx_0/signal_errorwait]
  connect_bd_net -net spwr_ip_0_Dout [get_bd_pins spwr_ip_0/Dout] [get_bd_pins spwr_ip_1/Din]
  connect_bd_net -net spwr_ip_0_Sout [get_bd_pins spwr_ip_0/Sout] [get_bd_pins spwr_ip_1/Sin]
  connect_bd_net -net spwr_ip_0_Tx_Full_n [get_bd_pins spwr_ip_0/Tx_Full_n] [get_bd_pins SpW_gen_0/Full_n]
  connect_bd_net -net spwr_ip_0_short_got_null_n [get_bd_pins spwr_ip_0/short_got_null_n]
  connect_bd_net -net spwr_ip_1_Dout [get_bd_pins spwr_ip_1/Dout] [get_bd_pins spwr_ip_0/Din]
  connect_bd_net -net spwr_ip_1_Rx_Dout [get_bd_pins spwr_ip_1/Rx_Dout] [get_bd_pins FIFO_stream_1/data_in_Rx]
  connect_bd_net -net spwr_ip_1_Rx_Empty_n [get_bd_pins spwr_ip_1/Rx_Empty_n] [get_bd_pins FIFO_stream_1/write_en]
  connect_bd_net -net spwr_ip_1_Sout [get_bd_pins spwr_ip_1/Sout] [get_bd_pins spwr_ip_0/Sin]
  connect_bd_net -net twodomainclock_0_out_short_pulse_n [get_bd_pins twodomainclock_0/out_short_pulse_n] [get_bd_pins Slicer_0/input_vector]

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


