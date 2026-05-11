import SwiftUI

struct AdaptiveFlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        let rows = makeRows(maxWidth: proposal.width, subviews: subviews)
        let width = proposal.width ?? rows.map(\.width).max() ?? .zero
        let height = rows.reduce(CGFloat.zero) { result, row in
            result + row.height
        } + spacing * CGFloat(max(rows.count - 1, .zero))

        return CGSize(width: width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        let rows = makeRows(maxWidth: bounds.width, subviews: subviews)
        var yPosition = bounds.minY

        for row in rows {
            var xPosition = bounds.minX

            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: xPosition, y: yPosition),
                    proposal: ProposedViewSize(item.size)
                )
                xPosition += item.size.width + spacing
            }

            yPosition += row.height + spacing
        }
    }

    private func makeRows(maxWidth: CGFloat?, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentItems: [Item] = []
        var currentWidth = CGFloat.zero
        var currentHeight = CGFloat.zero
        let availableWidth = maxWidth ?? .infinity

        for index in subviews.indices {
            let measuredSize = subviews[index].sizeThatFits(.unspecified)
            let size = CGSize(width: min(measuredSize.width, availableWidth), height: measuredSize.height)
            let proposedWidth = currentItems.isEmpty ? size.width : currentWidth + spacing + size.width

            if proposedWidth > availableWidth && currentItems.isEmpty == false {
                rows.append(Row(items: currentItems, width: currentWidth, height: currentHeight))
                currentItems = [Item(index: index, size: size)]
                currentWidth = size.width
                currentHeight = size.height
            } else {
                currentItems.append(Item(index: index, size: size))
                currentWidth = proposedWidth
                currentHeight = max(currentHeight, size.height)
            }
        }

        if currentItems.isEmpty == false {
            rows.append(Row(items: currentItems, width: currentWidth, height: currentHeight))
        }

        return rows
    }

    private struct Row {
        let items: [Item]
        let width: CGFloat
        let height: CGFloat
    }

    private struct Item {
        let index: Int
        let size: CGSize
    }
}
