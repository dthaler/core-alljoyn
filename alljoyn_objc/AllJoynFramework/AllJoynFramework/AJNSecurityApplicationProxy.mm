////////////////////////////////////////////////////////////////////////////////
//    Copyright (c) Open Connectivity Foundation (OCF), AllJoyn Open Source
//    Project (AJOSP) Contributors and others.
//
//    SPDX-License-Identifier: Apache-2.0
//
//    All rights reserved. This program and the accompanying materials are
//    made available under the terms of the Apache License, Version 2.0
//    which accompanies this distribution, and is available at
//    http://www.apache.org/licenses/LICENSE-2.0
//
//    Copyright (c) Open Connectivity Foundation and Contributors to AllSeen
//    Alliance. All rights reserved.
//
//    Permission to use, copy, modify, and/or distribute this software for
//    any purpose with or without fee is hereby granted, provided that the
//    above copyright notice and this permission notice appear in all
//    copies.
//
//    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
//    WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
//    WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
//    AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
//    DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
//    PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
//    TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
//    PERFORMANCE OF THIS SOFTWARE.
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import <alljoyn/SecurityApplicationProxy.h>
#import "AJNSecurityApplicationProxy.h"

using namespace ajn;

@interface AJNObject(Private)

@property (nonatomic) BOOL shouldDeleteHandleOnDealloc;

@end

@interface AJNBusAttachment(Private)

@property (nonatomic, readonly) BusAttachment *busAttachment;

@end

@interface AJNGUID128 (Private)

@property (nonatomic, readonly) qcc::GUID128 *guid128;

@end

@interface AJNKeyInfoNISTP256 (Private)

@property (nonatomic, readonly) qcc::KeyInfoNISTP256 *keyInfo;

@end

@interface AJNECCPublicKey (Private)

@property (nonatomic, readonly) qcc::ECCPublicKey *publicKey;

@end

@interface AJNECCPrivateKey (Private)

@property (nonatomic, readonly) qcc::ECCPrivateKey *privateKey;

@end

@interface AJNECCSignature (Private)

@property (nonatomic, readonly) qcc::ECCSignature *signature;

@end

@interface AJNCertificateX509 (Private)

@property (nonatomic, readonly) qcc::CertificateX509 *certificate;

@end

@implementation AJNSecurityApplicationProxy

- (id)initWithBus:(AJNBusAttachment *)bus withBusName:(NSString *)busName inSession:(AJNSessionId)sessionId
{
    self = [super init];
    if (self) {
        self.handle = new SecurityApplicationProxy(*bus.busAttachment, [busName UTF8String], (SessionId)sessionId);
        self.shouldDeleteHandleOnDealloc = YES;
    }

    return self;
}

- (SecurityApplicationProxy*)securityAppProxy
{
    return static_cast<SecurityApplicationProxy*>(self.handle);
}

- (void)dealloc
{
    if (self.shouldDeleteHandleOnDealloc) {
        SecurityApplicationProxy *pArg = static_cast<SecurityApplicationProxy*>(self.handle);
        delete pArg;
        self.handle = nil;
    }
}

- (QStatus)getManifestTemplateAsXml:(NSString **)manifestXml
{
    char* manifest = NULL;
    QStatus status = self.securityAppProxy->GetManifestTemplate(&manifest);
    if (status == ER_OK && manifest != NULL && manifestXml != nil) {
        *manifestXml = [NSString stringWithCString:manifest encoding:NSUTF8StringEncoding];
    }

    return status;
}

- (QStatus)getApplicationState:(AJNApplicationState *)applicationState
{
    if (applicationState == nil) {
        return ER_BAD_ARG_1;
    }

    PermissionConfigurator::ApplicationState appState;
    QStatus status = self.securityAppProxy->GetApplicationState(appState);

    *applicationState = (AJNApplicationState)appState;

    return status;
}

- (QStatus)getECCPublicKey:(AJNECCPublicKey**)eccPublicKey;
{
    if (eccPublicKey == nil) {
        return ER_BAD_ARG_1;
    }

    qcc::ECCPublicKey *publicKey = new qcc::ECCPublicKey();
    QStatus status = self.securityAppProxy->GetEccPublicKey(*publicKey);

    if (status == ER_OK) {
        *eccPublicKey = [[AJNECCPublicKey alloc] initWithHandle:(AJNHandle)publicKey];
    }

    return status;
}

- (QStatus)getClaimCapabilites:(AJNClaimCapabilities *)claimCapabilities
{
    if (claimCapabilities == nil) {
        return ER_BAD_ARG_1;
    }

    PermissionConfigurator::ClaimCapabilities appCapabilities;
    QStatus status = self.securityAppProxy->GetClaimCapabilities(appCapabilities);

    *claimCapabilities = (AJNClaimCapabilities)appCapabilities;

    return status;
}

- (QStatus)getClaimCapabilityAdditionalInfo:(AJNClaimCapabilityAdditionalInfo *)claimCapabilitiesAdditionalInfo
{
    if (claimCapabilitiesAdditionalInfo == nil) {
        return ER_BAD_ARG_1;
    }

    PermissionConfigurator::ClaimCapabilityAdditionalInfo additionalInfo;
    QStatus status = self.securityAppProxy->GetClaimCapabilityAdditionalInfo(additionalInfo);

    *claimCapabilitiesAdditionalInfo = additionalInfo;

    return status;
}

