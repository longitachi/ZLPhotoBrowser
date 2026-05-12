//
//  ZLPaths.swift
//  ZLPhotoBrowser
//
//  Created by long on 2023/9/25.
//
//  Copyright (c) 2020 Long Zhang <495181165@qq.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

// MARK: 涂鸦path

public class ZLDrawPath: NSObject {
    private static var pathIndex = 0
    
    private let pathColor: UIColor
    
    private let pathWidth: CGFloat
    
    private let defaultLinePath: CGFloat
    
    private var bgPath: UIBezierPath
    
    private let ratio: CGFloat
    
    /// 归一化坐标点（已除以 ratio），用于后续平滑处理
    private var points: [CGPoint] = []
    
    /// 命中测试用的描边 CGPath 缓存，key 为 strokeWidth，path 变化时清空
    private var strokedPathCache: (strokeWidth: CGFloat, path: CGPath)?
    
    // 平滑相关参数
    private let minPointSpacing: CGFloat = 1.5
    private let slowSmoothingFactor: CGFloat = 0.2
    private let fastSmoothingFactor: CGFloat = 0.4
    
    let index: Int
    
    var path: UIBezierPath
    
    var willDelete = false
    
    init(pathColor: UIColor, pathWidth: CGFloat, defaultLinePath: CGFloat, ratio: CGFloat, startPoint: CGPoint) {
        self.pathColor = pathColor
        self.pathWidth = pathWidth
        self.defaultLinePath = defaultLinePath
        self.ratio = ratio
        
        path = UIBezierPath()
        path.lineWidth = pathWidth / ratio
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        bgPath = UIBezierPath()
        bgPath.lineWidth = pathWidth / ratio + defaultLinePath
        bgPath.lineCapStyle = .round
        bgPath.lineJoinStyle = .round
        
        let normalized = CGPoint(x: startPoint.x / ratio, y: startPoint.y / ratio)
        points.append(normalized)
        path.move(to: normalized)
        bgPath.move(to: normalized)
        
        index = Self.pathIndex
        Self.pathIndex += 1
        
        super.init()
    }
    
    func addLine(to point: CGPoint) {
        let normalized = CGPoint(x: point.x / ratio, y: point.y / ratio)
        appendPointIfNeeded(normalized, force: false)
        rebuildPaths(isFinal: false)
    }
    
    /// 笔画结束时调用，确保最终的路径包含末端优化（去除反向短钩 / 收敛到真实终点）
    func finishDrawing() {
        rebuildPaths(isFinal: true)
    }
    
    /// 判断某个点是否命中当前笔画（用于橡皮擦）。
    /// 原生 `UIBezierPath.contains` 判定的是填充区域，对于开放的描边路径命中率很差。
    /// 这里先用 `copy(strokingWithWidth:)` 将路径按线宽+额外半径膨胀成实际可见区域，再做命中判断。
    /// - Parameters:
    ///   - point: 命中测试点（与 `path` 同坐标系）
    ///   - extraRadius: 额外容差半径（例如橡皮擦半径）
    func hitTest(_ point: CGPoint, extraRadius: CGFloat) -> Bool {
        let stroked = strokedPath(for: extraRadius)
        return stroked.contains(point)
    }
    
    /// 判断一条线段（上一个橡皮擦点 → 当前橡皮擦点）是否命中该笔画。
    /// 用于快速滑动时避免跳过细长笔画。
    func hitTest(from start: CGPoint, to end: CGPoint, extraRadius: CGFloat) -> Bool {
        let stroked = strokedPath(for: extraRadius)
        if stroked.contains(end) { return true }
        if stroked.contains(start) { return true }
        
        // 线段均匀采样
        let dx = end.x - start.x
        let dy = end.y - start.y
        let distance = hypot(dx, dy)
        // 采样步长取橡皮擦半径的一半，保证不会在两个采样点间漏掉
        let step = max(extraRadius * 0.5, 1)
        let sampleCount = Int(distance / step)
        guard sampleCount > 0 else { return false }
        
        for i in 1..<sampleCount {
            let t = CGFloat(i) / CGFloat(sampleCount)
            let p = CGPoint(x: start.x + dx * t, y: start.y + dy * t)
            if stroked.contains(p) { return true }
        }
        return false
    }
    
