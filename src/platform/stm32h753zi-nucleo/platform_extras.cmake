cmake_minimum_required(VERSION 3.20)

target_compile_definitions(usbnfc_fw PRIVATE
    USE_HAL_DRIVER
    STM32H753xx
)

target_compile_options(usbnfc_fw PRIVATE
    -mcpu=cortex-m7
    -mthumb
    -mfpu=fpv5-d16
    -mfloat-abi=hard
    -Wall
    -Wextra
)

target_link_options(usbnfc_fw PRIVATE
    -mcpu=cortex-m7
    -mthumb
    -mfpu=fpv5-d16
    -mfloat-abi=hard
    -T${CMAKE_CURRENT_LIST_DIR}/STM32H753ZITX_FLASH.ld
    -Wl,--gc-sections
    -Wl,-Map=${PROJECT_NAME}.map
    --specs=nano.specs
    --specs=nosys.specs
)

target_compile_options(usbnfc_fw PRIVATE
    -ffunction-sections
    -fdata-sections
)

target_link_options(usbnfc_fw PRIVATE
    -Wl,--print-memory-usage
)

# Needed for QCBOR which uses float-point exception tests
target_link_libraries(usbnfc_fw PRIVATE m)

add_custom_command(TARGET usbnfc_fw POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex
        $<TARGET_FILE:usbnfc_fw>
        ${PROJECT_NAME}.hex

    COMMAND arm-none-eabi-objcopy -O binary
        $<TARGET_FILE:usbnfc_fw>
        ${PROJECT_NAME}.bin
)
