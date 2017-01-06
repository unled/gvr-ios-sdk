import UIKit

class TreasureHuntViewController : UIViewController {
    
    var cardboardView: GVRCardboardView?
    var treasureHuntRenderer: TreasureHuntRenderer?
    var renderLoop: TreasureHuntRenderLoop?

    var daydreamController: DaydreamController?
    // var ship: SCNNode!
    var orientation0 = GLKQuaternionIdentity
    var firstUpdate = true
    
    override func loadView() {
        let treasureHuntRenderer = TreasureHuntRenderer()
        treasureHuntRenderer.delegate = self
        self.treasureHuntRenderer = treasureHuntRenderer

        let cardboardView = GVRCardboardView(frame: CGRect.zero)
        cardboardView?.delegate = self.treasureHuntRenderer
        cardboardView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cardboardView?.vrModeEnabled = true
        self.cardboardView = cardboardView
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(TreasureHuntViewController.didDoubleTapView))
        doubleTapGesture.numberOfTapsRequired = 2
        self.cardboardView?.addGestureRecognizer(doubleTapGesture)
        
        self.view = cardboardView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let cardboardView = self.cardboardView {
            self.renderLoop = TreasureHuntRenderLoop(renderTarget: cardboardView, selector: #selector(GVRCardboardView.render))
        }
        
        let daydreamController = DaydreamController()
        daydreamController.delegate = self
        daydreamController.connect()
        self.daydreamController = daydreamController
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Invalidate the render loop so that it removes the strong reference to cardboardView.
        self.renderLoop?.invalidate()
        self.renderLoop = nil
    }
    
    func getCardboardView() -> GVRCardboardView? {
        return self.cardboardView
    }
    
    func didDoubleTapView(sender: AnyObject) {
        if let cardboardView = self.cardboardView {
            cardboardView.vrModeEnabled = !cardboardView.vrModeEnabled
        }
    }
    
}

extension TreasureHuntViewController: TreasureHuntRendererDelegate {
    
    func shouldPauseRenderLoop(_ pause: Bool) {
        self.renderLoop?.paused = pause
    }
    
}

extension TreasureHuntViewController: DaydreamControllerDelegate
{
    func daydreamControllerDidConnect(_ controller: DaydreamController) {
        print("Press the home button to recenter the controller's orientation")
    }
    
    func daydreamControllerDidUpdate(_ controller: DaydreamController, batteryLevel: UInt8) {
        print("battery level \(batteryLevel)%")
    }
    
    func daydreamControllerDidUpdate(_ controller: DaydreamController, state: DaydreamController.State) {
        if firstUpdate {
            firstUpdate = false
            orientation0 = GLKQuaternionInvert(state.orientation)
        }
        
        if state.homeButtonDown {
            orientation0 = GLKQuaternionInvert(state.orientation)
        }
        
        let quaternion = GLKQuaternionMultiply(orientation0, state.orientation)
        self.treasureHuntRenderer?.quaternion = quaternion
        self.treasureHuntRenderer?.spawnCube()
        
        // print("\(quaternion.x), \(quaternion.y), \(quaternion.z), \(quaternion.w)")
        
        // ship.orientation = SCNQuaternion(q.x, q.y, q.z, q.w)
    }
    
}
