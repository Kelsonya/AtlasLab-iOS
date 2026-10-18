#include "../App/GateCore/NativeGate.h"
#include <stdio.h>
#include <assert.h>
int main(void) {
    ALGrant expired = al_grant_for_profile("orion");
    ALGrant active = al_grant_for_profile("nova");
    ALGrant blocked = al_grant_for_profile("quartz");
    assert(al_integrity(&expired));
    assert(!al_check_expiry(&expired, 1792281600U));
    assert(al_check_expiry(&active, 1792281600U));
    assert(!al_check_expiry(&blocked, 1792281600U));
    assert(al_check_feature(&active, 4U));
    expired.expiration = 4102444799ULL;
    assert(!al_integrity(&expired));
    puts("native gate smoke tests OK");
    return 0;
}
