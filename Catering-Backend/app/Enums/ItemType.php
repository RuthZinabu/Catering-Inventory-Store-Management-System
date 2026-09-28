<?php

namespace App\Enums;

enum ItemType: string
{
    case FOOD = 'food';
    case CATERING = 'catering';
    case ELECTRONICS = 'electronics';

    public function label(): string
    {
        return match($this) {
            self::FOOD => 'Food',
            self::CATERING => 'Catering',
            self::ELECTRONICS => 'Electronics',
        };
    }
}