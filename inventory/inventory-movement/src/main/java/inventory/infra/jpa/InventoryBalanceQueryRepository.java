package inventory.infra.jpa;

import inventory.domain.view.InventoryBalanceView;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface InventoryBalanceQueryRepository extends Repository<Object, Long> {

    @Query(value = """
        SELECT
            owner_id            AS ownerId,
            owner_code          AS ownerCode,
            owner_name          AS ownerName,
            warehouse_id        AS warehouseId,
            warehouse_code      AS warehouseCode,
            location_id         AS locationId,
            location_code       AS locationCode,
            item_id             AS itemId,
            item_code           AS itemCode,
            item_name           AS itemName,
            lot_id              AS lotId,
            lot_no              AS lotNo,
            stock_status        AS stockStatus,
            on_hand_qty         AS onHandQty,
            allocated_qty       AS allocatedQty,
            picked_qty          AS pickedQty,
            available_qty       AS availableQty,
            last_transaction_at AS lastTransactionAt
        FROM v_inventory_balance
        WHERE owner_id = :ownerId
        ORDER BY warehouse_id, location_id, item_id, lot_id
        """, nativeQuery = true)
    List<InventoryBalanceView> findByOwnerId(@Param("ownerId") Long ownerId);
}