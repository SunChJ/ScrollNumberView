//
//  ScrollNumber.swift
//  ScrollNumber
//
//  Created by 孙超杰 on 2018/12/21.
//  Copyright © 2018年 孙超杰. All rights reserved.
//

import UIKit

class ScrollNumberAnimatdView: UIView {
    var newNumber = 0 {
        didSet {
            // 根据新旧数据觉定滚动方向
            isAscending = newNumber < oldNumber
            prepareAnimations()
        }
    }
    var oldNumber = 0

    var textColor: UIColor = .white
    var font = UIFont.systemFont(ofSize: 14)
    var minLength = 0 // 最小显示长度，不够补零
    var duration: TimeInterval = 1.5 // 动画总持续时间
    
    private var isAscending = false // 方向，默认为false，数字向下滚动
    private var numbersText = [String]() // 保存拆分出来的数字
    private var oldNumebersText = [String]()
    private var scrollLayers = [CALayer]()
    private var scrollLabels = [UILabel]() // 保存Label

}

extension ScrollNumberAnimatdView {
    
    func reloadView() {
        prepareAnimations()
    }
    
    func startAnimation() {
        createAnimations()
        oldNumber = newNumber
    }
    
    func stopAnimation() {
        for layer in scrollLayers {
            layer.removeAnimation(forKey: "ScrollNumberAnimatdView")
        }
    }
}

extension ScrollNumberAnimatdView {
    private func prepareAnimations() {
        // 删除旧数据
        for layer in scrollLayers {
            layer.removeFromSuperlayer()
        }
        numbersText.removeAll()
        oldNumebersText.removeAll()
        scrollLayers.removeAll()
        scrollLabels.removeAll()
        
        configOldNumberText()
        configNewNumbersText()
        configScrollLayers()
    }
    
    private func generateNumbersText(_ number: Int) -> [String] {
        let numberStr = number.description
        var result = [String]()
        // 位数不足 补0
        if minLength > numberStr.count {
            for _ in 0..<(minLength - numberStr.count) {
                result.append("0")
            }
        }
        // 取各个数
        for char in numberStr {
            result.append(char.description)
        }
        return result
    }
    
    private func configNewNumbersText() {
        numbersText = generateNumbersText(newNumber)
    }
    
    private func configOldNumberText() {
        oldNumebersText = generateNumbersText(oldNumber)
    }
    
    private func configScrollLayers() {
        // 平均分配宽度
        let width = frame.width / CGFloat(numbersText.count)
        let height = frame.height
        
        for (index, text) in numbersText.enumerated() {
            let layer = CAScrollLayer()
            layer.frame = CGRect(x: CGFloat(index) * width,
                                 y: 0,
                                 width: width,
                                 height: height)
            self.layer.addSublayer(layer)
            scrollLayers.append(layer)
            
            configScrollLayer(layer, numberText: text, at: index)
        }
    }
    
    private func density(at index: Int) -> Int {
        let sumCount = Int((self.newNumber - self.oldNumber).magnitude) // 取绝对值 UInt -> Int
        let div = pow(10, Double(index))
        
        let density = sumCount / Int(div)
        return density
    }
    
    private func configScrollLayer(_ layer: CAScrollLayer, numberText text: String, at index: Int) {
        let numberInt = Int(text) ?? 0
        
        var scrollNumbers = [String]()
        var density = self.density(at: numbersText.count - 1 - index)
        let oldNumberInt = Int(safeString(at: index, from: oldNumebersText)) ?? 0

        // 控制动画layer帧总数， 20*N帧配合easeInEaseOut动画能比较好的混淆视觉感官
        if density > 20 {
            density = density % 20
            if density < 10 {
                density = 10
            }
        }
        // 做从old数值到new数值的过渡区间，跑马帧
        for i in 0..<density {
            let newNumber = abs((oldNumberInt + i * (isAscending ? -1 : 1)) % 10)
            scrollNumbers.append(newNumber.description)
        }
        // 最后的收尾帧
        scrollNumbers.append(numberInt.description)
    
        var height: CGFloat = 0 // 做高度累加
        // 保证数字列上大下小排序， 如需更改请置反(!)'isAscending = number < oldNumber'
        let tempNumbers = isAscending ? scrollNumbers : scrollNumbers.reversed()
        
        for numberStr in tempNumbers {
            let label = createLabel(text: numberStr)
            label.frame = CGRect(x: 0,
                                 y: height,
                                 width: layer.frame.width,
                                 height: layer.frame.height)
            layer.addSublayer(label.layer)
            // 保存label， 防止对象被回收
            scrollLabels.append(label)
            height = label.frame.maxY // 累加
        }
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.textColor = textColor
        label.font = font
        label.textAlignment = .center
        
        label.text = text
        return label
    }
    
    private func createAnimations() {

        guard oldNumber != newNumber else {
            return
        }
        
        for layer in scrollLayers {
            let maxY = layer.sublayers?.last?.frame.origin.y ?? 0
            let animation = CABasicAnimation(keyPath: "sublayerTransform.translation.y")
            
            animation.duration = self.duration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            // 滚动方向区分
            if isAscending {
                animation.fromValue = 0
                animation.toValue = -maxY
            } else {
                animation.fromValue = -maxY
                animation.toValue = 0
                
            }
            // 防止数字变小时， 回滚到初始值
            animation.isRemovedOnCompletion = false
            animation.fillMode = .forwards
            
            // 添加动画
            layer.add(animation, forKey: "ScrollNumberAnimatdView")
        }
    }
    
    // 旧的数值长度和新数值长度不匹配
    private func safeString(at index: Int, from array: [String]) -> String {
        guard index < array.count else {
            return ""
        }
        return array[index]
    }
}
