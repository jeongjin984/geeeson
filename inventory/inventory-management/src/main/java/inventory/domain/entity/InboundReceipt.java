package inventory.domain.entity;

import inventory.domain.entity.base.BaseTimeEntity;
import inventory.domain.entity.enums.InboundReceiptStatus;
import inventory.domain.entity.enums.InboundSourceType;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "inbound_receipt",
       uniqueConstraints = @UniqueConstraint(name = "uq_inbound_receipt_no", columnNames = "receipt_no"))
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InboundReceipt extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "inbound_receipt_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_id", nullable = false,
            foreignKey = @ForeignKey(name = "fk_inbound_receipt_warehouse"))
    private Warehouse warehouse;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false,
            foreignKey = @ForeignKey(name = "fk_inbound_receipt_owner"))
    private InventoryOwner owner;

    @Column(name = "receipt_no", nullable = false, length = 50)
    private String receiptNo;

    @Enumerated(EnumType.STRING)
    @Column(name = "source_type", nullable = false, length = 20)
    private InboundSourceType sourceType;

    @Column(name = "source_no", length = 100)
    private String sourceNo;

    @Enumerated(EnumType.STRING)
    @Column(name = "receipt_status", nullable = false, length = 20)
    private InboundReceiptStatus receiptStatus;

    @Column(name = "received_at")
    private java.time.LocalDateTime receivedAt;
}