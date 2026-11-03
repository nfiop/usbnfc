/*
 * SPDX-License-Identifier: MIT
 * Copyright (c) 2026 Liav A
 */

#include "common/data.h"

uint32_t crc32_init(void)
{
	return 0xFFFFFFFFu;
}

uint32_t crc32_finalize(uint32_t crc)
{
	return crc ^ 0xFFFFFFFFu;
}

uint32_t crc32_update(uint32_t crc, const uint8_t *data, size_t len)
{
	for (size_t i = 0; i < len; i++) {
		crc ^= data[i];

		for (unsigned bit = 0; bit < 8; bit++) {
			if (crc & 1u)
				crc = (crc >> 1) ^ 0xEDB88320u;
			else
				crc >>= 1;
		}
	}

	return crc;
}

uint32_t crc32_compute_direct_buf(const uint8_t *data, size_t len)
{
	uint32_t crc = crc32_init();
	crc = crc32_update(crc, data, len);
	return crc32_finalize(crc);
}
