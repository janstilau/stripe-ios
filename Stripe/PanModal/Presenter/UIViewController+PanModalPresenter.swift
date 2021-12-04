//
//  UIViewController+PanModalPresenterProtocol.swift
//  PanModal
//
//  Copyright © 2019 Tiny Speck, Inc. All rights reserved.
//

#if os(iOS)
import UIKit

/// Extends the UIViewController to conform to the PanModalPresenter protocol
@available(iOSApplicationExtension, unavailable)
@available(macCatalystApplicationExtension, unavailable)
extension UIViewController: PanModalPresenter {
    
    /**
     A flag that returns true if the topmost view controller in the navigation stack
     was presented using the custom PanModal transition
     
     - Warning: ⚠️ Calling `presentationController` in this function may cause a memory leak. ⚠️
     
     In most cases, this check will be used early in the view lifecycle and unfortunately,
     there's an Apple bug that causes multiple presentationControllers to be created if
     the presentationController is referenced here and called too early resulting in
     a strong reference to this view controller and in turn, creating a memory leak.
     */
    var isPanModalPresented: Bool {
        return (transitioningDelegate as? PanModalPresentationDelegate) != nil
    }
    
    /*
     Configures a view controller for presentation using the PanModal transition
     
     - Parameters:
     - viewControllerToPresent: The view controller to be presented
     - sourceView: The view containing the anchor rectangle for the popover.
     - sourceRect: The rectangle in the specified view in which to anchor the popover.
     - completion: The block to execute after the presentation finishes. You may specify nil for this parameter.
     
     - Note: sourceView & sourceRect are only required for presentation on an iPad.
     */
    func presentPanModal(
        _ viewControllerToPresent: PanModalPresentable.LayoutType,
        sourceView: UIView? = nil,
        sourceRect: CGRect = .zero,
        completion: (() -> Void)? = nil
    ) {
        
        /**
         Here, we deliberately do not check for size classes. More info in `PanModalPresentationDelegate`
         */
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            viewControllerToPresent.modalPresentationStyle = .formSheet
            if let vc = viewControllerToPresent as? BottomSheetViewController {
                viewControllerToPresent.presentationController?.delegate = vc
            }
        } else {
            /*
                使用了 CustomPresent 的方式, 来对一个新的 VC 进行 Present.
                将, 使用这种特殊的 Present 的方式, 用一个特殊的方法包装起来.
                方便, 也避免外界的误用.
             */
            viewControllerToPresent.modalPresentationStyle = .custom
            viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
            viewControllerToPresent.transitioningDelegate = PanModalPresentationDelegate.default
        }
        
        present(viewControllerToPresent, animated: true, completion: completion)
    }
    
}
#endif
