<?php

namespace App\Services;

use App\Models\User;
use App\Notifications\OperationalEvent;
use Illuminate\Support\Facades\Notification;

class OperationalNotificationService
{
    public function notifyStores(
        array $storeIds,
        User $actor,
        string $title,
        string $message,
        string $category,
        string $referenceType,
        string $referenceId
    ): void {
        $storeIds = array_values(array_unique(array_filter($storeIds)));
        if ($storeIds === []) {
            return;
        }

        $recipients = User::query()
            ->where('status', User::STATUS_ACTIVE)
            ->where('id', '!=', $actor->id)
            ->where(function ($query) use ($storeIds) {
                $query->where('role', User::ROLE_ADMIN)
                    ->orWhereHas('stores', fn ($stores) => $stores->whereIn('stores.id', $storeIds));
            })
            ->get();

        if ($recipients->isNotEmpty()) {
            Notification::send($recipients, new OperationalEvent(
                $title,
                $message,
                $category,
                count($storeIds) === 1 ? $storeIds[0] : null,
                $referenceType,
                $referenceId
            ));
        }
    }

    public function notifyUser(
        ?string $recipientId,
        User $actor,
        string $title,
        string $message,
        string $category,
        string $storeId,
        string $referenceType,
        string $referenceId
    ): void {
        if (!$recipientId || $recipientId === $actor->id) {
            return;
        }

        $recipient = User::query()
            ->where('status', User::STATUS_ACTIVE)
            ->find($recipientId);

        $recipient?->notify(new OperationalEvent(
            $title,
            $message,
            $category,
            $storeId,
            $referenceType,
            $referenceId
        ));
    }
}
