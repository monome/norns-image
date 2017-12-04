/*
 * ASoC Driver for monome-snd
 * connected to a Raspberry Pi
 *
 *  Created on: 20160610
 *      Author: murray foster <mrafoster@gmail.com>
 *              based on code from existing soc/bcm drivers
 *
 * Copyright (C) 2016 Murray Foster
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 */
#include <linux/module.h>
#include <linux/platform_device.h>

#include <sound/core.h>
#include <sound/pcm.h>
#include <sound/pcm_params.h>
#include <sound/soc.h>
#include <sound/jack.h>

#define CLK_RATE 12288000UL

static int snd_rpi_monome_init(struct snd_soc_pcm_runtime *rtd)
{
  return 0;
}

static int snd_rpi_monome_hw_params(struct snd_pcm_substream *substream,
			   struct snd_pcm_hw_params *params)
{
  struct snd_soc_pcm_runtime *rtd = substream->private_data;
  struct snd_soc_dai *cpu_dai = rtd->cpu_dai;
  struct snd_soc_dai *codec_dai = rtd->codec_dai;
  struct snd_soc_codec *codec = rtd->codec;
  
  int sysclk = 12288000;
  int ret = 0;

  /* Don't worry about clock id and direction (it's ignored in cs4270 driver) */
  ret = snd_soc_dai_set_sysclk(codec_dai, 0, sysclk, 0);

  if (ret < 0)
    {
      dev_err(codec->dev, "Unable to set CS4270 system clock.");
      return ret;
    }
  
  /* cs4270 datasheet says SCLK must be 48x or 64x for max system performance */
  return snd_soc_dai_set_bclk_ratio(cpu_dai, 64);
}

static int snd_rpi_monome_startup(struct snd_pcm_substream *substream) {
  return 0;
}

static void snd_rpi_monome_shutdown(struct snd_pcm_substream *substream) {
}

/* machine stream operations */
static struct snd_soc_ops snd_rpi_monome_ops = {
  .hw_params = snd_rpi_monome_hw_params,
  .startup = snd_rpi_monome_startup,
  .shutdown = snd_rpi_monome_shutdown,
};

static struct snd_soc_dai_link snd_rpi_monome_dai[] = {
	{
		.name = "monome cs4270",
		.stream_name = "monome cs4270",
		.cpu_dai_name	= "bcm2708-i2s.0",
		.codec_dai_name = "cs4270-hifi",
		.platform_name	= "bcm2708-i2s.0",
		.codec_name = "cs4270.1-0048",
		.dai_fmt = SND_SOC_DAIFMT_CBM_CFM | \
		           SND_SOC_DAIFMT_I2S | \
		           SND_SOC_DAIFMT_NB_NF,
		.ops = &snd_rpi_monome_ops,
		.init = snd_rpi_monome_init,
	},
};

static struct snd_soc_card snd_rpi_monome = {
	.name = "snd_rpi_monome",
	.owner = THIS_MODULE,
	.dai_link = snd_rpi_monome_dai,
	.num_links = ARRAY_SIZE(snd_rpi_monome_dai),
};

static int snd_rpi_monome_probe(struct platform_device *pdev)
{
	int ret = 0;
	
	snd_rpi_monome.dev = &pdev->dev;

	if (pdev->dev.of_node) {
		struct device_node *i2s_node;
		struct snd_soc_dai_link *dai = &snd_rpi_monome_dai[0];
		i2s_node = of_parse_phandle(pdev->dev.of_node,
					    "i2s-controller", 0);

		if (i2s_node) {
			dai->cpu_dai_name = NULL;
			dai->cpu_of_node = i2s_node;
			dai->platform_name = NULL;
			dai->platform_of_node = i2s_node;
		}		
	}
	
	ret = snd_soc_register_card(&snd_rpi_monome);
	if (ret)
	  {
	    dev_err(&pdev->dev,
		    "snd_soc_register_card() failed (%d)\n", ret);
	  }
	return ret;
}

static int snd_rpi_monome_remove(struct platform_device *pdev)
{
	return snd_soc_unregister_card(&snd_rpi_monome);
}

static const struct of_device_id snd_rpi_monome_of_match[] = {
	{ .compatible = "monome", },
	{},
};
MODULE_DEVICE_TABLE(of, snd_rpi_monome_of_match);

static struct platform_driver snd_rpi_monome_driver = {
       .driver         = {
		.name   = "snd-rpi-monome",
		.owner  = THIS_MODULE,
		.of_match_table = snd_rpi_monome_of_match,
       },
       .probe          = snd_rpi_monome_probe,
       .remove         = snd_rpi_monome_remove,
};
module_platform_driver(snd_rpi_monome_driver);

MODULE_AUTHOR("Murray Foster <mrafoster@gmail.com>");
MODULE_DESCRIPTION("ASoC Driver for monome-snd connected to a Raspberry Pi");
MODULE_LICENSE("GPL v2");
