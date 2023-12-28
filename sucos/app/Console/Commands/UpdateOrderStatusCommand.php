<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class UpdateOrderStatusCommand extends Command
{
    protected $signature = 'orders:update-status';
    protected $description = 'Update order status to "Ditunda" if batas_tanggal has passed.';

    public function handle()
    {
        $now = Carbon::now();

        // Find orders with status "Menunggu" and batas_tanggal in the past
        $orders = DB::table('pesanan')
            ->where('status_pesanan', 'Menunggu')
            ->where('batas_tanggal', '<', $now)
            ->get();

        // Update the status to "Ditunda" for the selected orders
        foreach ($orders as $order) {
            DB::table('pesanan')
                ->where('id_pemesanan', $order->id_pemesanan)
                ->update(['status_pesanan' => 'Ditunda']);
        }

        $this->info('Order statuses updated successfully.');
    }
}
