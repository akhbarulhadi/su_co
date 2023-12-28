<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Pesanan;
use Carbon\Carbon;

class UpdateOrderStatus extends Command
{
    protected $signature = 'orders:update-status';
    protected $description = 'Update order status based on deadline';

    public function handle()
    {
        $orders = Pesanan::where('status_pesanan', 'Menunggu')
            ->whereDate('batas_tanggal', '<', Carbon::today())
            ->get();

        foreach ($orders as $order) {
            $order->update(['status_pesanan' => 'Ditunda']);
        }

        $this->info('Order statuses updated successfully.');
    }
}