    /// 获取/生成描边膨胀后的 CGPath。笔画结束后 path 不再变化，缓存可长期复用。
    private func strokedPath(for extraRadius: CGFloat) -> CGPath {
        let strokeWidth = max(path.lineWidth + extraRadius * 2, 1)
        if let cache = strokedPathCache, abs(cache.strokeWidth - strokeWidth) < 0.01 {
            return cache.path
        }
        let stroked = path.cgPath.copy(
            strokingWithWidth: strokeWidth,
            lineCap: .round,
            lineJoin: .round,
            miterLimit: 0
        )
        strokedPathCache = (strokeWidth, stroked)
        return stroked
    }
    
    private func appendPointIfNeeded(_ point: CGPoint, force: Bool) {
        guard let last = points.last else {
            points.append(point)
            return
        }
        let d = Self.distance(last, point)
        if d < 0.1 {
            points[points.count - 1] = point
            return
        }
        if d < minPointSpacing, !force {
            return
        }
        points.append(point)
    }
    
    private func rebuildPaths(isFinal: Bool) {
        let sanitized = Self.sanitize(
            points,
            isFinal: isFinal,
            slowSmoothingFactor: slowSmoothingFactor,
            fastSmoothingFactor: fastSmoothingFactor
        )
        
        let newPath = Self.makeBezierPath(
            from: sanitized,
            lineWidth: pathWidth / ratio
        )
        let newBgPath = Self.makeBezierPath(
            from: sanitized,
            lineWidth: pathWidth / ratio + defaultLinePath
        )
        path = newPath
        bgPath = newBgPath
        // path 已变化，命中测试缓存失效
        strokedPathCache = nil
    }
    
    // MARK: - 路径生成
    
    private static func makeBezierPath(from pts: [CGPoint], lineWidth: CGFloat) -> UIBezierPath {
        let bezier = UIBezierPath()
        bezier.lineWidth = lineWidth
        bezier.lineCapStyle = .round
        bezier.lineJoinStyle = .round
        
        guard let first = pts.first else { return bezier }
        bezier.move(to: first)
        
        if pts.count == 1 { return bezier }
        if pts.count == 2 {
            bezier.addLine(to: pts[1])
            return bezier
        }
        
        // 在首尾各复制一个点，确保端点段也能用三次贝塞尔
        let extended = [pts[0]] + pts + [pts[pts.count - 1]]
        for i in 0..<(extended.count - 3) {
            let p0 = extended[i]
            let p1 = extended[i + 1]
            let p2 = extended[i + 2]
            let p3 = extended[i + 3]
            
            let cp1 = CGPoint(
                x: p1.x + (p2.x - p0.x) / 6,
                y: p1.y + (p2.y - p0.y) / 6
            )
            let cp2 = CGPoint(
                x: p2.x - (p3.x - p1.x) / 6,
                y: p2.y - (p3.y - p1.y) / 6
            )
            bezier.addCurve(to: p2, controlPoint1: cp1, controlPoint2: cp2)
        }
        return bezier
    }
    
    // MARK: - 点集平滑
    
    private static func sanitize(
        _ pts: [CGPoint],
        isFinal: Bool,
        slowSmoothingFactor: CGFloat,
        fastSmoothingFactor: CGFloat
    ) -> [CGPoint] {
        guard pts.count > 2 else { return pts }
        var result = smoothPoints(
            pts,
            isFinal: isFinal,
            slowSmoothingFactor: slowSmoothingFactor,
            fastSmoothingFactor: fastSmoothingFactor
        )
        result = dropSharpTerminalHook(result)
        result = removeTinyJitter(result)
        return result
    }
    
