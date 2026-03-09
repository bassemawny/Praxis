import LocalAuthentication

final class AuthenticationService {
    func authenticate(completion: @escaping (Bool) -> Void) {
        #if targetEnvironment(simulator)
        completion(true)
        return
        #endif

        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            // No biometrics or passcode available — allow access
            completion(true)
            return
        }

        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: String(localized: "Unlock Praxis to access your client data")
        ) { success, _ in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}
