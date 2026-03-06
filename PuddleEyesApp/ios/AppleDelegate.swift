import CarPlay
import UIKit

@UIApplicationMain
class AppleDelegate: UIResponder, UIApplicationDelegate, CPApplicationDelegate {

    var window: UIWindow?
    var carInterfaceController: CPInterfaceController?

    func application(_ application: UIApplication, didConnectCarInterfaceController interfaceController: CPInterfaceController, to window: CPWindow) {
        self.carInterfaceController = interfaceController

        let template = CPMapTemplate()
        template.mapButtons = [CPMapButton { _ in
            print("Bouton PuddleEyes CarPress")
        }]

        interfaceController.setRootTemplate(template, animated: true)
    }

    @objc func updateRadar(points: [[String:Any]]) {
        // TODO: Transformer JSON points en affichage CarPlay (nuage 3D ou heatmap)
    }
}