    private static func smoothPoints(
        _ pts: [CGPoint],
        isFinal: Bool,
        slowSmoothingFactor: CGFloat,
        fastSmoothingFactor: CGFloat
    ) -> [CGPoint] {
        guard pts.count > 2 else { return pts }
        
        var result: [CGPoint] = [pts[0]]
        for point in pts.dropFirst() {
            let last = result[result.count - 1]
            let d = distance(last, point)
            let t = min(max(d / 12, 0), 1)
            let factor = slowSmoothingFactor + (fastSmoothingFactor - slowSmoothingFactor) * t
            let filtered = CGPoint(
                x: last.x + (point.x - last.x) * factor,
                y: last.y + (point.y - last.y) * factor
            )
            if distance(last, filtered) < 0.35 {
                continue
            }
            result.append(filtered)
        }
        
        // 笔画结束时，向真实终点靠近，避免尾端明显偏移
        if isFinal, let actualLast = pts.last, result.count >= 2 {
            let previous = result[result.count - 2]
            result[result.count - 1] = CGPoint(
                x: previous.x + (actualLast.x - previous.x) * 0.55,
                y: previous.y + (actualLast.y - previous.y) * 0.55
            )
        }
        return result
    }
    
    /// 去除末端反向的短钩（拐弯处的小凸起主要来源）
    private static func dropSharpTerminalHook(_ pts: [CGPoint]) -> [CGPoint] {
        var result = pts
        while result.count >= 3 {
            let a = result[result.count - 3]
            let b = result[result.count - 2]
            let c = result[result.count - 1]
            
            let abx = b.x - a.x, aby = b.y - a.y
            let bcx = c.x - b.x, bcy = c.y - b.y
            let lab = hypot(abx, aby)
            let lbc = hypot(bcx, bcy)
            
            guard lab > 0.001, lbc > 0.001 else {
                result.removeLast()
                continue
            }
            
            let dot = (abx * bcx + aby * bcy) / (lab * lbc)
            let isShortReverse = lbc < 10 && dot < 0
            if !isShortReverse { break }
            
            result.removeLast()
        }
        return result
    }
    
    /// 去除中间抖动很小的点
    private static func removeTinyJitter(_ pts: [CGPoint]) -> [CGPoint] {
        guard pts.count > 2 else { return pts }
        var result: [CGPoint] = [pts[0]]
        for index in 1..<(pts.count - 1) {
            let previous = result[result.count - 1]
            let current = pts[index]
            let next = pts[index + 1]
            
            let d1 = distance(previous, current)
            let d2 = distance(current, next)
            if d1 < 1 || d2 < 1 { continue }
            result.append(current)
        }
        result.append(pts[pts.count - 1])
        return result
    }
    
    private static func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        hypot(p2.x - p1.x, p2.y - p1.y)
    }
    
    func drawPath() {
        if willDelete {
            UIColor.white.set()
            bgPath.stroke()
            pathColor.withAlphaComponent(0.7).set()
        } else {
            pathColor.set()
        }
        
        path.stroke()
    }
}

public extension ZLDrawPath {
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ZLDrawPath else {
            return false
        }
        
        return index == object.index
    }
}

// MARK: 马赛克path

public class ZLMosaicPath: NSObject {
    let path: UIBezierPath
    
    let ratio: CGFloat
    
    let startPoint: CGPoint
    
    var linePoints: [CGPoint] = []
    
    init(pathWidth: CGFloat, ratio: CGFloat, startPoint: CGPoint) {
        path = UIBezierPath()
        path.lineWidth = pathWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.move(to: startPoint)
        
        self.ratio = ratio
        self.startPoint = CGPoint(x: startPoint.x / ratio, y: startPoint.y / ratio)
        
        super.init()
    }
    
    func addLine(to point: CGPoint) {
        path.addLine(to: point)
        linePoints.append(CGPoint(x: point.x / ratio, y: point.y / ratio))
    }
}
