#ifndef AX_CONFIG_IMAGE_H
#define AX_CONFIG_IMAGE_H
#include "macro_store.h"

enum { AX_PREFIX = 68, AX_TRAILER = 12,
       AX_V41_BLOB = AX_PREFIX + AX_OLD_IMAGE + AX_TRAILER,
       AX_V2_BLOB = AX_PREFIX + AX_IMAGE + AX_TRAILER };

struct ax_config_image {
    ax_u8 prefix[AX_PREFIX];
    struct ax_store profiles;
    ax_u8 trailer[AX_TRAILER];
};

/* Source/destination must not overlap. These functions do no device I/O. */
int ax_config_import_v41(struct ax_config_image *dest, const ax_u8 *data, ax_u32 size);
int ax_config_read(const struct ax_config_image *image, ax_u8 *data, ax_u32 size);
int ax_config_restore(struct ax_config_image *dest, const ax_u8 *data, ax_u32 size);

#endif
