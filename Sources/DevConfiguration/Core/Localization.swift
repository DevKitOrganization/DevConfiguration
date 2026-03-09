//
//  Localization.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/26.
//

import Foundation

func localizedString(_ keyAndValue: String.LocalizationValue) -> String {
    String(localized: keyAndValue, bundle: #bundle)
}


func localizedStringResource(_ keyAndValue: String.LocalizationValue) -> LocalizedStringResource {
    LocalizedStringResource(keyAndValue, bundle: #bundle)
}


#if canImport(SwiftUI)
import SwiftUI

extension Text {
    init(localized localizationValue: String.LocalizationValue) {
        self.init(localizedString(localizationValue))
    }
}
#endif
