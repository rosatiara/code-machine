//
//  UIImage+extensions.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit

extension UIImage {
    
    private static var noirFilter = CIFilter(name: "CIPhotoEffectNoir")
    
    func noirFiltered() -> UIImage? {
        guard let currentFilter = UIImage.noirFilter  else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        guard let filteredCIImage = currentFilter.outputImage else { return nil }
        let context = CIContext(options: nil)
        guard let filteredCGImage = context.createCGImage(filteredCIImage, from: filteredCIImage.extent) else { return nil }
        return UIImage(cgImage: filteredCGImage)
    }
}
