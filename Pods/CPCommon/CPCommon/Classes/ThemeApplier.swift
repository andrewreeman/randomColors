//
//  ThemeApplier.swift
//  BDI_iOS
//
//  Created by ControlPoint on 31/05/2016.
//  Copyright © 2016 ControlPointLLP. All rights reserved.
//

import Foundation
import UIKit

public protocol Themeable {
    var TitleLabel: UILabel? {get}
    var BackgroundView: UIView? {get}
    var ColoredBackgroundTextLabels: [UILabel] {get}
    var BarButtonItems: [UIBarButtonItem] {get}
    var Buttons: [UIButton] {get}
    var ImageButtons: [UIButton] {get}
    
    var PrimaryHeadingItems: [UILabel] {get}
    var PrimaryTextItems: [UILabel] {get}
    var SecondaryTextItems: [UILabel] {get}
    
    
}

//themeable defaults
public extension Themeable {
    var TitleLabel: UILabel? { return nil }
    var BackgroundView: UIView? { return nil }
    var ColoredBackgroundTextLabels: [UILabel] { return [UILabel]() }
    var BarButtonItems: [UIBarButtonItem] { return [UIBarButtonItem]() }
    var Buttons: [UIButton] { return [UIButton]()}
    var ImageButtons: [UIButton] { return [UIButton]()}
    
    var PrimaryHeadingItems: [UILabel] { return [UILabel]() }
    var PrimaryTextItems: [UILabel] { return [UILabel]() }
    var SecondaryTextItems: [UILabel] { return [UILabel]() }
}

public protocol ThemeInterface {
    var PrimaryColor: UIColor {get}
    var SecondaryColor: UIColor {get}
    
    var ColoredBackgroundTextColor: UIColor {get}
    
    var StandardBackgroundTextColor: UIColor {get}
    var TitleFont: UIFont {get}
    var PrimaryHeadingFont: UIFont {get}
    var PrimaryTextFont: UIFont {get}
    
    var BackgroundColor: UIColor {get}
    
    /// if set this will override the standard background color
    var BackgroundGradientColors: [UIColor]? {get}
    
    
    var SecondaryTextFont: UIFont {get}
    var LightBackgroundPrimaryTextOpacity: CGFloat {get}
    var LightBackgroundSecondaryTextOpacity: CGFloat {get}
}


extension ThemeInterface {
    public var LightBackgroundPrimaryTextOpacity: CGFloat {
        return 0.87
    }
    public var LightBackgroundSecondaryTextOpacity: CGFloat {
        return 0.54
    }
    
    public var StandardBackgroundTextColor: UIColor {
        return UIColor.black
    }
    
    public var BackgroundColor: UIColor {
        return UIColor.white
    }
    
    public var BackgroundGradientColors: [UIColor]? {
        return nil
    }
}


public struct DefaultTheme : ThemeInterface {
    public var PrimaryColor: UIColor {
        return UIColor.createColorFromRGBValues(red: 0, green: 77, blue: 64)
    }
    
    public var SecondaryColor: UIColor {
        return UIColor.createColorFromRGBValues(red: 255, green: 72, blue: 0)
    }
    
    public var ColoredBackgroundTextColor: UIColor {
        return UIColor.white
    }
    
    public var TitleFont: UIFont {
        return UIFont.systemFont(ofSize: 30)
    }
    
    public var PrimaryHeadingFont: UIFont {
        return UIFont.systemFont(ofSize: 18)
    }
    
    public var PrimaryTextFont: UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: 12, weight: UIFontWeightMedium)
        }
        else {
            return UIFont.systemFont(ofSize: 12)
        }
    }
    
    public var SecondaryTextFont: UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: 12, weight: UIFontWeightMedium)
        }
        else {
            return UIFont.systemFont(ofSize: 12)
        }
    }
    
    public init(){}
}


public struct ThemeApplier {
    private let m_theme: ThemeInterface
    public var theme: ThemeInterface {
        return m_theme
    }
    
    public init() {
        m_theme = DefaultTheme()
    }
    
    public init(withTheme: ThemeInterface){
        m_theme = withTheme
    }
    
    public func applyThemeToThemeable(_ themeable: Themeable) {
        if let title = themeable.TitleLabel { applyTitleTheme(title) }
        if let background = themeable.BackgroundView {
            applyBackgroundColor(background)
            applyBackgroundGradient(background)            
        }
        
        themeable.ColoredBackgroundTextLabels.forEach{ applyPrimaryColorTheme($0) }
        themeable.BarButtonItems.forEach{ applySecondaryColorTheme($0) }
        
        themeable.PrimaryHeadingItems.forEach{ applyPrimaryHeadingTheme($0) }
        themeable.PrimaryTextItems.forEach{ applyPrimaryTextTheme($0) }
        themeable.SecondaryTextItems.forEach{ applySecondaryTextTheme($0) }
        themeable.Buttons.forEach{ applyButtonTheme($0) }
        themeable.ImageButtons.forEach{ applyPrimaryTextOpactiy($0) }
    }
    
    public func applyPrimaryHeadingTheme(_ title: UILabel) {
        title.font = m_theme.PrimaryHeadingFont
        title.textColor = m_theme.StandardBackgroundTextColor.withAlphaComponent(m_theme.LightBackgroundPrimaryTextOpacity)
    }
    
    public func applyPrimaryTextTheme(_ label: UILabel) {
        label.textColor = m_theme.StandardBackgroundTextColor.withAlphaComponent(m_theme.LightBackgroundPrimaryTextOpacity)
        label.font = m_theme.PrimaryTextFont
    }
    
    public func applySecondaryTextTheme(_ label: UILabel) {
        label.textColor = m_theme.StandardBackgroundTextColor.withAlphaComponent(m_theme.LightBackgroundSecondaryTextOpacity)
        label.font = m_theme.SecondaryTextFont
    }
    
    public func applyPrimaryTextOpactiy(_ view: UIView) {
        view.alpha = m_theme.LightBackgroundPrimaryTextOpacity
    }
    
    public func applyPrimaryTextFont(_ label: UILabel) {
        label.font = m_theme.PrimaryTextFont
    }
    
    public func applyTitleTheme(_ title: UILabel) {
        title.font = m_theme.TitleFont
        applyPrimaryColorTheme(title)
    }
    
    public func applyBackgroundColor( _ backgroundView: UIView) {
        backgroundView.backgroundColor = m_theme.BackgroundColor
    }
    
    public func applyBackgroundGradient(_ backgroundView: UIView ) {
        guard let backgroundGradientColors = m_theme.BackgroundGradientColors else { return }
        
        backgroundView.backgroundColor = nil
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = backgroundView.bounds
        gradientLayer.colors = backgroundGradientColors.map({$0.cgColor})
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    //MARK: private methods
    private func applyPrimaryColorTheme(_ label: UILabel) {
        label.textColor = m_theme.ColoredBackgroundTextColor
        label.backgroundColor = m_theme.PrimaryColor
    }
    
    private func applySecondaryColorTheme(_ button: UIBarButtonItem) {
        button.tintColor = m_theme.SecondaryColor
    }
    
    private func applyButtonTheme(_ button: UIButton) {
        button.tintColor = m_theme.SecondaryColor
        button.titleLabel?.textColor = m_theme.SecondaryColor
        button.backgroundColor = UIColor.clear
    }
}
