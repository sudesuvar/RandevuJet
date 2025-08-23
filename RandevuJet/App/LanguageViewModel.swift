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
        case .english: "English"
        case .turkish: "Türkçe"
        }
    }
    
    var locale: Locale {
        Locale(identifier: self.rawValue)
    }
}

class LanguageViewModel: ObservableObject {
    @Published var selectedLanguage: Language = .turkish {
        didSet {
            print("🔄 Dil değiştirildi: \(oldValue.rawValue) → \(selectedLanguage.rawValue)")
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selected_language")
            
            // AppleLanguages ayarını güncelle
            UserDefaults.standard.set([selectedLanguage.rawValue], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }
    
    init() {
        print("\n🚀 LanguageViewModel başlatılıyor...")
        
        // Mevcut UserDefaults kontrolü
        print("📱 UserDefaults'tan kayıtlı dil: \(UserDefaults.standard.string(forKey: "selected_language") ?? "nil")")
        
        if let saved = UserDefaults.standard.string(forKey: "selected_language"),
           let lang = Language(rawValue: saved) {
            print("✅ Kayıtlı dil yüklendi: \(lang.rawValue)")
            selectedLanguage = lang
        } else {
            print("⚠️ Kayıtlı dil bulunamadı, varsayılan kullanılıyor: \(selectedLanguage.rawValue)")
        }
        
        // Bundle kaynaklarını kontrol et
        print("\n📁 Bundle kaynakları kontrol ediliyor...")
        let bundlePath = Bundle.main.bundlePath
        print("Bundle path: \(bundlePath)")
        
        // String Catalog kontrolü  
        print("\n🔍 String Catalog aranıyor...")
        if let path = Bundle.main.path(forResource: "Localizable", ofType: "xcstrings") {
            print("✅ String catalog bulundu: \(path)")
            
            // Dosya içeriğini kontrol et
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                print("📄 String catalog içeriği yüklendi (boyut: \(data.count) bytes)")
                
                if let dict = jsonObject as? [String: Any] {
                    if let strings = dict["strings"] as? [String: Any] {
                        print("🔤 Bulunan string anahtarları: \(Array(strings.keys))")
                    } else {
                        print("⚠️ 'strings' anahtarı bulunamadı")
                    }
                }
            } catch {
                print("❌ String catalog okuma hatası: \(error)")
            }
        } else {
            print("❌ String catalog bulunamadı!")
            
            // Alternatif dosya arama
            print("🔍 Alternatif yerelleştirme dosyaları aranıyor...")
            let resourceKeys: [URLResourceKey] = [.nameKey, .isDirectoryKey]
            
            if let enumerator = FileManager.default.enumerator(at: Bundle.main.bundleURL,
                                                             includingPropertiesForKeys: resourceKeys,
                                                             options: [.skipsHiddenFiles]) {
                for case let fileURL as URL in enumerator {
                    let fileName = fileURL.lastPathComponent
                    if fileName.contains("Localizable") || fileName.contains(".lproj") {
                        print("📁 Bulunan dosya: \(fileName) - \(fileURL.path)")
                    }
                }
            }
        }
        
        // Mevcut localization'ları kontrol et
        print("\n🌍 Bundle localization'ları:")
        let localizations = Bundle.main.localizations
        print("Mevcut diller: \(localizations)")
        print("Tercih edilen diller: \(Bundle.main.preferredLocalizations)")
        
        // Sistem dili kontrolü
        let systemLanguage = Locale.current.language.languageCode?.identifier ?? "unknown"
        print("📱 Sistem dili: \(systemLanguage)")
        print("🌍 Locale identifier: \(Locale.current.identifier)")
        
   
        
        // Localizable.strings dosyalarının içeriğini kontrol et
      //  print("\n📄 Localizable.strings dosyaları kontrol ediliyor:")
        for language in Language.allCases {
            if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj") {
                let stringsPath = "\(path)/Localizable.strings"
           //     print("🔍 \(language.rawValue) strings dosyası: \(stringsPath)")
                
                do {
                    let content = try String(contentsOfFile: stringsPath, encoding: .utf8)
                  //  print("📝 İçerik (\(content.count) karakter):")
                    if content.isEmpty {
                //        print("❌ Dosya boş!")
                    } else {
                //        print("✅ İçerik var:")
                        // İlk 200 karakteri göster
                        let preview = String(content.prefix(200))
              //          print("   \(preview)\(content.count > 200 ? "..." : "")")
                    }
                } catch {
            //        print("❌ Dosya okuma hatası: \(error)")
                }
            }
        }

        // Belirli dil bundle'ı ile test
      //  print("\n🌍 Dil bundle testleri:")
        for language in Language.allCases {
            if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                let localized = NSLocalizedString("welcome_title", bundle: bundle, comment: "")
             //   print("📦 \(language.rawValue) bundle: 'welcome_title' → '\(localized)'")
            } else {
            //    print("❌ \(language.rawValue) bundle bulunamadı")
            }
        }
        
        // Tekrar eden kod bloğu kaldırıldı
      //  print("🎯 Seçili dil: \(selectedLanguage.rawValue)")
    //   print("🏁 LanguageViewModel başlatma tamamlandı\n")
    }
    
    func localizedString(for key: String) -> String {
     //   print("🔍 Çeviri isteniyor: '\(key)' (dil: \(selectedLanguage.rawValue))")
        
        // Seçili dil bundle'ını yükle
        guard let path = Bundle.main.path(forResource: selectedLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
       //     print("❌ Bundle bulunamadı: \(selectedLanguage.rawValue)")
            return key
        }
        
    //    print("📁 Bundle path: \(path)")

        let stringsPath = bundle.path(forResource: "Localizable", ofType: "strings")
    //    print("📄 Strings dosyası: \(stringsPath ?? "bulunamadı")")
    
        let localized = bundle.localizedString(forKey: key, value: nil, table: nil)
     //   print("📦 Bundle çevirisi: '\(key)' → '\(localized)'")

        if localized == key {
      //      print("⚠️ Çeviri bulunamadı, fallback deneniyor...")
     
            if let stringsPath = stringsPath,
               let stringsDict = NSDictionary(contentsOfFile: stringsPath) as? [String: String],
               let translation = stringsDict[key] {
            //    print("✅ Manuel okuma başarılı: '\(key)' → '\(translation)'")
                return translation
            }
            
           // print("❌ Manuel okuma da başarısız")
        }
        
        return localized
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}
