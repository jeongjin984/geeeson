package inventory.domain.service;

import inventory.domain.dto.ReserveInventoryCommand;
import inventory.domain.entity.*;
import inventory.domain.entity.enums.ReservationStatus;
import inventory.domain.entity.enums.StockStatus;
import inventory.domain.vo.StockSnapshot;
import inventory.infra.*;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.CannotAcquireLockException;
import org.springframework.dao.DeadlockLoserDataAccessException;
import org.springframework.dao.PessimisticLockingFailureException;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class ReserveInventoryService {
    private final InventoryReservationRepository inventoryReservationRepository;
    private final InventoryOwnerRepository inventoryOwnerRepository;
    private final WarehouseRepository warehouseRepository;
    private final ItemRepository itemRepository;
    private final ItemLotRepository itemLotRepository;
    private final LocationRepository locationRepository;
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
    public Long reserve(ReserveInventoryCommand command) {
        InventoryOwner owner = inventoryOwnerRepository.findById(command.ownerId())
            .orElseThrow(() -> new IllegalArgumentException("Owner not found"));

        Warehouse warehouse = warehouseRepository.findById(command.warehouseId())
            .orElseThrow(() -> new IllegalArgumentException("Warehouse not found"));

        Location location = locationRepository.findById(command.locationId())
            .orElseThrow(() -> new IllegalArgumentException("Location not found: " + command.locationId()));

        Item item = itemRepository.findById(command.itemId())
            .orElseThrow(() -> new IllegalArgumentException("Item not found"));

        ItemLot lot = command.lotId() == null ? null : itemLotRepository.findById(command.lotId())
            .orElse(null);

        InventoryStock inventoryStock = inventoryStockRepository.findForUpdateByLocation(owner, warehouse, location, item, lot, StockStatus.AVAILABLE)
            .orElseThrow(() -> new IllegalArgumentException("Inventory not found"));

        StockSnapshot before = StockSnapshot.from(inventoryStock);
        inventoryStock.allocate(command.reservedQty());
        StockSnapshot after = StockSnapshot.from(inventoryStock);

        InventoryReservation reservation = inventoryReservationRepository.save(
            InventoryReservation.create(
                owner,
                warehouse,
                location,
                item,
                lot,
                command.referenceType(),
                command.referenceNo(),
                command.referenceLineNo(),
                command.reservedQty(),
                command.expiresAt()
            )
        );

        inventoryTransactionRepository.save(
            InventoryTransaction.allocate(reservation, inventoryStock, before, after)
        );

        return reservation.getId();
    }


}
