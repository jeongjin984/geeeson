package inventory.domain.entity;

import inventory.common.exceptions.DomainValidationException;
import inventory.domain.dto.ReserveInventoryCommand;
import inventory.domain.entity.base.BaseTimeEntity;
import inventory.domain.entity.enums.ReservationReferenceType;
import inventory.domain.entity.enums.ReservationStatus;
import jakarta.annotation.Nullable;
import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "inventory_reservation")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
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
    private BigDecimal reservedQty;

    @Column(name = "released_qty", nullable = false, precision = 18, scale = 4)
    private BigDecimal releasedQty;

    @Enumerated(EnumType.STRING)
    @Column(name = "reservation_status", nullable = false, length = 30)
    private ReservationStatus reservationStatus;

    @Column(name = "reserved_at", nullable = false)
    private LocalDateTime reservedAt;

    @Column(name = "expires_at")
    private LocalDateTime expiresAt;

    public static InventoryReservation create(
        InventoryOwner owner,
        Warehouse warehouse,
        Location location,
        Item item,
        ItemLot lot,
        ReservationReferenceType referenceType,
        String referenceNo,
        String referenceLineNo,
        BigDecimal reservedQty,
        LocalDateTime expiresAt
    ) {
        if (owner == null) {
            throw new DomainValidationException("Owner is required");
        }
        if (warehouse == null) {
            throw new DomainValidationException("Warehouse is required");
        }
        if (item == null) {
            throw new DomainValidationException("Item is required");
        }
        if (referenceType == null) {
            throw new DomainValidationException("Reference type is required");
        }
        if (referenceNo == null || referenceNo.isBlank()) {
            throw new DomainValidationException("Reference no is required");
        }
        if (reservedQty == null || reservedQty.compareTo(BigDecimal.ZERO) <= 0) {
            throw new DomainValidationException("Reserved quantity must be greater than zero");
        }

        if (location == null) {
            throw new IllegalArgumentException("Location is required for current reservation flow");
        }

        if (!location.getWarehouse().getId().equals(warehouse.getId())) {
            throw new DomainValidationException("Location and warehouse mismatch");
        }

        if (!item.getOwner().getId().equals(owner.getId())) {
            throw new DomainValidationException("Item and owner mismatch");
        }

        if (lot != null && !lot.getItem().getId().equals(item.getId())) {
            throw new DomainValidationException("Lot and item mismatch");
        }

        return InventoryReservation.builder()
            .owner(owner)
            .warehouse(warehouse)
            .location(location)
            .item(item)
            .lot(lot)
            .referenceType(referenceType)
            .referenceNo(referenceNo)
            .referenceLineNo(referenceLineNo)
            .reservedQty(reservedQty)
            .releasedQty(BigDecimal.ZERO)
            .reservationStatus(ReservationStatus.ACTIVE)
            .reservedAt(LocalDateTime.now())
            .expiresAt(expiresAt)
            .build();
    }

    public void cancel() {
        this.reservationStatus = ReservationStatus.CANCELLED;
    }
}