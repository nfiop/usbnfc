/*
 * SPDX-License-Identifier: MIT
 * Copyright (c) 2026 Liav A
 */

#include "platform/platform.h"

int debug_and_test_mode_uart_send_bytes(const uint8_t *data, size_t len)
{
	UNUSED(data);
	UNUSED(len);

	TODO();
	return 0;
}

int debug_and_test_mode_uart_read_non_blocking(uint8_t *data, size_t max_len)
{
	UNUSED(data);
	UNUSED(max_len);

	TODO();
	return 0;
}

void start_debug_and_test_uart_mode(void (*rx_poll_timeout)(void))
{
	UNUSED(rx_poll_timeout);

	TODO();
}
