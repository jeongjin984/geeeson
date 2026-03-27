package inventory.domain.entity;

import inventory.domain.entity.base.BaseTimeEntity;
import inventory.domain.entity.enums.InboundReceiptLineStatus;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "inbound_receipt_line",
       uniqueConstraints = @UniqueConstraint(name = "uq_inbound_receipt_line", columnNames = {"inbound_receipt_id", "line_no"}))
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InboundReceiptLine extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "inbound_receipt_line_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "inbound_receipt_id", nullable = false,
            foreignKey = @ForeignKey(name = "fk_inbound_receipt_line_receipt"))
    private InboundReceipt inboundReceipt;

    @Column(name = "line_no", nullable = false)
    private Integer lineNo;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_id", nullable = false,
            foreignKey = @ForeignKey(name = "fk_inbound_receipt_line_item"))
    private Item item;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lot_id",
            foreignKey = @ForeignKey(name = "fk_inbound_receipt_line_lot"))
    private ItemLot lot;

    @Column(name = "expected_qty", nullable = false, precision = 18, scale = 4)
    private java.math.BigDecimal expectedQty;

    @Column(name = "received_qty", nullable = false, precision = 18, scale = 4)
    private java.math.BigDecimal receivedQty;

    @Column(name = "accepted_qty", nullable = false, precision = 18, scale = 4)
    private java.math.BigDecimal acceptedQty;

    @Column(name = "rejected_qty", nullable = false, precision = 18, scale = 4)
    private java.math.BigDecimal rejectedQty;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "putaway_location_id",
            foreignKey = @ForeignKey(name = "fk_inbound_receipt_line_putaway_location"))
    private Location putawayLocation;

    @Enumerated(EnumType.STRING)
    @Column(name = "line_status", nullable = false, length = 20)
    private InboundReceiptLineStatus lineStatus;

    @Column(name = "remark", length = 500)
    private String remark;
}