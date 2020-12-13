
The design files are located at
/home/ise/Xilins_virt_machine/project_FPGA - Video/VHDL_FILES/ipcore_dir:

   - LPDDR.vho:
        vho template file containing code that can be used as a model
        for instantiating a CORE Generator module in a HDL design.

   - LPDDR.xco:
       CORE Generator input file containing the parameters used to
       regenerate a core.

   - LPDDR_flist.txt:
        Text file listing all of the output files produced when a customized
        core was generated in the CORE Generator.

   - LPDDR_readme.txt:
        Text file indicating the files generated and how they are used.

   - LPDDR_xmdf.tcl:
        ISE Project Navigator interface file. ISE uses this file to determine
        how the files output by CORE Generator for the core can be integrated
        into your ISE project.

   - LPDDR.gise and LPDDR.xise:
        ISE Project Navigator support files. These are generated files and
        should not be edited directly.

   - LPDDR directory.

In the LPDDR directory, three folders are created:
   - docs:
        This folder contains Virtex-6 FPGA Memory Interface Solutions user guide
        and data sheet.

   - example_design:
        This folder includes the design with synthesizable test bench.

   - user_design:
        This folder includes the design without test bench modules.

The example_design and user_design folders contain several other folders
and files. All these output folders are discussed in more detail in
Spartan-6 FPGA Memory Controller user guide (ug388.pdf) located in docs folder.
    