import SwiftUI

struct EditOrderView: View {
    @Binding var isPresented: Bool
    let isLaptop: Bool
    @State private var showResetConfirm = false

    private var orderManager: CardOrderManager { CardOrderManager.shared }

    private func isVisible(_ card: CardType) -> Bool {
        !isLaptop ? card != .battery : true
    }

    private var visibleOrder: [CardType] {
        orderManager.order.filter(isVisible)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("编辑卡片顺序")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.shared.text)
                Spacer()
                Button("恢复默认") {
                    showResetConfirm = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Divider()

            // List with native drag-and-drop
            List {
                ForEach(visibleOrder, id: \.self) { card in
                    HStack(spacing: 12) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.shared.muted)
                            .frame(width: 20)

                        Image(systemName: card.iconName)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppTheme.shared.accent)
                            .frame(width: 24)

                        Text(card.displayName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.shared.text)

                        Spacer()
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppTheme.shared.card.opacity(0.5))
                    )
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppTheme.shared.card.opacity(0.5))
                    )
                    .listRowInsets(EdgeInsets(top: 2, leading: 12, bottom: 2, trailing: 12))
                    .listRowSeparator(.hidden)
                }
                .onMove(perform: moveItems)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.clear)

            Divider()

            // Footer
            HStack {
                Spacer()
                Button("完成") {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(width: 360, height: 480)
        .background(AppTheme.shared.surface)
        .alert("恢复默认顺序？", isPresented: $showResetConfirm) {
            Button("取消", role: .cancel) { }
            Button("恢复", role: .destructive) {
                orderManager.reset()
            }
        } message: {
            Text("卡片顺序将恢复为系统默认排列。")
        }
    }

    // MARK: - Move

    private func moveItems(from source: IndexSet, to destination: Int) {
        var fullOrder = orderManager.order
        var adjustedDest = destination

        guard let sourceIndex = source.first else { return }
        let filtered = fullOrder.filter(isVisible)
        let cardToMove = filtered[sourceIndex]

        guard let actualFrom = fullOrder.firstIndex(of: cardToMove) else { return }

        let destInFiltered = destination > sourceIndex ? destination - 1 : destination
        if destInFiltered < filtered.count {
            let targetCard = filtered[destInFiltered]
            if let actualTo = fullOrder.firstIndex(of: targetCard) {
                orderManager.moveItem(from: actualFrom, to: actualTo)
                return
            }
        }

        let insertPos = destination > sourceIndex ? destination - 1 : destination
        let clampedInsert = max(0, min(insertPos, fullOrder.count - 1))
        orderManager.moveItem(from: actualFrom, to: clampedInsert)
    }
}
