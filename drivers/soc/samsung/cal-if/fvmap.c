#include <linux/types.h>
#include <linux/kernel.h>
#include <linux/slab.h>
#include <linux/io.h>
#include <linux/debugfs.h>
#include <linux/uaccess.h>
#include <linux/kobject.h>
#include <soc/samsung/cal-if.h>

#include "fvmap.h"
#include "cmucal.h"
#include "vclk.h"
#include "ra.h"

#define FVMAP_SIZE		(SZ_8K)
#define STEP_UV			(6250)

void __iomem *fvmap_base;
void __iomem *sram_fvmap_base;

static int init_margin_table[MAX_MARGIN_ID];
static int volt_offset_percent = 0;
static int percent_margin_table[MAX_MARGIN_ID];

static int __init get_mif_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_MIF] = volt;

	return 0;
}
early_param("mif", get_mif_volt);

static int __init get_int_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_INT] = volt;

	return 0;
}
early_param("int", get_int_volt);

static int __init get_big_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_BIG] = volt;

	return 0;
}
early_param("big", get_big_volt);

static int __init get_mid_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_MID] = volt;

	return 0;
}
early_param("mid", get_mid_volt);

static int __init get_lit_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_LIT] = volt;

	return 0;
}
early_param("lit", get_lit_volt);

static int __init get_g3d_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_G3D] = volt;

	return 0;
}
early_param("g3d", get_g3d_volt);

static int __init get_intcam_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_INTCAM] = volt;

	return 0;
}
early_param("intcam", get_intcam_volt);

static int __init get_cam_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_CAM] = volt;

	return 0;
}
early_param("cam", get_cam_volt);

static int __init get_disp_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_DISP] = volt;

	return 0;
}
early_param("disp", get_disp_volt);

static int __init get_g3dm_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_G3DM] = volt;

	return 0;
}
early_param("g3dm", get_g3dm_volt);

static int __init get_cp_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_CP] = volt;

	return 0;
}
early_param("cp", get_cp_volt);

static int __init get_fsys0_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_FSYS0] = volt;

	return 0;
}
early_param("fsys0", get_fsys0_volt);

static int __init get_aud_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_AUD] = volt;

	return 0;
}
early_param("aud", get_aud_volt);

static int __init get_iva_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_IVA] = volt;

	return 0;
}
early_param("iva", get_iva_volt);

static int __init get_score_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_SCORE] = volt;

	return 0;
}
early_param("score", get_score_volt);

static int __init get_npu_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_NPU] = volt;

	return 0;
}
early_param("npu", get_npu_volt);

static int __init get_mfc_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_MFC] = volt;

	return 0;
}
early_param("mfc", get_mfc_volt);

static int __init get_dsp_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_DSP] = volt;

	return 0;
}
early_param("dsp", get_dsp_volt);

static int __init get_dnc_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_DNC] = volt;

	return 0;
}
early_param("dnc", get_dnc_volt);

static int __init get_tnr_volt(char *str)
{
	int volt;

	get_option(&str, &volt);
	init_margin_table[MARGIN_TNR] = volt;

	return 0;
}
early_param("tnr", get_tnr_volt);

static int __init get_percent_margin_volt(char *str)
{
	int percent;

	get_option(&str, &percent);
	volt_offset_percent = percent;

	return 0;
}
early_param("volt_offset_percent", get_percent_margin_volt);

int fvmap_set_raw_voltage_table(unsigned int id, int uV)
{
	struct fvmap_header *fvmap_header;
	struct rate_volt_header *fv_table;
	int num_of_lv;
	int idx, i;

	idx = GET_IDX(id);

	fvmap_header = sram_fvmap_base;
	fv_table = sram_fvmap_base + fvmap_header[idx].o_ratevolt;
	num_of_lv = fvmap_header[idx].num_of_lv;

	for (i = 0; i < num_of_lv; i++)
		fv_table->table[i].volt += uV;

	return 0;
}

