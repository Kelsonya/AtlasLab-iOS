#include "NativeGate.h"
#include <stddef.h>
#include <string.h>

static uint32_t spin(uint32_t value, unsigned bits) {
    return (value << bits) | (value >> (32U - bits));
}

uint32_t al_profile_hash(const char *name) {
    uint32_t h = 2166136261U;
    if (!name) return 0;
    while (*name) { h = (h ^ (unsigned char)*name++) * 16777619U; }
    return h;
}

static uint32_t make_seal(const ALGrant *g) {
    uint32_t lo = (uint32_t)(g->expiration & 0xffffffffU);
    uint32_t hi = (uint32_t)(g->expiration >> 32U);
    uint32_t v = spin(lo ^ 0xA7B3C19DU, 7) ^ spin(hi + g->feature_bits, 13);
    v ^= (((uint32_t)g->tier << 16U) | g->flags) * 0x9E3779B1U;
    return spin(v, 11) ^ 0x6C8E9CF5U;
}

ALGrant al_grant_for_profile(const char *profile) {
    ALGrant grant = { 0 };
    uint32_t hash = al_profile_hash(profile);
    // Intentionally understandable sample values, but not a plain date string.
    // 1704067199 = 2023-12-31 23:59:59 UTC; 2145916799 = 2037-12-13 UTC.
    grant.expiration = 1704067199ULL;
    grant.feature_bits = 0xffU;
    grant.tier = 2U;
    if (hash == al_profile_hash("nova")) {
        grant.expiration = 2145916799ULL;
        grant.tier = 3U;
    } else if (hash == al_profile_hash("quartz")) {
        grant.expiration = 2145916799ULL;
        grant.flags = 1U;
    } else if (hash == al_profile_hash("echo")) {
        grant.expiration = 2145916799ULL;
        grant.tier = 0U;
        grant.feature_bits = 3U;
    }
    grant.seal = make_seal(&grant);
    return grant;
}

int al_integrity(const ALGrant *grant) {
    if (!grant) return 0;
    return (grant->seal == make_seal(grant)) ? 1 : 0;
}

int al_check_expiry(const ALGrant *grant, uint64_t now) {
    if (!al_integrity(grant)) return 0;
    if (grant->flags & 1U) return 0;
    return now < grant->expiration;
}

int al_check_feature(const ALGrant *grant, uint32_t requested_bit) {
    if (!al_integrity(grant)) return 0;
    return (grant->feature_bits & requested_bit) == requested_bit;
}

uint32_t al_gate_fingerprint(const ALGrant *grant) {
    if (!grant) return 0;
    return spin(grant->seal ^ grant->feature_bits, 9) ^ (uint32_t)grant->expiration;
}
