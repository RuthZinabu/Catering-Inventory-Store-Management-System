<?php

namespace App\Enums;

enum MovementType: string
{
    case STOCK_IN = 'Stock In';
    case STOCK_OUT = 'Stock Out';
    case TRANSFER = 'Transfer';
    case ADJUSTMENT = 'Adjustment';
    case RETURN = 'Return';
    case CORRECTION = 'Correction';

    public function isPositive(): bool
    {
        return match($this) {
            self::STOCK_IN, self::RETURN => true,
            self::STOCK_OUT, self::TRANSFER => false,
            self::ADJUSTMENT, self::CORRECTION => null, // Depends on quantity
        };
    }
}