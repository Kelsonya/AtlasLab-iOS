#ifndef ATLAS_LAB_LICENSE_CORE_H
#define ATLAS_LAB_LICENSE_CORE_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
// Local training entitlement. Not an actual App Store subscription.
const char *lab_license_seed_expiry(void);
const char *lab_license_marker(void);
int lab_has_local_entitlement(int account_enabled, int plan_code, int64_t expiry_epoch, int64_t now_epoch);
#ifdef __cplusplus
}
#endif
#endif
