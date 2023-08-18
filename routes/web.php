<?php

use App\Jobs\ExampleJob;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Cache;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::get('/job', function () {
    dispatch(new ExampleJob());
    return response()->json([
        'message' => 'Job has been dispatched'
    ]);
});

Route::get('/test-redis', function () {
   $resultOfCache = Cache::store('redis')->set('my-redis-key', \Illuminate\Support\Str::random());
    return response()->json([
        'resultOfCache' => $resultOfCache,
        'redis-stuff' => Cache::store('redis')->get('my-reds-key')
    ]);
});