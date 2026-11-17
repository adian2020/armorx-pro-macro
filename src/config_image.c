#include "config_image.h"

typedef char ax_blob_check[(sizeof(struct ax_config_image) == 5456) ? 1 : -1];
typedef char ax_legacy_check[(AX_V41_BLOB == 3152) ? 1 : -1];

static void copy(ax_u8 *to, const ax_u8 *from, ax_u32 count) {
    while (count--) *to++ = *from++;
}

static int trailer_valid(const ax_u8 *data) {
    /* The original q32s store h[tail+2] = 0x0c00 writes bytes 00 0c:
       this is the 12-byte record's big-endian length, NOT a 3072-byte size. */
    ax_u16 crc;
    if (data[2] != 0 || data[3] != AX_TRAILER) return 0;
    crc = (ax_u16)(((ax_u16)data[0] << 8) | data[1]);
    return crc == ax_crc16(data + 2, AX_TRAILER - 2);
}

int ax_config_import_v41(struct ax_config_image *dest, const ax_u8 *data, ax_u32 size) {
    int result;
    if (!dest || !data) return AX_BAD_BUFFER;
    if (size != AX_V41_BLOB) return AX_BAD_LENGTH;
    if (!trailer_valid(data + AX_PREFIX + AX_OLD_IMAGE)) return AX_BAD_CRC;
    result = ax_store_import_v41(&dest->profiles, data + AX_PREFIX, AX_OLD_IMAGE);
    if (result) return result;
    copy(dest->prefix, data, AX_PREFIX);
    copy(dest->trailer, data + AX_PREFIX + AX_OLD_IMAGE, AX_TRAILER);
    return AX_OK;
}

int ax_config_read(const struct ax_config_image *image, ax_u8 *data, ax_u32 size) {
    int result;
    if (!image || !data) return AX_BAD_BUFFER;
    if (size != AX_V2_BLOB) return AX_BAD_LENGTH;
    if (!trailer_valid(image->trailer)) return AX_BAD_CRC;
    result = ax_image_read(&image->profiles, data + AX_PREFIX, AX_IMAGE);
    if (result) return result;
    copy(data, image->prefix, AX_PREFIX);
    copy(data + AX_PREFIX + AX_IMAGE, image->trailer, AX_TRAILER);
    return AX_OK;
}

int ax_config_restore(struct ax_config_image *dest, const ax_u8 *data, ax_u32 size) {
    int result;
    if (!dest || !data) return AX_BAD_BUFFER;
    if (size != AX_V2_BLOB) return AX_BAD_LENGTH;
    if (!trailer_valid(data + AX_PREFIX + AX_IMAGE)) return AX_BAD_CRC;
    result = ax_image_restore(&dest->profiles, data + AX_PREFIX, AX_IMAGE);
    if (result) return result;
    copy(dest->prefix, data, AX_PREFIX);
    copy(dest->trailer, data + AX_PREFIX + AX_IMAGE, AX_TRAILER);
    return AX_OK;
}
