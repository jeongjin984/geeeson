package inventory.domain.entity;

import inventory.domain.entity.base.BaseTimeEntity;
import inventory.domain.entity.enums.ReservationReferenceType;
import inventory.domain.entity.enums.ReservationStatus;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "inventory_reservation")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InventoryReservation extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "reservation_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private InventoryOwner owner;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_id", nullable = false)
    private Warehouse warehouse;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "location_id")
    private Location location;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_id", nullable = false)
    private Item item;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lot_id")
    private ItemLot lot;

    @Enumerated(EnumType.STRING)
    @Column(name = "reference_type", nullable = false, length = 20)
    private ReservationReferenceType referenceType;

    @Column(name = "reference_no", nullable = false, length = 100)
    private String referenceNo;

    @Column(name = "reference_line_no", length = 50)
    private String referenceLineNo;

    @Column(name = "reserved_qty", nullable = false, precision = 18, scale = 4)
    private java.math.BigDecimal reservedQty;

    @Column(name = "released_qty", nullable = false, precision = 18, scale = 4)
    private java.math.BigDecimal releasedQty;

    @Enumerated(EnumType.STRING)
    @Column(name = "reservation_status", nullable = false, length = 30)
    private ReservationStatus reservationStatus;

    @Column(name = "reserved_at", nullable = false)
    private java.time.LocalDateTime reservedAt;

    @Column(name = "expires_at")
    private java.time.LocalDateTime expiresAt;
}