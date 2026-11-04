/*
 * SPDX-License-Identifier: MIT
 * Copyright (c) 2026 Liav A
 */

#include "platform/platform.h"
#include "stm32h7xx_hal.h"

#include <stdlib.h>
#include <string.h>

extern int app_main(void);

UART_HandleTypeDef huart2;

enum platform_mode determine_platform_mode(void)
{
	// TODO: Implement this
	return PLATFORM_MODE_MSC;
}

uint64_t time_now_ms(void)
{
	return (uint64_t)HAL_GetTick();
}

void *mem_realloc(void *ptr, size_t size)
{
	return realloc(ptr, size);
}

void *mem_alloc(size_t mem_size)
{
	return malloc(mem_size);
}

void *mem_alloc_counted(size_t count, size_t obj_size)
{
	return mem_alloc(count * obj_size);
}

void mem_free(void *ptr)
{
	free(ptr);
}

void *mem_zalloc(size_t mem_size)
{
	void *new_mem = mem_alloc(mem_size);
	if (!new_mem)
		return NULL;

	memset(new_mem, 0, mem_size);
	return new_mem;
}

void send_msg_on_debug_uart(const char *msg)
{
	HAL_UART_Transmit(&huart2, (uint8_t *)msg, strlen(msg), HAL_MAX_DELAY);

	/* Print newline automatically */
	HAL_UART_Transmit(&huart2, (uint8_t *)"\r\n", 2, HAL_MAX_DELAY);
}

void halt_all_cpus(void)
{
	__disable_irq();

	// Halt forever
	while (1) {
	}
	__builtin_unreachable();
}

void halt(void)
{
	halt_all_cpus();
}

static void enable_uart0(void)
{
	// Basic UART settings
	huart2.Instance = USART2;
	huart2.Init.BaudRate = 115200;
	huart2.Init.WordLength = UART_WORDLENGTH_8B;
	huart2.Init.StopBits = UART_STOPBITS_1;
	huart2.Init.Parity = UART_PARITY_NONE;
	huart2.Init.Mode = UART_MODE_TX_RX;
	huart2.Init.HwFlowCtl = UART_HWCONTROL_NONE;
	huart2.Init.OverSampling = UART_OVERSAMPLING_16;

	if (HAL_UART_Init(&huart2) != HAL_OK) {
		// Nothing we can do about this...
		halt_all_cpus();
	}

	send_msg_on_debug_uart("UART enabled!");
}

int main(void)
{
	HAL_Init();

	enable_uart0();

	app_main();

	ASSERT_NOT_REACHED("main cannot exit");
}
