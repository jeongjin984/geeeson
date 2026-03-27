package inventory.domain.entity;

import inventory.domain.entity.base.BaseTimeEntity;
import inventory.domain.entity.enums.ReceiptStatus;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDate;
import java.util.Map;

@Entity
@Table(name = "item_lot",
       uniqueConstraints = @UniqueConstraint(name = "uq_item_lot", columnNames = {"item_id", "lot_no"}))
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ItemLot extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "lot_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_id", nullable = false,
            foreignKey = @ForeignKey(name = "fk_item_lot_item"))
    private Item item;

    @Column(name = "lot_no", nullable = false, length = 100)
    private String lotNo;

    @Column(name = "manufacture_date")
    private LocalDate manufactureDate;

    @Column(name = "expiry_date")
    private LocalDate expiryDate;

    @Column(name = "vendor_lot_no", length = 100)
    private String vendorLotNo;

    @Enumerated(EnumType.STRING)
    @Column(name = "receipt_status", nullable = false, length = 20)
    private ReceiptStatus receiptStatus;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "attributes_json")
    private Map<String, Object> attributesJson;
}