int fvmap_get_voltage_table(unsigned int id, unsigned int *table)
{
	struct fvmap_header *fvmap_header = fvmap_base;
	struct rate_volt_header *fv_table;
	int idx, i;
	int num_of_lv;

	if (!IS_ACPM_VCLK(id))
		return 0;

	idx = GET_IDX(id);

	fvmap_header = fvmap_base;
	fv_table = fvmap_base + fvmap_header[idx].o_ratevolt;
	num_of_lv = fvmap_header[idx].num_of_lv;

	for (i = 0; i < num_of_lv; i++)
		table[i] = fv_table->table[i].volt;

	return num_of_lv;

}

int fvmap_get_raw_voltage_table(unsigned int id)
{
	struct fvmap_header *fvmap_header;
	struct rate_volt_header *fv_table;
	int idx, i;
	int num_of_lv;
	unsigned int table[20];

	idx = GET_IDX(id);

	fvmap_header = sram_fvmap_base;
	fv_table = sram_fvmap_base + fvmap_header[idx].o_ratevolt;
	num_of_lv = fvmap_header[idx].num_of_lv;

	for (i = 0; i < num_of_lv; i++)
		table[i] = fv_table->table[i].volt;

	for (i = 0; i < num_of_lv; i++)
		printk("dvfs id : %d  %d Khz : %d uv\n", ACPM_VCLK_TYPE | id, fv_table->table[i].rate, table[i]);

	return 0;
}

static void check_percent_margin(struct rate_volt_header *head, unsigned int num_of_lv)
{
	int org_volt;
	int percent_volt;
	int i;

	if (!volt_offset_percent)
		return;

	for (i = 0; i < num_of_lv; i++) {
		org_volt = head->table[i].volt;
		percent_volt = org_volt * volt_offset_percent / 100;
		head->table[i].volt = org_volt + rounddown(percent_volt, STEP_UV);
	}
}

static int get_vclk_id_from_margin_id(int margin_id)
{
	int size = cmucal_get_list_size(ACPM_VCLK_TYPE);
	int i;
	struct vclk *vclk;

	for (i = 0; i < size; i++) {
		vclk = cmucal_get_node(ACPM_VCLK_TYPE | i);

		if (vclk->margin_id == margin_id)
			return i;
	}

	return -EINVAL;
}

#define attr_percent(margin_id, type)								\
static ssize_t show_##type##_percent								\
(struct kobject *kobj, struct kobj_attribute *attr, char *buf)					\
{												\
	return snprintf(buf, PAGE_SIZE, "%d\n", percent_margin_table[margin_id]);		\
}												\
												\
static ssize_t store_##type##_percent								\
(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count)		\
{												\
	int input, vclk_id;									\
												\
	if (!sscanf(buf, "%d", &input))								\
		return -EINVAL;									\
												\
	if (input < -100 || input > 100)							\
		return -EINVAL;									\
												\
	vclk_id = get_vclk_id_from_margin_id(margin_id);					\
	if (vclk_id == -EINVAL)									\
		return vclk_id;									\
	percent_margin_table[margin_id] = input;						\
	cal_dfs_set_volt_margin(vclk_id | ACPM_VCLK_TYPE, input);				\
												\
	return count;										\
}												\
												\
