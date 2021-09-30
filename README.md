# STM32 Template project

## Simple Cmake STM project

### Setup for VSCode:

Setup variables in `.vscode\settings.json`:

```json
"TOOLCHAIN_PATH": path to toolchain (example: "disk:/folder/Arm/armcc/")
"STM32Cube_DIR": path to cmsis\hal\cube dir (example: "disk:/folder/Arm/STM32Cube_FW_F3_V1.10.0/")
"VOID_LIB_PATH": path to void lib (optional)
```

### Setup for CLion:

1. Create compiler for ARM (Set `Path to C\C++ compilers`) in `File->Settings->Build,Execute,Deployment->Toolchains`
2. Setup `Cmake options` in `File->Settings->Build,Execute,Deployment->Cmake`:
    ```cmake
    -DCMAKE_TOOLCHAIN_FILE:FILEPATH=cmake/stm32/entrypoint.cmake
    -DSTM32Cube_DIR:STRING=I:/Nextcloud/LIBRARIES/Arm/STM32Cube_FW_F3_V1.10.0/
    -DVOID_LIB_PATH:FILEPATH: path to void lib (optional)
    -G Ninja
    ```
3. Change `project_name` `MCU` and `F_CPU` in [CMakeLists.txt](/CMakeLists.txt) file.
4. Setup debugger configuration in Edit configuration `Embedded GDB Server`.

Example for `openocd`:
```
'target remote' args: localhost:3333
GSB Server: I:\Nextcloud\LIBRARIES\Arm\OpenOCD\bin\openocd.exe
GDB Server args: -f interface/jlink.cfg -c "transport select swd" -f target/stm32f3x.cfg
Advanced GDB Server options->Reset command: monitor reset break main
```



