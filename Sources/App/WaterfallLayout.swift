import SwiftUI

// MARK: - WaterfallLayout (true masonry/Pinterest style)
// Each card is placed in the shortest column. Cards in same "row" can have different heights.
// Columns are tight-packed vertically with no gaps between cards.

struct WaterfallLayout: Layout {
    let columnCount: Int
    let spacing: CGFloat

    static var layoutProperties: LayoutProperties {
        LayoutProperties()
    }

    func makeCache(subviews: Subviews) -> WaterfallCache {
        WaterfallCache()
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout WaterfallCache) -> CGSize {
        let containerWidth = proposal.width ?? 800
        let colWidth = (containerWidth - spacing * CGFloat(columnCount - 1)) / CGFloat(columnCount)

        // Track the height of each column
        var columnHeights = Array(repeating: CGFloat(0), count: columnCount)

        for i in subviews.indices {
            let size = subviews[i].sizeThatFits(ProposedViewSize(width: colWidth, height: nil))
            let h = size.height > 0 ? size.height : 180

            // Find the shortest column
            let shortestCol = columnHeights.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            columnHeights[shortestCol] += h + spacing
        }

        // Subtract trailing spacing for the tallest column's last item
        let maxHeight = columnHeights.max() ?? 0
        let totalHeight = maxHeight > 0 ? maxHeight - spacing : 0

        cache.columnHeights = columnHeights
        return CGSize(width: containerWidth, height: max(100, totalHeight))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout WaterfallCache) {
        let containerWidth = bounds.width
        let colWidth = (containerWidth - spacing * CGFloat(columnCount - 1)) / CGFloat(columnCount)

        // Track current height of each column
        var columnHeights = Array(repeating: CGFloat(0), count: columnCount)

        for i in subviews.indices {
            let size = subviews[i].sizeThatFits(ProposedViewSize(width: colWidth, height: nil))
            let h = size.height > 0 ? size.height : 180

            // Find the shortest column and place there
            let shortestCol = columnHeights.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0

            let x = bounds.minX + CGFloat(shortestCol) * (colWidth + spacing)
            let y = bounds.minY + columnHeights[shortestCol]

            subviews[i].place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(width: colWidth, height: h)
            )

            columnHeights[shortestCol] += h + spacing
        }

        cache.columnHeights = columnHeights
    }
}

struct WaterfallCache {
    var columnHeights: [CGFloat] = []
}