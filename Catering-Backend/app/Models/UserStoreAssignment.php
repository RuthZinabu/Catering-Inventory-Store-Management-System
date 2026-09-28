<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserStoreAssignment extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'user_id',
        'store_id',
        'role_in_store',
        'can_transfer_to',
        'can_transfer_from',
    ];

    protected $casts = [
        'can_transfer_to' => 'boolean',
        'can_transfer_from' => 'boolean',
    ];

    /**
     * Store roles
     */
    const ROLE_MANAGER = 'manager';
    const ROLE_SUPERVISOR = 'supervisor';
    const ROLE_STAFF = 'staff';

    /**
     * Get the user.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the store.
     */
    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    /**
     * Check if user can manage this store.
     */
    public function canManage(): bool
    {
        return $this->role_in_store === self::ROLE_MANAGER;
    }

    /**
     * Check if user can supervise this store.
     */
    public function canSupervise(): bool
    {
        return in_array($this->role_in_store, [self::ROLE_MANAGER, self::ROLE_SUPERVISOR]);
    }
}