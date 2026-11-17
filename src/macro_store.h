#ifndef AX_MACRO_STORE_H
#define AX_MACRO_STORE_H

/* Offline/firmware-core prototype. No absolute SRAM addresses or device I/O. */
typedef unsigned char ax_u8;
typedef unsigned short ax_u16;
typedef unsigned int ax_u32;

enum {
    AX_PROFILES = 3, AX_SLOTS = 4, AX_PARAMS = 144,
    AX_HEADER = 10, AX_RECORD = 6,
    AX_OLD_SLOT = 220, AX_OLD_PROFILE = 1024,
    AX_MAX_RECORDS = 67,
    AX_SLOT = AX_HEADER + AX_RECORD * AX_MAX_RECORDS,
    AX_PROFILE = AX_PARAMS + AX_SLOTS * AX_SLOT,
    AX_IMAGE = AX_PROFILES * AX_PROFILE,
    AX_OLD_IMAGE = AX_PROFILES * AX_OLD_PROFILE,
    AX_OK = 0, AX_BAD_INDEX = -1, AX_BAD_LENGTH = -2,
    AX_BAD_CRC = -3, AX_FULL = -4, AX_BAD_BUFFER = -5
};

struct ax_store { ax_u8 bytes[AX_IMAGE]; };

ax_u16 ax_crc16(const ax_u8 *data, ax_u32 size);
int ax_macro_validate(const ax_u8 *data, ax_u32 size, ax_u32 capacity);
int ax_store_init(struct ax_store *store);
int ax_store_import_v41(struct ax_store *store, const ax_u8 *old_profiles, ax_u32 size);
int ax_macro_replace(struct ax_store *store, ax_u32 profile, ax_u32 slot,
                     const ax_u8 *data, ax_u32 size);
int ax_macro_append(struct ax_store *store, ax_u32 profile, ax_u32 slot,
                    const ax_u8 record[AX_RECORD]);
int ax_macro_read(const struct ax_store *store, ax_u32 profile, ax_u32 slot,
                  ax_u8 *out, ax_u32 capacity);
int ax_image_read(const struct ax_store *store, ax_u8 *out, ax_u32 size);
int ax_image_restore(struct ax_store *store, const ax_u8 *data, ax_u32 size);

#endif
