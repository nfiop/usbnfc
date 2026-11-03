cmake_minimum_required(VERSION 3.20)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# STM32CubeH7 location
set(CUBE_DIR
    ${CMAKE_CURRENT_LIST_DIR}/external/STM32CubeH7
)

# HAL sources
set(HAL_DIR
    ${CUBE_DIR}/Drivers/STM32H7xx_HAL_Driver
)

set(HAL_SOURCES
    ${HAL_DIR}/Src/stm32h7xx_hal.c
    ${HAL_DIR}/Src/stm32h7xx_hal_cortex.c
    ${HAL_DIR}/Src/stm32h7xx_hal_gpio.c
    ${HAL_DIR}/Src/stm32h7xx_hal_rcc.c
    ${HAL_DIR}/Src/stm32h7xx_hal_rcc_ex.c
    ${HAL_DIR}/Src/stm32h7xx_hal_pwr.c
    ${HAL_DIR}/Src/stm32h7xx_hal_pwr_ex.c
    ${HAL_DIR}/Src/stm32h7xx_hal_flash.c
    ${HAL_DIR}/Src/stm32h7xx_hal_flash_ex.c
)

set(PLATFORM_SOURCES 
    ${HAL_SOURCES}
    ${CUBE_DIR}/Drivers/CMSIS/Device/ST/STM32H7xx/Source/Templates/system_stm32h7xx.c
    ${CMAKE_CURRENT_LIST_DIR}/startup_stm32h753xx.s
    ${CMAKE_CURRENT_LIST_DIR}/platform.c)

# ${PICO_SDK_PATH} is declared in sdk.cmake file.
set(PLATFORM_INCLUDES ${CMAKE_CURRENT_LIST_DIR}
    ${HAL_DIR}/Inc
    ${CUBE_DIR}/Drivers/CMSIS/Include
    ${CUBE_DIR}/Drivers/CMSIS/Device/ST/STM32H7xx/Include)
