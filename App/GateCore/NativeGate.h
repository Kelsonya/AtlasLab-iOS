#ifndef ATLAS_NATIVE_GATE_H
#define ATLAS_NATIVE_GATE_H
#include <stdint.h>

typedef struct {
    uint64_t expiration;
    uint32_t feature_bits;
    uint16_t tier;
    uint16_t flags;
    uint32_t seal;
} ALGrant;

ALGrant al_grant_for_profile(const char *profile);
int al_integrity(const ALGrant *grant);
int al_check_expiry(const ALGrant *grant, uint64_t now);
int al_check_feature(const ALGrant *grant, uint32_t requested_bit);
uint32_t al_profile_hash(const char *name);
uint32_t al_gate_fingerprint(const ALGrant *grant);
#endif