- (QStatus)claim:(AJNKeyInfoNISTP256*)certificateAuthority adminGroupId:(AJNGUID128*)adminGroupId adminGroup:(AJNKeyInfoNISTP256*)adminGroup identityCertChain:(NSArray*)identityCertChain manifestsXmls:(NSArray*)manifestsXmls
{
    size_t certCount = identityCertChain.count;
    size_t manifestCount = manifestsXmls.count;

    qcc::CertificateX509 *certs = new qcc::CertificateX509[certCount];
    const char **manifestList = new const char*[manifestCount];

    for (int i = 0; i < certCount; i++) {
        AJNCertificateX509 *cert = identityCertChain[i];
        certs[i] = *cert.certificate;
    }

    for (int i = 0; i < manifestCount; i++) {
        NSString *str = manifestsXmls[i];
        manifestList[i] = [str UTF8String];
    }

    QStatus status = self.securityAppProxy->Claim(*certificateAuthority.keyInfo, *adminGroupId.guid128, *adminGroup.keyInfo, certs, certCount, manifestList, manifestCount);

    delete [] certs;
    delete [] manifestList;

    return status;
}

- (QStatus)updateIdentity:(NSArray*)identityCertificateChain manifestsXmls:(NSArray*)manifestsXmls
{
    size_t manifestCount = manifestsXmls.count;
    size_t certCount = identityCertificateChain.count;

    const char **manifestStrs = new const char*[manifestCount];
    qcc::CertificateX509 *certs = new qcc::CertificateX509[certCount];

    for (int i = 0; i < manifestCount; i++) {
        NSString *str = manifestsXmls[i];
        manifestStrs[i] = [str UTF8String];
    }

    for (int i = 0; i < certCount; i++) {
        AJNCertificateX509 *cert = identityCertificateChain[i];
        certs[i] = *cert.certificate;
    }

    QStatus status = self.securityAppProxy->UpdateIdentity(certs, certCount, manifestStrs, manifestCount);

    delete [] manifestStrs;
    delete [] certs;

    return status;
}

- (QStatus)updatePolicyFromXml:(NSString *)withPolicy
{
    return self.securityAppProxy->UpdatePolicy([withPolicy UTF8String]);
}

- (QStatus)installMembership:(NSArray*)certificateChain
{
    size_t certCount = certificateChain.count;
    qcc::CertificateX509 *certs = new qcc::CertificateX509[certCount];

    for (int i = 0; i < certCount; i++) {
        AJNCertificateX509 *cert = certificateChain[i];
        certs[i] = *cert.certificate;
    }

    QStatus status = self.securityAppProxy->InstallMembership(certs, certCount);

    delete [] certs;

    return status;
}

+ (QStatus)signManifest:(AJNCertificateX509*)identityCertificate privateKey:(AJNECCPrivateKey*)privateKey unsignedManifestXml:(NSString*)unsignedManifestXml signedManifestXml:(char**)signedManifestXml

{
    if (identityCertificate == nil) {
        return ER_BAD_ARG_1;
    }

    if (privateKey == nil) {
        return ER_BAD_ARG_2;
    }

    if (unsignedManifestXml == nil) {
        return ER_BAD_ARG_3;
    }

    if (signedManifestXml == NULL) {
        return ER_BAD_ARG_4;
    }

    return ajn::SecurityApplicationProxy::SignManifest(*identityCertificate.certificate, *privateKey.privateKey, [unsignedManifestXml UTF8String], signedManifestXml);
}

+ (void)destroySignedManifest:(char*)signedManifestXml
{
    if (signedManifestXml != NULL) {
        ajn::SecurityApplicationProxy::DestroySignedManifest(signedManifestXml);
    }
}

+ (QStatus)computeManifestDigest:(NSString *)unsignedManifestXml identityCertificate:(AJNCertificateX509 *)identityCertificate digest:(NSData **)digest
{
    uint8_t** outDigest = NULL;
    size_t outDigestSize = 0;
    QStatus status = ajn::SecurityApplicationProxy::ComputeManifestDigest([unsignedManifestXml UTF8String], *identityCertificate.certificate, outDigest, &outDigestSize);

    NSData *digestData = [[NSData alloc] initWithBytes:*outDigest length:outDigestSize];

    ajn::SecurityApplicationProxy::DestroyManifestDigest(*outDigest);

    *digest = digestData;

    return status;
}

+ (void)destroyManifestDigest:(uint8_t*)digest
{
    if (digest != NULL) {
        ajn::SecurityApplicationProxy::DestroyManifestDigest(digest);
    }
}

- (QStatus)reset
{
    return self.securityAppProxy->Reset();
}

- (QStatus)resetPolicy
{
    return self.securityAppProxy->ResetPolicy();
}

- (QStatus)startManagement
{
    return self.securityAppProxy->StartManagement();
}

- (QStatus)endManagement
{
    return self.securityAppProxy->EndManagement();
}

- (QStatus)secureConnect:(BOOL)forceAuth {
    return self.securityAppProxy->SecureConnection(forceAuth);
}

@end
