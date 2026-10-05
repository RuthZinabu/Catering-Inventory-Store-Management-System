<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $validated = $request->validate([
            'search' => 'nullable|string|max:100',
            'category' => ['nullable', Rule::in(['purchases', 'transfers', 'kitchen', 'waste', 'inventory'])],
            'unread' => 'nullable|boolean',
            'page' => 'nullable|integer|min:1',
            'per_page' => 'nullable|integer|min:1|max:50',
        ]);

        $since = now()->subDays(90);
        $userNotifications = $request->user()->notifications();
        $unreadCount = (clone $userNotifications)->whereNull('read_at')
            ->where('created_at', '>=', $since)->count();

        $query = $request->user()->notifications()
            ->where('created_at', '>=', $since);
        if (!empty($validated['category'])) {
            $query->where('data->category', $validated['category']);
        }
        if (!empty($validated['unread'])) {
            $query->whereNull('read_at');
        }
        if (!empty($validated['search'])) {
            $search = '%' . addcslashes($validated['search'], '\\%_') . '%';
            $query->where(function ($builder) use ($search) {
                $builder->where('data->title', 'like', $search)
                    ->orWhere('data->message', 'like', $search);
            });
        }

        $notifications = $query->latest()->paginate($validated['per_page'] ?? 25);

        return $this->success([
            'notifications' => $notifications->getCollection()->map(
                fn ($notification) => $this->serialize($notification)
            )->values(),
            'unread_count' => $unreadCount,
            'pagination' => [
                'current_page' => $notifications->currentPage(),
                'last_page' => $notifications->lastPage(),
                'per_page' => $notifications->perPage(),
                'total' => $notifications->total(),
            ],
        ]);
    }

    public function markAsRead(Request $request, $notification)
    {
        $notification = $request->user()->notifications()->whereKey($notification)->firstOrFail();
        if ($notification->read_at === null) {
            $notification->markAsRead();
        }

        return $this->success([
            'notification' => $this->serialize($notification->fresh()),
            'unread_count' => $request->user()->unreadNotifications()
                ->where('created_at', '>=', now()->subDays(90))->count(),
        ], 'Notification marked as read');
    }

    private function serialize($notification): array
    {
        return [
            'id' => $notification->id,
            'title' => $notification->data['title'] ?? 'Notification',
            'message' => $notification->data['message'] ?? '',
            'category' => $notification->data['category'] ?? 'inventory',
            'store_id' => $notification->data['store_id'] ?? null,
            'reference_type' => $notification->data['reference_type'] ?? null,
            'reference_id' => $notification->data['reference_id'] ?? null,
            'read_at' => $notification->read_at,
            'created_at' => $notification->created_at,
        ];
    }
}