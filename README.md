# STM32 Template project

## Simple Cmake STM project

### Setup for VSCode:

Setup variables in `.vscode\settings.json`:

```json
"PROJECT_NAME": name of project,
"CMAKE_EXPORT_COMPILE_COMMANDS": "1", //Generate compile_commands.json
"MCU": avr mcu like "STM32F303xC",
"F_CPU": frequency like"72000000",
"CMAKE_RUNTIME_OUTPUT_DIRECTORY": output binary dir
"TOOLCHAIN_PATH": path to toolchain (example: "disk:/folder/Arm/armcc/")
"CPPTOOL_PATH": path to generated file c_cpp_properties "${workspaceFolder}/.vscode/c_cpp_properties.json", for better syntax highlight
"STM32Cube_DIR": path to cmsis\hal\cube dir (example: "disk:/folder/Arm/STM32Cube_FW_F3_V1.10.0/")
```

### Setup for CLion:

Setup `Cmake options` in `File->Settings->Build,Execute,Deployment->Cmake`:

```cmake
-DPROJECT_NAME:STRING=<name_of_project>
-DCMAKE_TOOLCHAIN_FILE:FILEPATH=<PROJECT_DIR>/cmake/avr/entrypoint.cmake
-DTOOLCHAIN_PATH:STRING=<PATH_TO_TOLCHAIN>
-DMCU:STRING=<MCU(ex: STM32F303xC)>
-F_CPU:STRING=<FREQUENCY(ex: 72000000)>
-DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE
-DCMAKE_RUNTIME_OUTPUT_DIRECTORY:STRING=<PROJECT_DIR>/bin
-DCPPTOOL_PATH:STRING=<PROJECT_DIR>/.vscode/c_cpp_properties.json
-DSTM32Cube_DIR:STRING =<PATH_TO_CUBE_DIR>/Arm/STM32Cube_FW_F3_V1.10.0/
-DVOID_LIB_PATH:STRING=<PATH_TO_VOID_LIB>
-DCPH_LIB_PATH:STRING=<PATH_TO_CPH_LIB>
-DUNITY_LIB_PATH:STRING=<PATH_TO_UNITY_LIB>
-G Ninja
```

Setup debugger configuration in Edit configuration `Embedded GDB Server`.

Example for `openocd`:
```
'target remote' args: localhost:3333
GSB Server: I:\Nextcloud\LIBRARIES\Arm\OpenOCD\bin\openocd.exe
GDB Server args: -f interface/jlink.cfg -c "transport select swd" -f target/stm32f3x.cfg
Advanced GDB Server options->Reset command: monitor reset break main
```


Don't forget to setup `Path to C\C++ compilers` in `File->Settings->Build,Execute,Deployment->Toolchain`
