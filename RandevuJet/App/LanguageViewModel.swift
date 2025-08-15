//
//  LanguageViewModel.swift
//  RandevuJet
//
//  Created by sude on 15.08.2025.
//


import Foundation
import SwiftUI

enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case turkish = "tr"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .turkish:
            return "Türkçe"
        }
    }
    
    var locale: Locale {
        return Locale(identifier: self.rawValue)
    }
}

class LanguageViewModel: ObservableObject {
    @Published var selectedLanguage: Language = .turkish {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selected_language")
            updateCurrentLocale()
        }
    }
    
    @Published var currentLocale: Locale = Locale(identifier: "tr")
    
    init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "selected_language"),
           let language = Language(rawValue: savedLanguage) {
            selectedLanguage = language
        }
        updateCurrentLocale()
    }
    
    private func updateCurrentLocale() {
        currentLocale = selectedLanguage.locale
    }
    
    // String Catalogs ile lokalizasyon (iOS 17+)
    @available(iOS 17.0, *)
    func localizedString(_ key: String) -> String {
        return String(localized: String.LocalizationValue(key), locale: currentLocale)
    }
    
    // Fallback için NSLocalizedString
    func localizedStringLegacy(_ key: String) -> String {
        if let path = Bundle.main.path(forResource: selectedLanguage.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: key, value: nil, table: nil)
        }
        return NSLocalizedString(key, comment: "")
    }
}

// String extension
extension String {
    func localized(using languageViewModel: LanguageViewModel) -> String {
        if #available(iOS 17.0, *) {
            return languageViewModel.localizedString(self)
        } else {
            return languageViewModel.localizedStringLegacy(self)
        }
    }
}

struct L {
    static func string(_ key: String, language: Language) -> String {
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return key
        }
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}
