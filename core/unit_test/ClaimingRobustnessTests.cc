/******************************************************************************
 * Copyright (c) 2014, AllSeen Alliance. All rights reserved.
 *
 *    Permission to use, copy, modify, and/or distribute this software for any
 *    purpose with or without fee is hereby granted, provided that the above
 *    copyright notice and this permission notice appear in all copies.
 *
 *    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *    WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *    MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *    ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *    WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *    ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *    OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 ******************************************************************************/

#include "gtest/gtest.h"
#include "SecurityManagerFactory.h"
#include "PermissionMgmt.h"
#include "Stub.h"
#include "TestUtil.h"
#include "SecurityInfo.h"
#include <semaphore.h>


/**
 * Several claiming robustness tests.
 */

namespace secmgrcoretest_unit_robustnesstests {
using namespace secmgrcoretest_unit_testutil;

using namespace ajn::securitymgr;
using namespace std;

class ClaimingRobustnessTests :
    public ClaimTest {
  private:

  protected:

  public:
    ClaimingRobustnessTests()
    {
    }
};

/**
 * \test The test should make sure that the security manager handles properly
 *       the response of a stub client that already has an ROT
 *       -# Create a security manager 1 and announce it.
 *       -# Create a security manager 2 and announce it.
 *       -# Create a stub client and make it claimable.
 *       -# Try to claim the stub client from both security managers at the same time.
 *       -# Verify that exactly one security manager has claimed the stub client
 *          and that the stub client has the right ROT and an identity certificate.

 * */
TEST_F(ClaimingRobustnessTests, DISABLED_FailedClaimingExistingROT) {
    // ASSERT_TRUE(false);
}

/**
 * \test The test should make sure that the security manager handles properly
 *       the response of a stub client that already has an ROT
 *       -# Create a security manager and announce it.
 *       -# Create a stub client and make it claimable.
 *       -# Try to claim the stub client but introduce a network error, e.g., session lost
 *       -# Verify that the security manager did not claim the stub client and that the client
 *          has no ROT nor an identity certificate.
 * */
TEST_F(ClaimingRobustnessTests, DISABLED_FailedClaimingNetError) {
    //   ASSERT_TRUE(false);
}

/**
 * \test The test should make sure that the claim method handles and request in  robust way
 *  - unknown application
 *  - bad busname
 *  - ...
 * */
TEST_F(ClaimingRobustnessTests,  DISABLED_InvalidArguments) {
    sem_t sem;
    sem_init(&sem, 0, 0);
    bool claimAnswer = true;
    TestClaimListener tcl(claimAnswer);
    TestApplicationListener tal(sem);

    secMgr->RegisterApplicationListener(&tal);

    Stub* stub = new Stub(&tcl);
    ASSERT_EQ(stub->OpenClaimWindow(), ER_OK);
    sem_wait(&sem);

    ApplicationInfo info = tal._lastAppInfo;
    info.publicKey = "My Rubbish Key";
    info.busName = tal._lastAppInfo.busName;

    ASSERT_EQ(secMgr->ClaimApplication(info), ER_FAIL);

    info.publicKey = tal._lastAppInfo.publicKey;
    info.busName = "My Rubbish BusName"; //the bad busname should be ignored
    ASSERT_EQ(secMgr->ClaimApplication(info), ER_OK);

    ASSERT_NE(secMgr->ClaimApplication(tal._lastAppInfo), ER_OK); //already claimed

    delete stub;
    ASSERT_NE(secMgr->ClaimApplication(tal._lastAppInfo), ER_OK); //we killed our peer.
}

//TODO Add more tests for failed claiming as per identified claiming errors in the future
}
//namespace
