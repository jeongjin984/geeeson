package inventory.domain.reservation.dto;

import inventory.common.enums.ReservationReferenceType;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record ReserveInventoryCommand(
    @NotNull Long ownerId,
    @NotNull Long warehouseId,
    @NotNull Long locationId,
    @NotNull Long itemId,
    Long lotId,
    @NotNull ReservationReferenceType referenceType,
    @NotBlank String referenceNo,
    String referenceLineNo,
    @NotNull @DecimalMin(value = "0.0001") BigDecimal reservedQty,
    LocalDateTime expiresAt
) {}