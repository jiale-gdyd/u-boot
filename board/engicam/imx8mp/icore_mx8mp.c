// SPDX-License-Identifier: GPL-2.0+
/*
 * Copyright (C) 2016 Engicam S.r.l.
 * Copyright (C) 2022 Amarula Solutions(India)
 *
 * Authors:
 * Manoj Sai <abbaraju.manojsai@amarulasolutions.com>
 * Jagan Teki <jagan@amarulasolutions.com>
 */

#include <common.h>
#include <env.h>
#include <errno.h>
#include <init.h>
#include <miiphy.h>
#include <netdev.h>
#include <linux/delay.h>
#include <asm/global_data.h>
#include <asm/mach-imx/iomux-v3.h>
#include <asm-generic/gpio.h>
#include <asm/arch/imx8mp_pins.h>
#include <asm/arch/clock.h>
#include <asm/arch/sys_proto.h>
#include <asm/mach-imx/gpio.h>

DECLARE_GLOBAL_DATA_PTR;

static void setup_fec(void)
{
	struct iomuxc_gpr_base_regs *gpr =
		(struct iomuxc_gpr_base_regs *)IOMUXC_GPR_BASE_ADDR;

	/* Enable RGMII TX clk output */
	setbits_le32(&gpr->gpr[1], BIT(22));
}

static int setup_eqos(void)
{
	struct iomuxc_gpr_base_regs *gpr =
		(struct iomuxc_gpr_base_regs *)IOMUXC_GPR_BASE_ADDR;

	/* set INTF as RGMII, enable RGMII TXC clock */
	clrsetbits_le32(&gpr->gpr[1],
			IOMUXC_GPR_GPR1_GPR_ENET_QOS_INTF_SEL_MASK, BIT(16));
	setbits_le32(&gpr->gpr[1], BIT(19) | BIT(21));

	return set_clk_eqos(ENET_125MHZ);
}

#if CONFIG_IS_ENABLED(NET)
int board_phy_config(struct phy_device *phydev)
{
	if (phydev->drv->config)
		phydev->drv->config(phydev);
	return 0;
}
#endif

int board_init(void)
{
	if (CONFIG_IS_ENABLED(FEC_MXC))
		setup_fec();

	if (CONFIG_IS_ENABLED(DWC_ETH_QOS))
		setup_eqos();

	return 0;
}

int board_late_init(void)
{
	return 0;
}
