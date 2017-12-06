#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/device.h>
#include <linux/init.h>
#include <linux/gpio.h>
#include <linux/spi/spi.h>
#include <linux/delay.h>

#include "fbtft.h"

#define DRVNAME     "fb_ssd1322"
#define WIDTH       128
#define HEIGHT      64
#define GAMMA_NUM   1
#define GAMMA_LEN   15
#define DEFAULT_GAMMA "1 1 1 1 1 2 2 3 3 4 4 5 5 6 6"

int init[] = {			/* Initialization for LM560G-256064 5.6" OLED display */
	//-1, 0xFD, 0x12,		/* Unlock OLED driver IC */
	-1, 0xAE,		/* Display OFF (blank) */
	-1, 0xB9,		/* Select default linear grayscale */
	-1, 0xB3, 0x91,		/* Display divide clockratio/frequency */
	-1, 0xCA, 0x3F,		/* Multiplex ratio, 1/64, 64 COMS enabled */
	-1, 0xA2, 0x00,		/* Set offset, the display map starting line is COM0 */
	-1, 0xA1, 0x00,		/* Set start line position */
	-1, 0xA0, 0x16, 0x11,	/* Set remap, horiz address increment, disable colum address remap, */
				/*  enable nibble remap, scan from com[N-1] to COM0, disable COM split odd even */
	-1, 0xAB, 0x01,		/* Select external VDD */
	-1, 0xB4, 0xA0, 0xFD,	/* Display enhancement A, external VSL, enhanced low GS display quality */
	-1, 0xC1, 0x7F,		/* Contrast current, 256 steps, default is 0x7F */
	-1, 0xC7, 0x0F,		/* Master contrast current, 16 steps, default is 0x0F */
	-1, 0xB1, 0xF2,		/* Phase Length */
	//-1, 0xD1, 0x82, 0x20	/* Display enhancement B */
	-1, 0xBB, 0x1F,		/* Pre-charge voltage */
	-1, 0xBE, 0x04,		/* Set VCOMH */
	-1, 0xA6,		/* Normal display */
	-1, 0xAF,		/* Display ON */
	-3 };


static void set_addr_win(struct fbtft_par *par, int xs, int ys, int xe, int ye)
{
	//int width = par->info->var.xres;
	//int offset = (480 - width) / 8;

	fbtft_par_dbg(DEBUG_SET_ADDR_WIN, par, "%s(xs=%d, ys=%d, xe=%d, ye=%d)\n", __func__, xs, ys, xe, ye);
	//write_reg(par, 0x15, offset, offset + (width / 4) - 1);
	//write_reg(par, 0x15, 28 + xs,28+xe);
	write_reg(par, 0x15, 28,91);
	write_reg(par, 0x75, ys, ye);
	//write_reg(par, 0x75, 0, 63);
	write_reg(par, 0x5c);
}

/*
	Grayscale Lookup Table
	GS1 - GS15
	The "Gamma curve" contains the relative values between the entries in the Lookup table.

	0 = Setting of GS1 < Setting of GS2 < Setting of GS3..... < Setting of GS14 < Setting of GS15

*/
static int set_gamma(struct fbtft_par *par, unsigned long *curves)
{
	unsigned long tmp[GAMMA_LEN * GAMMA_NUM];
	int i, acc = 0;

	fbtft_par_dbg(DEBUG_INIT_DISPLAY, par, "%s()\n", __func__);

	for (i = 0; i < GAMMA_LEN; i++) {
		if (i > 0 && curves[i] < 1) {
			dev_err(par->info->device,
				"Illegal value in Grayscale Lookup Table at index %d. " \
				"Must be greater than 0\n", i);
			return -EINVAL;
		}
		acc += curves[i];
		tmp[i] = acc;
		if (acc > 180) {
			dev_err(par->info->device,
				"Illegal value(s) in Grayscale Lookup Table. " \
				"At index=%d, the accumulated value has exceeded 180\n", i);
			return -EINVAL;
		}
	}

	//write_reg(par, 0xB8,
	//0,1,2,3,4,5,6,7,8,
	//9,10,15,25,30,35);
	//tmp[0], tmp[1], tmp[2], tmp[3], tmp[4], tmp[5], tmp[6], tmp[7],
	//tmp[8], tmp[9], tmp[10], tmp[11], tmp[12], tmp[13], tmp[14]);
	//write_reg(par, 0);
	

	return 0;
}

