import UIKit
import SwiftUI
import UniformTypeIdentifiers
import LinkPresentation

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        extensionContext?.inputItems.forEach { item in
            guard let input = item as? NSExtensionItem else { return }
            input.attachments?.forEach { provider in
                print("Registered Type Identifiers: \(provider.registeredTypeIdentifiers)")
            }
        }

        if !UIAccessibility.isReduceTransparencyEnabled {
            view.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = view.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(blurView, at: 0)
        } else {
            view.backgroundColor = .systemBackground
        }

        extractSharedURL { sharedURLString in
            DispatchQueue.main.async {
                self.presentForm(with: sharedURLString)
            }
        }
    }
    
    private func fetchPreview(urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { metadata, error in
            guard let metadata = metadata, error == nil else {
                completion(nil)
                return
            }

            if let itemProvider = metadata.imageProvider {
                itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            completion(image)
                        }
                    } else {
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
    }



    private func presentForm(with sharedURLString: String?) {
        fetchPreview(urlString: sharedURLString ?? "") { [weak self] image in
            guard let self = self else { return }

            let swiftUIView = ShareFormView(
                sectionText: "Save to Save4Later",
                onSave: {
                    self.extensionContext?.completeRequest(returningItems: nil)
                    self.dismiss(animated: true)
                },
                initialLink: sharedURLString ?? "",
                initialImage: image
            )

            let hostingController = UIHostingController(rootView: swiftUIView)
            self.addChild(hostingController)
            hostingController.view.frame = self.view.bounds
            hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
        }
    }


    private func extractSharedURL(completion: @escaping (String?) -> Void) {
        guard
            let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let attachments = extensionItem.attachments
        else {
            completion(nil)
            return
        }

        for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { item, _ in
                    let urlString = (item as? URL)?.absoluteString
                    completion(urlString)
                }
                return
            }
        }

        completion(nil)
    }
}
