package inventory.domain.reservation.service;

import inventory.domain.reservation.entity.InventoryReservation;
import inventory.domain.stock.entity.InventoryStock;
import inventory.domain.stock.entity.InventoryTransaction;
import inventory.domain.master.entity.Location;
import inventory.common.enums.StockStatus;
import inventory.domain.reservation.vo.StockSnapshot;
import inventory.infra.*;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.CannotAcquireLockException;
import org.springframework.dao.PessimisticLockingFailureException;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
@Transactional
public class CancelReservationService {
    private final InventoryReservationRepository inventoryReservationRepository;
    private final InventoryStockRepository inventoryStockRepository;
    private final InventoryTransactionRepository inventoryTransactionRepository;

    @Retryable(
        retryFor = {
            CannotAcquireLockException.class,
            PessimisticLockingFailureException.class
        },
        maxAttempts = 3,
        backoff = @Backoff(delay = 100, maxDelay = 300, random = true)
    )
    public Long cancelReservation(Long reservationId) {
        InventoryReservation reservation = inventoryReservationRepository.findByIdForUpdate(reservationId)
            .orElseThrow(() -> new IllegalArgumentException("Reservation not found"));

        Location location = reservation.getLocation();
        if (location == null) {
            throw new IllegalStateException("Location is required for current cancellation flow");
        }

        InventoryStock inventoryStock = inventoryStockRepository.findForUpdateByLocation(
                reservation.getOwner(),
                reservation.getWarehouse(),
                location,
                reservation.getItem(),
                reservation.getLot(),
                StockStatus.AVAILABLE
            )
            .orElseThrow(() -> new IllegalArgumentException("Inventory not found for reservation: " + reservationId));

        BigDecimal releaseQty = reservation.cancel();

        StockSnapshot before = StockSnapshot.from(inventoryStock);
        inventoryStock.deallocate(releaseQty);
        StockSnapshot after = StockSnapshot.from(inventoryStock);

        inventoryTransactionRepository.save(
            InventoryTransaction.deallocate(reservation, inventoryStock, before, after, releaseQty)
        );

        return reservation.getId();
    }
}
