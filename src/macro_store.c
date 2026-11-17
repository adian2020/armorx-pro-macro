#include "macro_store.h"

typedef char ax_slot_size_check[(AX_SLOT == 412) ? 1 : -1];
typedef char ax_profile_size_check[(AX_PROFILE == 1792) ? 1 : -1];
typedef char ax_image_size_check[(AX_IMAGE == 5376) ? 1 : -1];

static void copy_bytes(ax_u8 *to, const ax_u8 *from, ax_u32 size) {
    while (size--) *to++ = *from++;
}
static void zero_bytes(ax_u8 *to, ax_u32 size) {
    while (size--) *to++ = 0;
}
static ax_u16 be16(const ax_u8 *p) { return ((ax_u16)p[0] << 8) | p[1]; }
static void put_be16(ax_u8 *p, ax_u16 value) {
    p[0] = (ax_u8)(value >> 8); p[1] = (ax_u8)value;
}
static int valid_index(ax_u32 profile, ax_u32 slot) {
    return profile < AX_PROFILES && slot < AX_SLOTS;
}
static ax_u32 macro_offset(ax_u32 profile, ax_u32 slot) {
    return profile * AX_PROFILE + AX_PARAMS + slot * AX_SLOT;
}

ax_u16 ax_crc16(const ax_u8 *data, ax_u32 size) {
    ax_u16 crc = 0xffff;
    while (size--) {
        ax_u32 bit;
        crc ^= *data++;
        for (bit = 0; bit < 8; ++bit)
            crc = (ax_u16)((crc >> 1) ^ ((crc & 1) ? 0xa001 : 0));
    }
    return crc;
}

static void seal_macro(ax_u8 *macro, ax_u32 size) {
    put_be16(macro + 2, (ax_u16)size);
    put_be16(macro, ax_crc16(macro + 2, size - 2));
}

int ax_macro_validate(const ax_u8 *data, ax_u32 size, ax_u32 capacity) {
    if (!data) return AX_BAD_BUFFER;
    if (size < AX_HEADER || size > capacity || size > AX_SLOT ||
        (size - AX_HEADER) % AX_RECORD || be16(data + 2) != size)
        return AX_BAD_LENGTH;
    if (be16(data) != ax_crc16(data + 2, size - 2)) return AX_BAD_CRC;
    return AX_OK;
}

int ax_store_init(struct ax_store *store) {
    ax_u32 p, s;
    if (!store) return AX_BAD_BUFFER;
    zero_bytes(store->bytes, AX_IMAGE);
    for (p = 0; p < AX_PROFILES; ++p) {
        /* Valid empty parameter record, not a device factory configuration. */
        ax_u8 *params = store->bytes + p * AX_PROFILE;
        put_be16(params + 2, AX_PARAMS);
        put_be16(params, ax_crc16(params + 2, AX_PARAMS - 2));
        for (s = 0; s < AX_SLOTS; ++s) {
            ax_u8 *macro = store->bytes + macro_offset(p, s);
            macro[5] = (ax_u8)s;
            macro[6] = 32; /* Existing empty-macro trigger sentinel. */
            seal_macro(macro, AX_HEADER);
        }
    }
    return AX_OK;
}

static int validate_profile_params(const ax_u8 *params) {
    return be16(params + 2) == AX_PARAMS &&
           be16(params) == ax_crc16(params + 2, AX_PARAMS - 2);
}

