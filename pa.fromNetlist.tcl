
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name INL_Project -dir "D:/FPGA CONSOLE/codeOne/INL_Project/planAhead_run_1" -part xc6slx9csg324-2
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "D:/FPGA CONSOLE/codeOne/INL_Project/Assembly.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/FPGA CONSOLE/codeOne/INL_Project} {ipcore_dir} }
add_files [list {ipcore_dir/video_buffer.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "D:/FPGA CONSOLE/codeOne/INL_Project/VHDL_FILES/UCFmimas.ucf" [current_fileset -constrset]
add_files [list {D:/FPGA CONSOLE/codeOne/INL_Project/VHDL_FILES/UCFmimas.ucf}] -fileset [get_property constrset [current_run]]
link_design
