#include "config_image.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>

static void seal(ax_u8 *p, unsigned size) {
    unsigned crc;
    p[2] = (ax_u8)(size >> 8); p[3] = (ax_u8)size;
    crc = ax_crc16(p + 2, size - 2);
    p[0] = (ax_u8)(crc >> 8); p[1] = (ax_u8)crc;
}

int main(void) {
    ax_u8 old[AX_V41_BLOB], saved[AX_V2_BLOB];
    struct ax_config_image image, snapshot, restored;
    unsigned p, s, i;
    memset(old, 0, sizeof(old));
    for (i = 0; i < AX_PREFIX; ++i) old[i] = (ax_u8)(i * 19);
    for (p = 0; p < AX_PROFILES; ++p) {
        ax_u8 *params = old + AX_PREFIX + p * AX_OLD_PROFILE;
        for (i = 4; i < AX_PARAMS; ++i) params[i] = (ax_u8)(p * 67 + i);
        seal(params, AX_PARAMS);
        for (s = 0; s < AX_SLOTS; ++s) {
            ax_u8 *macro = params + AX_PARAMS + s * AX_OLD_SLOT;
            for (i = 4; i < AX_OLD_SLOT; ++i) macro[i] = (ax_u8)(p * 47 + s * 31 + i);
            seal(macro, AX_OLD_SLOT);
        }
    }
    for (i = 4; i < AX_TRAILER; ++i) old[AX_V41_BLOB - AX_TRAILER + i] = (ax_u8)(0x70 + i);
    seal(old + AX_V41_BLOB - AX_TRAILER, AX_TRAILER);
    assert(ax_config_import_v41(&image, old, sizeof(old)) == AX_OK);
    assert(!memcmp(image.prefix, old, AX_PREFIX));
    assert(!memcmp(image.trailer, old + AX_V41_BLOB - AX_TRAILER, AX_TRAILER));
    assert(image.trailer[2] == 0 && image.trailer[3] == 12);
    assert(ax_config_read(&image, saved, sizeof(saved)) == AX_OK);
    assert(ax_config_restore(&restored, saved, sizeof(saved)) == AX_OK);
    assert(!memcmp(&image, &restored, sizeof(image)));
    snapshot = image;
    old[AX_V41_BLOB - 9] = 0x15; /* Wrong 3072->5376 interpretation corrupts record length. */
    assert(ax_config_import_v41(&image, old, sizeof(old)) == AX_BAD_CRC);
    assert(!memcmp(&image, &snapshot, sizeof(image)));
    saved[AX_V2_BLOB - 1] ^= 1;
    assert(ax_config_restore(&image, saved, sizeof(saved)) == AX_BAD_CRC);
    assert(!memcmp(&image, &snapshot, sizeof(image)));
    puts("PASS: whole-object migration 3152->5456 preserves opaque prefix and 12-byte trailer exactly");
    puts("PASS: incorrect trailer length, CRC and restore are rejected without mutation");
    return 0;
}
