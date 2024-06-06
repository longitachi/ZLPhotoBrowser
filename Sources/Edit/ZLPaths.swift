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
    
    private var bgPath: UIBezierPath
    
    private let ratio: CGFloat
    
    private var points: [CGPoint] = []
    
    let index: Int
    
    var path: UIBezierPath
    
    var willDelete = false
    
    init(pathColor: UIColor, pathWidth: CGFloat, defaultLinePath: CGFloat, ratio: CGFloat, startPoint: CGPoint) {
        self.pathColor = pathColor
        path = UIBezierPath()
        path.lineWidth = pathWidth / ratio
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.move(to: CGPoint(x: startPoint.x / ratio, y: startPoint.y / ratio))
        
        bgPath = UIBezierPath()
        bgPath.lineWidth = pathWidth / ratio + defaultLinePath
        bgPath.lineCapStyle = .round
        bgPath.lineJoinStyle = .round
        bgPath.move(to: CGPoint(x: startPoint.x / ratio, y: startPoint.y / ratio))
        
        points.append(startPoint)
        self.ratio = ratio
        index = Self.pathIndex
        Self.pathIndex += 1
        
        super.init()
    }
    
    func addLine(to point: CGPoint) {
        points.append(point)
        
        func divRatio(_ point: CGPoint) -> CGPoint {
            return CGPoint(x: point.x / ratio, y: point.y / ratio)
        }
        
        guard points.count >= 4 else {
            path.addLine(to: divRatio(point))
            bgPath.addLine(to: divRatio(point))
            return
        }
        
        path.removeAllPoints()
        bgPath.removeAllPoints()
        
        // https://blog.csdn.net/ChasingDreamsCoder/article/details/53015694
        path.move(to: divRatio(points[0]))
        path.addLine(to: divRatio(points[1]))
        
        bgPath.move(to: divRatio(points[0]))
        bgPath.addLine(to: divRatio(points[1]))
        
        let granularity = 4
        for i in 3..<points.count {
            let p0 = points[i - 3]
            let p1 = points[i - 2]
            let p2 = points[i - 1]
            let p3 = points[i]
            
            for i in 1..<granularity {
                let t = CGFloat(i) * (1 / CGFloat(granularity))
                let tt = t * t
                let ttt = tt * t

                var point = CGPoint.zero
                point.x = 0.5 * (
                    2 * p1.x + (p2.x - p0.x) * t +
                    (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * tt +
                    (3 * p1.x - p0.x - 3 * p2.x + p3.x) * ttt
                )
                point.y = 0.5 * (
                    2 * p1.y + (p2.y - p0.y) * t +
                    (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * tt +
                    (3 * p1.y - p0.y - 3 * p2.y + p3.y) * ttt
                )
                path.addLine(to: divRatio(point))
                bgPath.addLine(to: divRatio(point))
            }
            
            path.addLine(to: divRatio(p2))
            bgPath.addLine(to: divRatio(p2))
        }
        
        path.addLine(to: divRatio(points[points.count - 1]))
        bgPath.addLine(to: divRatio(points[points.count - 1]))
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
    static func ==(lhs: ZLDrawPath, rhs: ZLDrawPath) -> Bool {
        return lhs.index == rhs.index
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
