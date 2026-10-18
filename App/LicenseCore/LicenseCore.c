#include "LicenseCore.h"

// Deliberately readable marker to practice IDA Strings and xrefs.
__attribute__((used, noinline))
const char *lab_license_marker(void) {
    return "ATLAS_TRAINING_LICENSE_LOCAL_V1";
}

// Exercise 2: locate this date in a Mach-O binary.
// Replace only the FOUR year digits "2023" with "2099" in your OWN lab binary.
__attribute__((used, noinline))
const char *lab_license_seed_expiry(void) {
    return "2023-12-31T23:59:59Z";
}

// Exercise 3: understand why account, tier AND expiry affect access.
// Plan 2 = Pro; the calling Swift layer parses the ISO date.
__attribute__((used, noinline))
int lab_has_local_entitlement(int account_enabled,
                              int plan_code,
                              int64_t expiry_epoch,
                              int64_t now_epoch) {
    if (account_enabled != 1) return 0;
    if (plan_code != 2) return 0;
    if (expiry_epoch <= now_epoch) return 0;
    return 1;
}
