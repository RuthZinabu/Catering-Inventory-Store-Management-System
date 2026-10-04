<?php

namespace App\Services;

use App\Models\InventoryBatch;

class InventoryBatchService
{
    public function consume(string $storeId, string $itemId, float $quantity): void
    {
        if ($quantity <= 0) {
            return;
        }

        $batches = InventoryBatch::query()
            ->where('store_id', $storeId)
            ->where('item_id', $itemId)
            ->where('quantity_remaining', '>', 0)
            ->orderBy('expires_on')
            ->orderBy('created_at')
            ->lockForUpdate()
            ->get();

        foreach ($batches as $batch) {
            if ($quantity <= 0.0005) {
                break;
            }

            $available = (float) $batch->quantity_remaining;
            $consumed = min($available, $quantity);
            $batch->update(['quantity_remaining' => max(0, $available - $consumed)]);
            $quantity -= $consumed;
        }
    }
}