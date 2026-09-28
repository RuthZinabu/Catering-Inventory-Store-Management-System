<?php

namespace App\Enums;

enum StockStatus: string
{
    case HEALTHY = 'Healthy';
    case LOW_STOCK = 'Low Stock';
    case OUT_OF_STOCK = 'Out of Stock';
    case EXPIRED = 'Expired';
    case EXPIRING_SOON = 'Expiring Soon';

    public function color(): string
    {
        return match($this) {
            self::HEALTHY => 'green',
            self::LOW_STOCK => 'yellow',
            self::OUT_OF_STOCK => 'red',
            self::EXPIRED => 'red',
            self::EXPIRING_SOON => 'orange',
        };
    }
}