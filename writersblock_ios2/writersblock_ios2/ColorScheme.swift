import SwiftUI

enum AppColorScheme {
    case light
    case dark
}

struct AppColors {
    let background: Color
    let foreground: Color
    let card: Color
    let primary: Color
    let secondary: Color
    let muted: Color
}

extension AppColorScheme {
    var colors: AppColors {
        switch self {
        case .light:
            return AppColors(
                background: Color(hsl: 0, 0, 0.9),
                foreground: Color(hsl: 240, 0.1, 0.039),
                card: .white,
                primary: .black,
                secondary: Color(hsl: 240, 0.048, 0.959),
                muted: Color(hsl: 240, 0.038, 0.45)
            )
        case .dark:
            return AppColors(
                background: Color(hsl: 0, 0, 0.1),
                foreground: Color(hsl: 0, 0, 0.9),
                card: Color(hsl: 0, 0, 0.15),
                primary: .black,
                secondary: Color(hsl: 0, 0, 0.2),
                muted: Color(hsl: 0, 0, 0.6)
            )
        }
    }
}

extension Color {
    init(hsl h: Double, _ s: Double, _ l: Double, opacity: Double = 1) {
        let c = (1 - abs(2 * l - 1)) * s
        let x = c * (1 - abs((h / 60).truncatingRemainder(dividingBy: 2) - 1))
        let m = l - c/2
        var rgb: (Double, Double, Double) = (0, 0, 0)
        
        if h < 60 {
            rgb = (c, x, 0)
        } else if h < 120 {
            rgb = (x, c, 0)
        } else if h < 180 {
            rgb = (0, c, x)
        } else if h < 240 {
            rgb = (0, x, c)
        } else if h < 300 {
            rgb = (x, 0, c)
        } else {
            rgb = (c, 0, x)
        }
        
        self.init(red: rgb.0 + m, green: rgb.1 + m, blue: rgb.2 + m, opacity: opacity)
    }
}