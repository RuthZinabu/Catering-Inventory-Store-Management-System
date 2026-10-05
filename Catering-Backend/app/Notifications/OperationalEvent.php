<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class OperationalEvent extends Notification
{
    use Queueable;

    public function __construct(
        private readonly string $title,
        private readonly string $message,
        private readonly string $category,
        private readonly ?string $storeId = null,
        private readonly ?string $referenceType = null,
        private readonly ?string $referenceId = null,
    ) {
    }

    public function via($notifiable): array
    {
        return ['database'];
    }

    public function toDatabase($notifiable): array
    {
        return [
            'title' => $this->title,
            'message' => $this->message,
            'category' => $this->category,
            'store_id' => $this->storeId,
            'reference_type' => $this->referenceType,
            'reference_id' => $this->referenceId,
        ];
    }
}
