# Faculty Fighters Instructions To Run

This project was developed using Quartus II 15.0 (64-bit) on the device family Cyclone IV E. The device name of the FPGA is (EP4CE115F29C7).

This is a project developed for a course at the University of Illinois at Champaign-Urbana, ECE385: Digital Systems Laboratory. For a detailed report on the project, please refer to the project proposal and report file under the documentation directory.

To run Faculty Fighters:
1. Load the project file on the Quartus application. The project file should automatically include all necessary files.
2. Open Qsys to generate an HDL file for the project's System on Chip.
   - Click on the 'tools->Qsys'.
   - Click on the 'Generate->Generate HDL'. Make sure verilog is selected as the HDL design file.
   - On Quartus, add the newly generated verilog file to the project if it doesn't already exist. This can be done by:
     - Right click files under 'Project Navigator' and select 'Add/Remove Files in Project'
     - Click on the ellipsis to navigate the project folders to find the verilog file. It should be nested under a folder with 'soc' appended to the end and synthesis. Ex. project_root->faculty_fighter_soc->synthesis->faculty_fighter_soc.v.
3. Compile and Synthesis the project.

After the project has been compiled, the output file can be flashed onto the FPGA. You will need the USB-Blaster installed to flash it from the developer deivce to the FPGA through USB. This will need to be done before ths software can function with the hardware.

To get the Software running to control the characters with a keyboard open NIOS II and run the software from there through the USB connection.
1. Click on the 'tools' drop down menu in Quartus and select 'NIOS II Software Build Tools for Eclipse'.
2. Navigate the project directories to select the 'software' directory as the work directory for the software. It should contain the necessary C files for the project.
3. On the NIOS II window, click on 'Files->New->NIOS II Application and BSP from Template'.
4. Select the '.sopcinfo' file in the project directory.
5. Choose Blank Template.
6. Click Finish.
7. Move all the software files into the automatically generated software directory.
8. In the Project Explorer, right click the 'bsp' directory and click on 'NIOS II->Generate BSP'. Wait for it to finish generating.
9. Click on 'Project->Build All' from the drop down.
10. Click on 'Run->Run Configurations'.
11. Add new NIOS II Hardware and provide it the project name and elf file.
12. Click on the 'Target Connection' tab and hit refresh connection before hitting run. This may take a couple attempts.

Once the Software is finish booting up, the keyboard should be functional and running alongside the hardware to control the character.
