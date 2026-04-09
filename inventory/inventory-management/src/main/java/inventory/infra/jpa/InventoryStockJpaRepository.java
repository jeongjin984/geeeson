package inventory.infra.jpa;

import inventory.common.enums.StockStatus;
import inventory.domain.master.entity.*;
import inventory.domain.stock.entity.InventoryStock;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface InventoryStockJpaRepository extends JpaRepository<InventoryStock, Long> {
    Optional<InventoryStock> findByOwnerAndWarehouseAndLocationAndItemAndLotAndStockStatus(
        InventoryOwner owner, Warehouse warehouse, Location location, Item item, ItemLot lot, StockStatus stockStatus);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
        select s
        from InventoryStock s
        where s.owner = :owner
          and s.warehouse = :warehouse
          and s.location = :location
          and s.item = :item
          and ((:lot is null and s.lot is null) or s.lot = :lot)
          and s.stockStatus = :stockStatus
    """)
    Optional<InventoryStock> findForUpdateByLocation(
        InventoryOwner owner,
        Warehouse warehouse,
        Location location,
        Item item,
        ItemLot lot,
        StockStatus stockStatus
    );

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
        select s
        from InventoryStock s
        where s.owner = :owner
          and s.warehouse = :warehouse
          and s.item = :item
          and ((:lot is null and s.lot is null) or s.lot = :lot)
          and s.stockStatus = :stockStatus
        order by s.availableQty desc, s.id asc
    """)
    List<InventoryStock> findAllForUpdateWithoutLocation(
        InventoryOwner owner,
        Warehouse warehouse,
        Item item,
        ItemLot lot,
        StockStatus stockStatus
    );
}
