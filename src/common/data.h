/*
 * SPDX-License-Identifier: MIT
 * Copyright (c) 2026 Liav A
 */

#ifndef __COMMON__DATA_H_
#define __COMMON__DATA_H_

#include "common/types.h"

uint32_t crc32_compute_direct_buf(const uint8_t *data, size_t len);

/* Functions for CRC32 in steps, useful for block device reading */
uint32_t crc32_init(void);
uint32_t crc32_update(uint32_t crc, const uint8_t *data, size_t len);
uint32_t crc32_finalize(uint32_t crc);

#endif