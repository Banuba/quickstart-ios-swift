import UIKit
import BanubaSdk

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_
        application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
            [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let deviceDocumentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.path

        BanubaSdkManager.initialize(
            resourcePath: [Bundle.main.bundlePath + "/effects", deviceDocumentsPath! + "/Effects"],
            clientTokenString: banubaClientToken)
        return true
    }
}