int ax_store_import_v41(struct ax_store *store, const ax_u8 *old, ax_u32 size) {
    ax_u32 p, s;
    if (!store || !old) return AX_BAD_BUFFER;
    if (size != AX_OLD_IMAGE) return AX_BAD_LENGTH;
    /* Validate everything before changing the destination. Source must not
       overlap destination; the firmware adapter must provide distinct buffers. */
    for (p = 0; p < AX_PROFILES; ++p) {
        if (!validate_profile_params(old + p * AX_OLD_PROFILE)) return AX_BAD_CRC;
        for (s = 0; s < AX_SLOTS; ++s) {
            const ax_u8 *macro = old + p * AX_OLD_PROFILE + AX_PARAMS + s * AX_OLD_SLOT;
            int result = ax_macro_validate(macro, be16(macro + 2), AX_OLD_SLOT);
            if (result) return result;
        }
    }
    for (p = 0; p < AX_PROFILES; ++p) {
        copy_bytes(store->bytes + p * AX_PROFILE, old + p * AX_OLD_PROFILE, AX_PARAMS);
        for (s = 0; s < AX_SLOTS; ++s) {
            const ax_u8 *macro = old + p * AX_OLD_PROFILE + AX_PARAMS + s * AX_OLD_SLOT;
            ax_u8 *dest = store->bytes + macro_offset(p, s);
            copy_bytes(dest, macro, AX_OLD_SLOT);
            zero_bytes(dest + AX_OLD_SLOT, AX_SLOT - AX_OLD_SLOT);
        }
    }
    return AX_OK;
}

int ax_macro_replace(struct ax_store *store, ax_u32 p, ax_u32 s,
                     const ax_u8 *data, ax_u32 size) {
    ax_u8 *dest;
    int result;
    if (!store) return AX_BAD_BUFFER;
    if (!valid_index(p, s)) return AX_BAD_INDEX;
    result = ax_macro_validate(data, size, AX_SLOT);
    if (result) return result;
    dest = store->bytes + macro_offset(p, s);
    copy_bytes(dest, data, size);
    zero_bytes(dest + size, AX_SLOT - size);
    return AX_OK;
}

int ax_macro_append(struct ax_store *store, ax_u32 p, ax_u32 s,
                    const ax_u8 record[AX_RECORD]) {
    ax_u8 *macro;
    ax_u32 size;
    int result;
    if (!store || !record) return AX_BAD_BUFFER;
    if (!valid_index(p, s)) return AX_BAD_INDEX;
    macro = store->bytes + macro_offset(p, s);
    size = be16(macro + 2);
    result = ax_macro_validate(macro, size, AX_SLOT);
    if (result) return result;
    if (size > AX_SLOT - AX_RECORD) return AX_FULL;
    copy_bytes(macro + size, record, AX_RECORD);
    seal_macro(macro, size + AX_RECORD);
    return AX_OK;
}

int ax_macro_read(const struct ax_store *store, ax_u32 p, ax_u32 s,
                  ax_u8 *out, ax_u32 capacity) {
    const ax_u8 *macro;
    ax_u32 size;
    int result;
    if (!store || !out) return AX_BAD_BUFFER;
    if (!valid_index(p, s)) return AX_BAD_INDEX;
    macro = store->bytes + macro_offset(p, s);
    size = be16(macro + 2);
    result = ax_macro_validate(macro, size, AX_SLOT);
    if (result) return result;
    if (capacity < size) return AX_BAD_LENGTH;
    copy_bytes(out, macro, size);
    return (int)size;
}

int ax_image_read(const struct ax_store *store, ax_u8 *out, ax_u32 size) {
    if (!store || !out) return AX_BAD_BUFFER;
    if (size != AX_IMAGE) return AX_BAD_LENGTH;
    copy_bytes(out, store->bytes, AX_IMAGE);
    return AX_OK;
}

int ax_image_restore(struct ax_store *store, const ax_u8 *data, ax_u32 size) {
    ax_u32 p, s;
    if (!store || !data) return AX_BAD_BUFFER;
    if (size != AX_IMAGE) return AX_BAD_LENGTH;
    for (p = 0; p < AX_PROFILES; ++p) {
        if (!validate_profile_params(data + p * AX_PROFILE)) return AX_BAD_CRC;
        for (s = 0; s < AX_SLOTS; ++s) {
            const ax_u8 *macro = data + macro_offset(p, s);
            int result = ax_macro_validate(macro, be16(macro + 2), AX_SLOT);
            if (result) return result;
        }
    }
    copy_bytes(store->bytes, data, AX_IMAGE);
    return AX_OK;
}