static struct kobj_attribute type##_percent =							\
__ATTR(type##_percent, 0600,									\
	show_##type##_percent, store_##type##_percent)

attr_percent(MARGIN_MIF, mif_margin);
attr_percent(MARGIN_INT, int_margin);
attr_percent(MARGIN_BIG, big_margin);
attr_percent(MARGIN_MID, mid_margin);
attr_percent(MARGIN_LIT, lit_margin);
attr_percent(MARGIN_G3D, g3d_margin);
attr_percent(MARGIN_INTCAM, intcam_margin);
attr_percent(MARGIN_CAM, cam_margin);
attr_percent(MARGIN_DISP, disp_margin);
attr_percent(MARGIN_CP, cp_margin);
attr_percent(MARGIN_FSYS0, fsys0_margin);
attr_percent(MARGIN_AUD, aud_margin);
attr_percent(MARGIN_IVA, iva_margin);
attr_percent(MARGIN_SCORE, score_margin);
attr_percent(MARGIN_NPU, npu_margin);
attr_percent(MARGIN_MFC, mfc_margin);

static struct attribute *percent_margin_attrs[] = {
	&mif_margin_percent.attr,
	&int_margin_percent.attr,
	&big_margin_percent.attr,
	&mid_margin_percent.attr,
	&lit_margin_percent.attr,
	&g3d_margin_percent.attr,
	&intcam_margin_percent.attr,
	&cam_margin_percent.attr,
	&disp_margin_percent.attr,
	&cp_margin_percent.attr,
	&fsys0_margin_percent.attr,
	&aud_margin_percent.attr,
	&iva_margin_percent.attr,
	&score_margin_percent.attr,
	&npu_margin_percent.attr,
	&mfc_margin_percent.attr,
	NULL,
};

static const struct attribute_group percent_margin_group = {
	.attrs = percent_margin_attrs,
};

static void optimize_rate_volt_table(struct rate_volt_header *head, unsigned int num_of_lv) {
	bool changed;
	int i;

	/* optimize voltages */
	while (true) {
		changed = false;

		for (i = 1; i < num_of_lv; i++) {
			/* switch voltages if higher frequency uses less */
			if (head->table[i].volt > head->table[i-1].volt) {
				int temp_volt = head->table[i-1].volt;

				head->table[i-1].volt = head->table[i].volt;
				head->table[i].volt = temp_volt;

				changed = true;
			}
		}

		if (!changed)
			break;
	}
}

static inline ssize_t print_fvmap(char *buf, int start, int end)
{
	volatile struct fvmap_header *fvmap_header;
	struct rate_volt_header *cur;
	struct vclk *vclk;
	int size;
	int i, j;
	ssize_t len = 0;

	fvmap_header = fvmap_base;
	size = cmucal_get_list_size(ACPM_VCLK_TYPE);

	for (i = 0; i < size; i++) {
		vclk = cmucal_get_node(ACPM_VCLK_TYPE | i);
		if (vclk == NULL)
			continue;
		cur = fvmap_base + fvmap_header[i].o_ratevolt;

		pr_info("dvfs_type : %s - id : %x\n",
			vclk->name, fvmap_header[i].dvfs_type);
		pr_info("  num_of_lv      : %d\n", fvmap_header[i].num_of_lv);
		pr_info("  num_of_members : %d\n", fvmap_header[i].num_of_members);
		for (j = 0; j < fvmap_header[i].num_of_lv; j++)
			pr_info("  lv : [%7d], volt = %d uV (%d %%) \n",
				cur->table[j].rate, cur->table[j].volt,
				volt_offset_percent);

		if (buf != NULL && i >= start && i < end) {
			len += sprintf(buf + len, "dvfs_type : %s - id : %u\n",
				vclk->name, fvmap_header[i].dvfs_type);
			len += sprintf(buf + len, "  num_of_lv      : %d\n", fvmap_header[i].num_of_lv);

			for (j = 0; j < fvmap_header[i].num_of_lv; j++)
				len += sprintf(buf + len, "  rate : %7d Hz, volt : %d uV\n",
					cur->table[j].rate, cur->table[j].volt);
		}
	}

	return len;
}

static void fvmap_copy_from_sram(void __iomem *map_base, void __iomem *sram_base)
{
	volatile struct fvmap_header *fvmap_header, *header;
	struct rate_volt_header *old, *new;
	struct clocks *clks;
	struct pll_header *plls;
	struct vclk *vclk;
	unsigned int member_addr;
	unsigned int blk_idx;
	int size, margin;
	int i, j;

	fvmap_header = map_base;
	header = sram_base;

	size = cmucal_get_list_size(ACPM_VCLK_TYPE);

	for (i = 0; i < size; i++) {
		/* load fvmap info */
		fvmap_header[i].dvfs_type = header[i].dvfs_type;
		fvmap_header[i].num_of_lv = header[i].num_of_lv;
		fvmap_header[i].num_of_members = header[i].num_of_members;
		fvmap_header[i].num_of_pll = header[i].num_of_pll;
		fvmap_header[i].num_of_mux = header[i].num_of_mux;
		fvmap_header[i].num_of_div = header[i].num_of_div;
		fvmap_header[i].gearratio = header[i].gearratio;
		fvmap_header[i].init_lv = header[i].init_lv;
		fvmap_header[i].num_of_gate = header[i].num_of_gate;
		fvmap_header[i].reserved[0] = header[i].reserved[0];
		fvmap_header[i].reserved[1] = header[i].reserved[1];
		fvmap_header[i].block_addr[0] = header[i].block_addr[0];
		fvmap_header[i].block_addr[1] = header[i].block_addr[1];
		fvmap_header[i].block_addr[2] = header[i].block_addr[2];
		fvmap_header[i].o_members = header[i].o_members;
		fvmap_header[i].o_ratevolt = header[i].o_ratevolt;
		fvmap_header[i].o_tables = header[i].o_tables;

		vclk = cmucal_get_node(ACPM_VCLK_TYPE | i);
		if (vclk == NULL)
			continue;

		old = sram_base + fvmap_header[i].o_ratevolt;
		new = map_base + fvmap_header[i].o_ratevolt;
		
		optimize_rate_volt_table(old, fvmap_header[i].num_of_lv);

		check_percent_margin(old, fvmap_header[i].num_of_lv);

		margin = init_margin_table[vclk->margin_id];
		if (margin)
			cal_dfs_set_volt_margin(i | ACPM_VCLK_TYPE, margin);

		for (j = 0; j < fvmap_header[i].num_of_members; j++) {
			clks = sram_base + fvmap_header[i].o_members;

			if (j < fvmap_header[i].num_of_pll) {
				plls = sram_base + clks->addr[j];
				member_addr = plls->addr - 0x90000000;
			} else {

				member_addr = (clks->addr[j] & ~0x3) & 0xffff;
				blk_idx = clks->addr[j] & 0x3;

				member_addr |= ((fvmap_header[i].block_addr[blk_idx]) << 16) - 0x90000000;
			}


			vclk->list[j] = cmucal_get_id_by_addr(member_addr);

			if (vclk->list[j] == INVALID_CLK_ID)
				pr_info("  Invalid addr :0x%x\n", member_addr);
			else
				pr_info("  DVFS CMU addr:0x%x\n", member_addr);
		}

		for (j = 0; j < fvmap_header[i].num_of_lv; j++) {
			new->table[j].rate = old->table[j].rate;
			new->table[j].volt = old->table[j].volt;
		}
	}
}

static int patch_fvmap(void __iomem *map_base, unsigned int dvfs_type, unsigned int rate, unsigned int volt)
{
	volatile struct fvmap_header *fvmap_header;
	struct rate_volt_header *rvh;
	bool exists = false;
	int size, rest;
	int i, j, k;
	int ret = 0;

	if (rate < 1)
		return -1;

	fvmap_header = map_base;
	size = cmucal_get_list_size(ACPM_VCLK_TYPE);

	if (volt > 10000)
		if ((rest = volt % STEP_UV) != 0) 
				volt += STEP_UV - rest;

	for (i = 0; i < size; i++) {
		if (fvmap_header[i].dvfs_type == dvfs_type) {
			rvh = map_base + fvmap_header[i].o_ratevolt;

			for (j = 0; j < fvmap_header[i].num_of_lv; j++) {
				if (rvh->table[j].rate == rate) {
					exists = true;
					break;
				}
			}

			if (exists) {
				if (volt > 0) {
					for (j = 0; j < fvmap_header[i].num_of_lv; j++) {
						if (rvh->table[j].rate == rate) {
							if (volt > 10000)
								rvh->table[j].volt = volt;
							else
								rvh->table[j].volt += volt * STEP_UV;
							break;
						}
					}
				} else {
					for (j = 0; j < fvmap_header[i].num_of_lv; j++) {
						if (rvh->table[j].rate == rate) {
							for (k = j; k < fvmap_header[i].num_of_lv - 1; k++) {
								rvh->table[k].rate = rvh->table[k + 1].rate;
								rvh->table[k].volt = rvh->table[k + 1].volt;
							}
							fvmap_header[i].num_of_lv--;
							break;
						}
					}
				}
				ret = 1;
			} else {
				int insertPosition = -1;

				for (j = 0; j < fvmap_header[i].num_of_lv; j++) {
					if (rvh->table[j].rate < rate) {
						insertPosition = j;
						break;
					}
				}

				if (insertPosition < 0)
					insertPosition = fvmap_header[i].num_of_lv;

				for (j = fvmap_header[i].num_of_lv; j > insertPosition; j--) {
					rvh->table[j].rate = rvh->table[j - 1].rate;
					rvh->table[j].volt = rvh->table[j - 1].volt;
				}

				rvh->table[insertPosition].rate = rate;
				if (volt > 10000)
					rvh->table[insertPosition].volt = volt;
				else if (volt > 0)
					rvh->table[insertPosition].volt += volt * STEP_UV;

				fvmap_header[i].num_of_lv++;
			}
			break;
		}
	}

	return ret;
}

int fvmap_patch(unsigned int dvfs_type, unsigned int rate, unsigned int volt)
{
	int ret;

	ret = patch_fvmap(fvmap_base, dvfs_type, rate, volt);
	if (ret == 1) {
		ret = 0;
		patch_fvmap(sram_fvmap_base, dvfs_type, rate, volt);
	}

	return ret;
}

static ssize_t show_patch(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
	return print_fvmap(buf, 2, 5); /* Only Print CL0/CL1/G3D to Buffer */
}

static ssize_t store_patch(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count)
{
	volatile struct fvmap_header *fvmap_header;
	unsigned int dvfs, rate, volt = 0;
	struct vclk *vclk;
	char dvfs_name[63];
	size_t ret;
	int size;
	int i;

	if (sscanf(buf, "%s %u %u", dvfs_name, &rate, &volt) != 3 &&
		sscanf(buf, "%u %u %u", &dvfs, &rate, &volt) != 3 &&
		sscanf(buf, "%s:%u:%u", dvfs_name, &rate, &volt) != 3 &&
		sscanf(buf, "%u:%u:%u", &dvfs, &rate, &volt) != 3)
		return -EINVAL;

	if (!dvfs) {
		fvmap_header = fvmap_base;
		size = cmucal_get_list_size(ACPM_VCLK_TYPE);

		for (i = 0; i < size; i++) {
			vclk = cmucal_get_node(ACPM_VCLK_TYPE | i);
			if (vclk == NULL)
				continue;
			if (strstr(vclk->name, dvfs_name) != NULL) {
				dvfs = fvmap_header[i].dvfs_type;
				break;
			}
		}
	}

	if (!dvfs)
		return -EINVAL;

	ret = fvmap_patch(dvfs, rate, volt);
	if (ret)
		return ret;

	return count;
}

static struct kobj_attribute patch =
__ATTR(patch, 0644, show_patch, store_patch);

static struct attribute *fvmap_attrs[] = {
	&patch.attr,
	NULL,
};

static const struct attribute_group fvmap_group = {
	.attrs = fvmap_attrs,
};

int fvmap_init(void __iomem *sram_base)
{
	void __iomem *map_base;
	struct kobject *kobj;

	map_base = kzalloc(FVMAP_SIZE, GFP_KERNEL);

	fvmap_base = map_base;
	sram_fvmap_base = sram_base;
	pr_info("%s:fvmap initialize %p\n", __func__, sram_base);
	fvmap_copy_from_sram(fvmap_base, sram_base);
	print_fvmap(NULL, 0, 0);

	kobj = kobject_create_and_add("fvmap", power_kobj);
	if (!kobj)
		pr_err("Fail to create fvmap kboject\n");

	if (sysfs_create_group(kobj, &fvmap_group))
		pr_err("Fail to create fvmap group\n");

	/* percent margin for each doamin at runtime */
	kobj = kobject_create_and_add("percent_margin", power_kobj);
	if (!kobj)
		pr_err("Fail to create percent_margin kboject\n");

	if (sysfs_create_group(kobj, &percent_margin_group))
		pr_err("Fail to create percent_margin group\n");

	return 0;
}
