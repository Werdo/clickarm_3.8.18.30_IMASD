/*
 * linux/arch/arm/mach-exynos4/setup-i2c5.c
 *
 * Copyright (c) 2010 Samsung Electronics Co., Ltd.
 *
 * I2C5 GPIO configuration.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
*/

struct platform_device; /* don't need the contents */

#include <linux/gpio.h>
#include <linux/platform_data/i2c-s3c2410.h>
#include <plat/gpio-cfg.h>

void s3c_i2c5_cfg_gpio(struct platform_device *dev)
{
	//s3c_gpio_cfgall_range(EXYNOS4_GPB(6), 2,
	//		      S3C_GPIO_SFN(3), S3C_GPIO_PULL_UP);
}
