<?php

use App\Models\User;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id('id_user');
            $table->string('id_staff')->unique();
            $table->string('password');
            $table->string('nama');
            $table->enum('jenis_kelamin', ['Laki-laki', 'Perempuan']);
            $table->string('alamat');
            $table->string('no_tlp')->unique();
            $table->string('foto')->default('null');
            $table->string('email')->unique();
            $table->enum('status', ['aktif.', 'tidak-aktif']);
            $table->enum('roles', ['marketing', 'supervisor', 'leader', 'staff_gudang', 'kepala_gudang', 'admin']);
            $table->timestamps();
        });
        // Menambahkan satu data default
        DB::table('users')->insert([
            'id_staff' => '123',
            'password' => Hash::make('admin'),
            'nama' => 'Admin',
            'jenis_kelamin' => 'Laki-laki',
            'alamat' => 'Default',
            'no_tlp' => '1234567890',
            'foto' => 'default-profile.jpg',
            'email' => 'admin@gmail.com',
            'status' => 'aktif.', // Sesuaikan dengan enum yang telah Anda tentukan
            'roles' => 'admin',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    public function down()
    {
        Schema::dropIfExists('users');
    }
};
