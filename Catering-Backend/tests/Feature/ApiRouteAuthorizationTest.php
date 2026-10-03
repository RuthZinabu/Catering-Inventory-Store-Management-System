<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Tests\CreatesApplication;

class ApiRouteAuthorizationTest extends BaseTestCase
{
    use CreatesApplication;

    public function test_mutating_routes_keep_their_permission_middleware(): void
    {
        $routes = [
            ['GET', '/api/users', 'permission:users.view'],
            ['POST', '/api/users', 'permission:users.create'],
            ['PUT', '/api/users/123', 'permission:users.update'],
            ['PATCH', '/api/stores/123', 'permission:stores.update'],
            ['DELETE', '/api/items/123', 'permission:inventory.delete'],
            ['POST', '/api/suppliers/123/logo', 'permission:suppliers.update'],
            ['POST', '/api/purchase-orders/123/returns', 'permission:purchases.create'],
            ['POST', '/api/purchase-orders/123/returns/456/approve', 'permission:purchases.update'],
        ];

        foreach ($routes as [$method, $uri, $permission]) {
            $route = Route::getRoutes()->match(Request::create($uri, $method));

            $this->assertContains($permission, $route->middleware(), "$method $uri must require $permission");
        }
    }
}