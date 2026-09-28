<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, HasUuids, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'phone',
        'role',
        'department',
        'status',
        'permissions',
        'two_factor_enabled',
        'two_factor_secret',
        'failed_login_attempts',
        'locked_until',
        'password_changed_at',
        'must_change_password',
        'last_login_at',
        'email_verified_at',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'two_factor_secret',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password_changed_at' => 'datetime',
        'last_login_at' => 'datetime',
        'locked_until' => 'datetime',
        'permissions' => 'array',
        'two_factor_enabled' => 'boolean',
        'must_change_password' => 'boolean',
        'failed_login_attempts' => 'integer',
        'password' => 'hashed',
    ];

    const DELETED_AT = 'deleted_at';

    /**
     * User roles
     */
    const ROLE_ADMIN = 'admin';
    const ROLE_STORE_MANAGER = 'store_manager';
    const ROLE_KITCHEN_SUPERVISOR = 'kitchen_supervisor';
    const ROLE_CASHIER = 'cashier';
    const ROLE_STOREKEEPER = 'storekeeper';
    const ROLE_CHEF = 'chef';

    /**
     * User statuses
     */
    const STATUS_ACTIVE = 'Active';
    const STATUS_INACTIVE = 'Inactive';
    const STATUS_SUSPENDED = 'Suspended';

    /**
     * Get the store assignments for the user.
     */
    public function storeAssignments()
    {
        return $this->hasMany(UserStoreAssignment::class);
    }

    /**
     * Get the stores this user is assigned to.
     */
    public function stores()
    {
        return $this->belongsToMany(Store::class, 'user_store_assignments')
                    ->withPivot(['role_in_store', 'can_transfer_to', 'can_transfer_from'])
                    ->withTimestamps();
    }

    /**
     * Get stock movements performed by this user.
     */
    public function stockMovements()
    {
        return $this->hasMany(StockMovement::class, 'performed_by');
    }

    /**
     * Get audit logs for this user.
     */
    public function auditLogs()
    {
        return $this->hasMany(AuditLog::class);
    }

    /**
     * Check if user has a specific permission.
     */
    public function hasPermission(string $permission): bool
    {
        if ($this->role === self::ROLE_ADMIN) {
            return true;
        }

        return in_array($permission, $this->permissions ?? []);
    }

    /**
     * Check if user can access a specific store.
     */
    public function canAccessStore(string $storeId): bool
    {
        if ($this->role === self::ROLE_ADMIN) {
            return true;
        }

        return $this->stores()->where('stores.id', $storeId)->exists();
    }

    /**
     * Check if user account is locked.
     */
    public function isLocked(): bool
    {
        return $this->locked_until && $this->locked_until->isFuture();
    }

    /**
     * Increment failed login attempts.
     */
    public function incrementLoginAttempts(): void
    {
        $this->increment('failed_login_attempts');
        
        if ($this->failed_login_attempts >= 5) {
            $this->update(['locked_until' => now()->addMinutes(15)]);
        }
    }

    /**
     * Reset failed login attempts.
     */
    public function resetLoginAttempts(): void
    {
        $this->update([
            'failed_login_attempts' => 0,
            'locked_until' => null,
        ]);
    }
}