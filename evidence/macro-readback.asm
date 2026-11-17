 1e09466:    00 f9 03 90       	r0 = b[r9 + 0x3] (u)
 1e0946a:    40 e0 1c 20       	if (r0 >= 0x4) goto 0x38
 1e0946e:    02 f6 b8 81       	r2 = [r8 + 0x1b8]
 1e09472:    c1 7d             	r1 = 0xdc
 1e09474:    23 08             	r3 = r2
 1e09476:    80 fe 10 30       	r3 += r0 * r1
 1e0947a:    31 66             	r1 = b[r3 + 0x3] (u)
 1e0947c:    23 66             	r3 = b[r3 + 0x2] (u)
 1e0947e:    d8 fd 40 31       	r3 <= insert(r1, p:0x8, l:0x18)
 1e09482:    30 fb 00 13       	r1 = rev8(r3)
 1e09486:    0b d4             	r3 = r1 >> 0x10
 1e09488:    11 18             	goto 0x22
 1e0948a:    07 70             	r7 = 0x0
 1e0948c:    5a 1e             	goto -0x34c
 1e0948e:    e0 fb 12 02       	r0 = sp + 530
 1e09492:    11 90             	r1 = r0 + 0x1
 1e09494:    10 70             	r0 = 0x1
 1e09496:    bf f3 ab d7       	call -0x50aa
 1e0949a:    10 80             	r0 += 0x1
 1e0949c:    03 04             	r3 = r0.b0 (u)
 1e0949e:    e2 fb 12 02       	r2 = sp + 530
 1e094a2:    51 7e             	r1 = 0xe5
 1e094a4:    2c 18             	goto 0x58
 1e094a6:    02 f6 b8 81       	r2 = [r8 + 0x1b8]
 1e094aa:    03 70             	r3 = 0x0
 1e094ac:    c1 7d             	r1 = 0xdc
 1e094ae:    80 fe 10 20       	r2 += r0 * r1
 1e094b2:    91 7d             	r1 = 0xd9
 1e094b4:    48 18             	goto 0x90
