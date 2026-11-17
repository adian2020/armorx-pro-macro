#include "macro_store.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>

static void seal(ax_u8 *data, unsigned n) {
    unsigned crc;
    data[2] = (ax_u8)(n >> 8); data[3] = (ax_u8)n;
    crc = ax_crc16(data + 2, n - 2);
    data[0] = (ax_u8)(crc >> 8); data[1] = (ax_u8)crc;
}

int main(void) {
    struct { ax_u8 before[32]; struct ax_store value; ax_u8 after[32]; } guarded;
    struct ax_store restored, snapshot;
    ax_u8 old[AX_OLD_IMAGE], saved[AX_IMAGE], packet[AX_SLOT + AX_RECORD];
    ax_u8 record[6] = {0x10, 0x00, 0x01, 0x00, 0x00, 0x00};
    unsigned p, s, i, j;
    memset(&guarded, 0xa5, sizeof(guarded));
    assert(ax_crc16((const ax_u8 *)"123456789", 9) == 0x4b37);
    assert(ax_store_init(&guarded.value) == AX_OK);
    memset(old, 0, sizeof(old));
    /* Three distinct synthetic parameter blocks and twelve distinct macros. */
    for (p = 0; p < AX_PROFILES; ++p) {
        ax_u8 *params = old + p * AX_OLD_PROFILE;
        for (j = 4; j < AX_PARAMS; ++j) params[j] = (ax_u8)(p * 71 + j);
        seal(params, AX_PARAMS);
        for (s = 0; s < AX_SLOTS; ++s) {
            ax_u8 *m = params + AX_PARAMS + s * AX_OLD_SLOT;
            for (j = 4; j < AX_OLD_SLOT; ++j) m[j] = (ax_u8)(p * 83 + s * 13 + j);
            seal(m, AX_OLD_SLOT);
        }
    }
    assert(ax_store_import_v41(&guarded.value, old, sizeof(old)) == AX_OK);
    for (p = 0; p < AX_PROFILES; ++p) {
        assert(!memcmp(guarded.value.bytes + p * AX_PROFILE,
                       old + p * AX_OLD_PROFILE, AX_PARAMS));
        for (s = 0; s < AX_SLOTS; ++s) {
            const ax_u8 *original = old + p * AX_OLD_PROFILE + AX_PARAMS + s * AX_OLD_SLOT;
            assert(ax_macro_read(&guarded.value, p, s, packet, sizeof(packet)) == AX_OLD_SLOT);
            assert(!memcmp(packet, original, AX_OLD_SLOT));
            for (i = 35; i < AX_MAX_RECORDS; ++i) {
                record[2] = (ax_u8)(p * 4 + s); record[3] = (ax_u8)i;
                assert(ax_macro_append(&guarded.value, p, s, record) == AX_OK);
            }
            assert(ax_macro_read(&guarded.value, p, s, packet, sizeof(packet)) == AX_SLOT);
            assert(!memcmp(packet + 4, original + 4, AX_OLD_SLOT - 4));
        }
    }
    snapshot = guarded.value;
    for (p = 0; p < AX_PROFILES; ++p)
        for (s = 0; s < AX_SLOTS; ++s)
            assert(ax_macro_append(&guarded.value, p, s, record) == AX_FULL);
    assert(!memcmp(&snapshot, &guarded.value, sizeof(snapshot)));
    for (i = 0; i < 32; ++i)
        assert(guarded.before[i] == 0xa5 && guarded.after[i] == 0xa5);
    puts("PASS: all 12 macros migrate, independently hold 67 records and reject overflow without mutation");

    assert(ax_image_read(&guarded.value, saved, sizeof(saved)) == AX_OK);
    memset(&restored, 0xdd, sizeof(restored));
    assert(ax_image_restore(&restored, saved, sizeof(saved)) == AX_OK);
    assert(!memcmp(&restored, &guarded.value, sizeof(restored)));
    assert(ax_image_restore(&restored, saved, sizeof(saved) - 1) == AX_BAD_LENGTH);
    saved[AX_PARAMS + 50] ^= 0x80;
    assert(ax_image_restore(&restored, saved, sizeof(saved)) == AX_BAD_CRC);
    assert(!memcmp(&restored, &guarded.value, sizeof(restored)));
    puts("PASS: saved-image restore, truncated/corrupt rejection and parameter preservation");

    assert(ax_macro_append(&guarded.value, 3, 0, record) == AX_BAD_INDEX);
    assert(ax_macro_append(&guarded.value, 0, 4, record) == AX_BAD_INDEX);
    assert(ax_macro_append(0, 0, 0, record) == AX_BAD_BUFFER);
    assert(ax_macro_read(&guarded.value, 0, 0, packet, AX_SLOT - 1) == AX_BAD_LENGTH);
    memset(packet, 0, sizeof(packet));
    seal(packet, sizeof(packet));
    assert(ax_macro_replace(&guarded.value, 0, 0, packet, sizeof(packet)) == AX_BAD_LENGTH);
    seal(packet, AX_HEADER + 1);
    assert(ax_macro_replace(&guarded.value, 0, 0, packet, AX_HEADER + 1) == AX_BAD_LENGTH);
    seal(packet, AX_HEADER);
    packet[0] ^= 1;
    assert(ax_macro_replace(&guarded.value, 0, 0, packet, AX_HEADER) == AX_BAD_CRC);
    old[AX_PARAMS + 20] ^= 1;
    assert(ax_store_import_v41(&guarded.value, old, sizeof(old)) == AX_BAD_CRC);
    assert(!memcmp(&snapshot, &guarded.value, sizeof(snapshot)));
    puts("PASS: invalid indices, lengths, CRCs and null buffers fail before writes");

    /* User reproduction: 32 complete clicks need 64 state-change records. */
    assert(ax_store_init(&restored) == AX_OK);
    for (i = 0; i < 64; ++i) {
        record[2] = (ax_u8)(i & 1);
        assert(ax_macro_append(&restored, 2, 3, record) == AX_OK);
    }
    assert(ax_macro_read(&restored, 2, 3, packet, sizeof(packet)) == 394);
    printf("PASS: 32 complete clicks stored as 64 records, macro size 394 bytes\n");
    printf("Prototype sizes: slot=%d profile=%d profiles=%d; extra profile RAM=%d\n",
           AX_SLOT, AX_PROFILE, AX_IMAGE, AX_IMAGE - AX_OLD_IMAGE);
    return 0;
}