static int blank(struct fbtft_par *par, bool on)
{
	fbtft_par_dbg(DEBUG_BLANK, par, "%s(blank=%s)\n", __func__, on ? "true" : "false");
	if (on)
		write_reg(par, 0xAE);
	else
		write_reg(par, 0xAF);
	return 0;
}


#define CYR     613    /* 2.392 */
#define CYG     601    /* 2.348 */
#define CYB     233    /* 0.912 */
/*static unsigned int rgb565_to_y(unsigned int rgb)
{
	rgb = cpu_to_le16(rgb);
	return CYR * (rgb >> 11) + CYG * (rgb >> 5 & 0x3F) + CYB * (rgb & 0x1F);
}*/

static int write_vmem(struct fbtft_par *par, size_t offset, size_t len)
{
	u16 *vmem16 = (u16 *)(par->info->screen_base);
	u8 *buf = par->txbuf.buf;
	int y, x, bl_height, bl_width;
	int ret = 0;

	/* Set data line beforehand */
	gpio_set_value(par->gpio.dc, 1);

	/* convert offset to word index from byte index */
	offset /= 2;
	bl_width = par->info->var.xres;
	bl_height = len / par->info->fix.line_length;

	fbtft_par_dbg(DEBUG_WRITE_VMEM, par,
		"%s(offset=0x%x bl_width=%d bl_height=%d)\n", __func__, offset, bl_width, bl_height);

	//for(y=0;y<256;y++) 
	//for(x=0,x<8;x++) 
	//*buf++ = y>>4 | (y&0xf0);

	for (y = 0; y < bl_height; y++) {
		for (x = 0; x < bl_width; x++) {
			//*buf++ = cpu_to_le16(rgb565_to_y(vmem16[offset++])) >> 8;
			//int z = cpu_to_le16(rgb565_to_y(vmem16[offset++])) >> 8;
			int z = cpu_to_le16(vmem16[offset++]) >> 8;
			*buf++ = z>>4 | (z&0xf0); 
			//*buf++ = cpu_to_le16(rgb565_to_y(vmem16[offset++])) >> 8;
			//*buf++ = cpu_to_le16(vmem16[offset++]) >> 8;
		}
	}

	/* Write data */
	ret = par->fbtftops.write(par, par->txbuf.buf, bl_width*bl_height);
	if (ret < 0)
		dev_err(par->info->device, "%s: write failed and returned: %d\n", __func__, ret);

	return ret;
}

static struct fbtft_display display = {
	.regwidth = 8,
	.width = WIDTH,
	.height = HEIGHT,
	.txbuflen = WIDTH*HEIGHT,
	.gamma_num = GAMMA_NUM,
	.gamma_len = GAMMA_LEN,
	.gamma = DEFAULT_GAMMA,
	.init_sequence = init,
	.fbtftops = {
		.write_vmem = write_vmem,
		.set_addr_win  = set_addr_win,
		.blank = blank,
		.set_gamma = set_gamma,
	},
};

FBTFT_REGISTER_DRIVER(DRVNAME, "solomon,ssd1322", &display);

MODULE_ALIAS("spi:" DRVNAME);
MODULE_ALIAS("platform:" DRVNAME);
MODULE_ALIAS("spi:ssd1322");
MODULE_ALIAS("platform:ssd1322");

MODULE_DESCRIPTION("SSD1322 OLED Driver");
MODULE_AUTHOR("Ryan Press");
MODULE_LICENSE("GPL");
