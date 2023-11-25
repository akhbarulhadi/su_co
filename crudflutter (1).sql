-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 21 Nov 2023 pada 07.37
-- Versi server: 10.4.20-MariaDB
-- Versi PHP: 8.0.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `crudflutter`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `barang`
--

CREATE TABLE `barang` (
  `id_produk` int(11) NOT NULL,
  `nama_barang` varchar(50) NOT NULL,
  `harga_barang` varchar(100) NOT NULL,
  `jumlah` int(12) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data untuk tabel `barang`
--

INSERT INTO `barang` (`id_produk`, `nama_barang`, `harga_barang`, `jumlah`) VALUES
(1, 'Laptop', 'Rp 12.000.000', 200),
(2, 'Smart Watch', 'Rp 5.000.000', 1000),
(3, 'Processor AMD RYZEN 5000', 'Rp 4.000.000', 200),
(4, 'Adapter Samsung 30 Watt', 'Rp 300.000', 2000);

-- --------------------------------------------------------

--
-- Struktur dari tabel `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(19, '2014_10_12_000000_create_users_table', 1),
(30, '2014_10_12_100000_create_password_reset_tokens_table', 2),
(31, '2019_08_19_000000_create_failed_jobs_table', 2),
(32, '2019_12_14_000001_create_personal_access_tokens_table', 2),
(33, '2023_11_06_135129_create_users_table', 2);

-- --------------------------------------------------------

--
-- Struktur dari tabel `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 1, 'auth_token', 'a05872d009f7572db6c5c5cf999852f970de05adcdaaef7edb215c5a07a834e0', '[\"*\"]', NULL, NULL, '2023-11-10 05:01:16', '2023-11-10 05:01:16'),
(2, 'App\\Models\\User', 1, 'authToken', '9e0466db72c96ddf018b4ada76e9ee720e2f413371ad2a14769b7cfaaa5e6b5f', '[\"*\"]', NULL, NULL, '2023-11-10 06:40:21', '2023-11-10 06:40:21'),
(3, 'App\\Models\\User', 1, 'authToken', '45db1bb4a47111d7790257d4fc9b9278f6c8523eb331404d6ed5fcdb5eb042d9', '[\"*\"]', NULL, NULL, '2023-11-10 06:41:02', '2023-11-10 06:41:02'),
(4, 'App\\Models\\User', 1, 'authToken', '754b061ff1e53b7a076b8f7f8590e0d87dbd1c294ff5e21b30fbb68fa461322e', '[\"*\"]', NULL, NULL, '2023-11-10 06:47:32', '2023-11-10 06:47:32'),
(5, 'App\\Models\\User', 1, 'authToken', '6079fa95720e3affa173a16c9a9a318327ca4caa49001720cad7be8a402548d1', '[\"*\"]', NULL, NULL, '2023-11-12 05:14:53', '2023-11-12 05:14:53'),
(6, 'App\\Models\\User', 1, 'authToken', 'ee21761d4da014174d7b5ddeb1204662073baaf1321cbb18247405d3f16982f0', '[\"*\"]', NULL, NULL, '2023-11-12 06:58:02', '2023-11-12 06:58:02'),
(7, 'App\\Models\\User', 1, 'authToken', '590b130444b736e7bb9392b678dea7884c270f122fdabe4150c891737d91be1f', '[\"*\"]', NULL, NULL, '2023-11-13 05:10:31', '2023-11-13 05:10:31'),
(8, 'App\\Models\\User', 2, 'authToken', '70be6f4edcfbc1b2df43d9f467d1bf89396214c67bc3b274e9fe933773f05bac', '[\"*\"]', NULL, NULL, '2023-11-13 05:20:53', '2023-11-13 05:20:53'),
(9, 'App\\Models\\User', 2, 'authToken', '345fe393d2ddf5697023c4af460807e2a73a298cb8a23305d134639ec6b2c342', '[\"*\"]', NULL, NULL, '2023-11-13 05:38:11', '2023-11-13 05:38:11'),
(10, 'App\\Models\\User', 2, 'authToken', 'aaffe63e979f41188026f5cb12ef32de14ac37d088196d7d5dd2dfef525eea06', '[\"*\"]', NULL, NULL, '2023-11-13 06:01:24', '2023-11-13 06:01:24'),
(11, 'App\\Models\\User', 2, 'authToken', 'e5df8f483195dfa40220dec6e4db819f8dc0078ddca32ef3e3f453145efe00df', '[\"*\"]', NULL, NULL, '2023-11-13 06:19:31', '2023-11-13 06:19:31'),
(12, 'App\\Models\\User', 1, 'authToken', '3132ddfaf93c3bbebd1d587fff0f8e0bd8e7300cf8fa8cfc79c672bc7a3c361d', '[\"*\"]', NULL, NULL, '2023-11-13 06:20:46', '2023-11-13 06:20:46'),
(13, 'App\\Models\\User', 3, 'authToken', '86a7db9aedb5ff8c6acc9874ea11afc2d296bc424257b16d743c9dfc3c7b53dd', '[\"*\"]', NULL, NULL, '2023-11-13 06:29:29', '2023-11-13 06:29:29'),
(14, 'App\\Models\\User', 1, 'authToken', '9a831cd1cfaf861da3461eba68f5ae7d1a27e3b84341b61a95d289ab387b92fd', '[\"*\"]', NULL, NULL, '2023-11-13 06:52:15', '2023-11-13 06:52:15'),
(15, 'App\\Models\\User', 1, 'authToken', '2138424a446198c2cc104f9b190593314da323427e38c4d4d4ee165f6a1c69b4', '[\"*\"]', NULL, NULL, '2023-11-13 06:52:16', '2023-11-13 06:52:16'),
(16, 'App\\Models\\User', 1, 'authToken', 'ba4406f3bc9ba490c0db7d72f2460bec7f2f39f3af5296a273ce31d0ace65c63', '[\"*\"]', NULL, NULL, '2023-11-13 06:55:40', '2023-11-13 06:55:40'),
(17, 'App\\Models\\User', 1, 'authToken', 'a4a19881eaa594153b9717b3dcd206e5d75bddb6746f4c82b7cf23b2f995dd83', '[\"*\"]', NULL, NULL, '2023-11-13 06:55:44', '2023-11-13 06:55:44'),
(18, 'App\\Models\\User', 1, 'authToken', 'fc1a93536438742fea33dd9b6e79c998bd4ee4b9d9d26428c373821ecddec264', '[\"*\"]', NULL, NULL, '2023-11-13 06:55:47', '2023-11-13 06:55:47'),
(19, 'App\\Models\\User', 1, 'authToken', '6b5d40e824f563f1c2c39d895dc7377e44562e3255bb1a8af81464e819c799ea', '[\"*\"]', NULL, NULL, '2023-11-13 06:55:47', '2023-11-13 06:55:47'),
(20, 'App\\Models\\User', 1, 'authToken', '9bd8403fcb837ddfade764070684fdd8bf5f566cdbb53363b06560990d542ece', '[\"*\"]', NULL, NULL, '2023-11-13 06:55:48', '2023-11-13 06:55:48'),
(21, 'App\\Models\\User', 1, 'authToken', '2eb720aac9fbc5f220ef9b40f86dd03372ca4acdfa4ae2cf19e8bfdae49b5550', '[\"*\"]', NULL, NULL, '2023-11-13 06:55:48', '2023-11-13 06:55:48'),
(22, 'App\\Models\\User', 1, 'authToken', 'ed5e118373c1c01ce93e0fa82e8f10f86539492299f9c2e8040e53c70ab9b386', '[\"*\"]', NULL, NULL, '2023-11-13 06:55:52', '2023-11-13 06:55:52'),
(23, 'App\\Models\\User', 1, 'authToken', '5332b7edd8050cd38ed112cc414d6ada7fe97b9ed1e44745162681addf660e7a', '[\"*\"]', NULL, NULL, '2023-11-13 06:55:55', '2023-11-13 06:55:55'),
(24, 'App\\Models\\User', 1, 'authToken', '06e5e74daa98b5152fc61aa27de5d4f4e701e7d3c22e65b89000f87bf43e8ce8', '[\"*\"]', NULL, NULL, '2023-11-13 06:55:56', '2023-11-13 06:55:56'),
(25, 'App\\Models\\User', 1, 'authToken', 'ec4e439ee9d7c196aba52df461800fba6f806c10e21f896dceb262e124801463', '[\"*\"]', NULL, NULL, '2023-11-13 06:56:15', '2023-11-13 06:56:15'),
(26, 'App\\Models\\User', 1, 'authToken', '4a1594ef2f3e05c6526a3ed45123f6c722a4f21ca386023c161040fc4d816705', '[\"*\"]', NULL, NULL, '2023-11-13 06:56:18', '2023-11-13 06:56:18'),
(27, 'App\\Models\\User', 1, 'authToken', 'c0b7728a7d020a36dfbda3fd4e955b3abee9775ec887f96071532139050f251c', '[\"*\"]', NULL, NULL, '2023-11-13 06:56:23', '2023-11-13 06:56:23'),
(28, 'App\\Models\\User', 1, 'authToken', '5eaffa6285a32282a82391f1450c4fa21f4b0ac5da53ec34b6e7af4b35c1e62b', '[\"*\"]', NULL, NULL, '2023-11-13 06:57:08', '2023-11-13 06:57:08'),
(29, 'App\\Models\\User', 1, 'authToken', '5fd339dc754b03f2cf16b78dd845a8033987501bb0aef149f262796aabb79887', '[\"*\"]', NULL, NULL, '2023-11-13 06:57:09', '2023-11-13 06:57:09'),
(30, 'App\\Models\\User', 1, 'authToken', '7e3475924852bbd7a25bd9deb15ebec2edb3cd0dfcd64314437286eada0381fb', '[\"*\"]', NULL, NULL, '2023-11-13 06:57:40', '2023-11-13 06:57:40'),
(31, 'App\\Models\\User', 1, 'authToken', 'b4b7d01abed5ac9df0935755caf89d51027d703686f1a892c8b513d470a8438b', '[\"*\"]', NULL, NULL, '2023-11-13 06:57:41', '2023-11-13 06:57:41'),
(32, 'App\\Models\\User', 1, 'authToken', 'c82f4dba50c1d2230dafafcec948be16af5fcdad4623bfeb2a011a304d2b3eda', '[\"*\"]', NULL, NULL, '2023-11-13 06:59:18', '2023-11-13 06:59:18'),
(33, 'App\\Models\\User', 1, 'authToken', 'e9e6a12aeac4824a9e8389a2e2f93f40fe85ebd267e947d5fdd11749563b2307', '[\"*\"]', NULL, NULL, '2023-11-13 06:59:45', '2023-11-13 06:59:45'),
(34, 'App\\Models\\User', 1, 'authToken', '23d275f0cbb5b0ca388546bc8773f42fb4041479a49d0e6fa139766d71e969eb', '[\"*\"]', NULL, NULL, '2023-11-13 07:00:10', '2023-11-13 07:00:10'),
(35, 'App\\Models\\User', 1, 'authToken', '36571f137eb4d7620eda8b104d7bb75d0cd077b2d144766b7c0f1c75b26ae1b9', '[\"*\"]', NULL, NULL, '2023-11-13 07:00:36', '2023-11-13 07:00:36'),
(36, 'App\\Models\\User', 1, 'authToken', '331e62eeafa9a08fb2cbeec6ec1c6d9372f1a9029fc27d71ee395f849097ef81', '[\"*\"]', NULL, NULL, '2023-11-13 07:01:49', '2023-11-13 07:01:49'),
(37, 'App\\Models\\User', 1, 'authToken', '15c8e1ab8efc87d73c6927fba5c5cb66576c2584412c493450c0c0a97e345a09', '[\"*\"]', NULL, NULL, '2023-11-13 07:01:51', '2023-11-13 07:01:51'),
(38, 'App\\Models\\User', 1, 'authToken', 'eebff45581031b75dd506026a8bb8694b43aef1b823fcd9d5bb8def4bfe71810', '[\"*\"]', NULL, NULL, '2023-11-13 07:01:53', '2023-11-13 07:01:53'),
(39, 'App\\Models\\User', 1, 'authToken', '6326aa525e84ef200985286bfde1ecae135d9278596f6ea03ba0f5fe4fa11a5d', '[\"*\"]', NULL, NULL, '2023-11-13 07:01:56', '2023-11-13 07:01:56'),
(40, 'App\\Models\\User', 1, 'authToken', '77e4be4a40a3ba78a5a1623483625bdccddde0dc5800d6bc749a46b058ade499', '[\"*\"]', NULL, NULL, '2023-11-13 07:01:57', '2023-11-13 07:01:57'),
(41, 'App\\Models\\User', 1, 'authToken', '50b9c69b48ddb93f4d73572557ae14672b36195bd858806fda508cfa36e1105a', '[\"*\"]', NULL, NULL, '2023-11-13 07:01:57', '2023-11-13 07:01:57'),
(42, 'App\\Models\\User', 1, 'authToken', 'c740b7dedcc8c8ea773338fbc156bf0c1797f4a142a03a242d46da79a0e946bc', '[\"*\"]', NULL, NULL, '2023-11-13 07:01:58', '2023-11-13 07:01:58'),
(43, 'App\\Models\\User', 1, 'authToken', 'd719f2bc484dae5af0584bb2071cfdd88f9af8242751d99f37c08a7131e2e0b1', '[\"*\"]', NULL, NULL, '2023-11-13 07:01:58', '2023-11-13 07:01:58'),
(44, 'App\\Models\\User', 1, 'authToken', 'd374649372aac93b9c84b1bb008c1de4fc801acff59249bd58409aa872c7da36', '[\"*\"]', NULL, NULL, '2023-11-13 07:01:59', '2023-11-13 07:01:59'),
(45, 'App\\Models\\User', 1, 'authToken', '06b56d377717c4f541a5e66e7b7c7023485e529017d0a5e0835c4fc74e93c503', '[\"*\"]', NULL, NULL, '2023-11-13 07:01:59', '2023-11-13 07:01:59'),
(46, 'App\\Models\\User', 1, 'authToken', '511b83654cb02e5694acaa982131020cc0e72b0704718a9200face5431da76c1', '[\"*\"]', NULL, NULL, '2023-11-13 07:02:00', '2023-11-13 07:02:00'),
(47, 'App\\Models\\User', 1, 'authToken', '0c6509497290c5eebc816cf4ff845a4c2d09be3f233c55a17a18b1d8d18d5b50', '[\"*\"]', NULL, NULL, '2023-11-13 07:02:08', '2023-11-13 07:02:08'),
(48, 'App\\Models\\User', 1, 'authToken', '30b7e428059fa34671ab5a828693be497921daef1f2d1d41d79ae069d0065333', '[\"*\"]', NULL, NULL, '2023-11-13 07:09:25', '2023-11-13 07:09:25'),
(49, 'App\\Models\\User', 1, 'authToken', 'bdcd43fb18cce7839053801cb08f5454d49c2f742992265eb90f5ed375ec6836', '[\"*\"]', NULL, NULL, '2023-11-13 07:09:26', '2023-11-13 07:09:26'),
(50, 'App\\Models\\User', 1, 'authToken', '9b563ad64278d153dabd47f9536bf4dc19c29c5787b1bc6927b9a2c0004f860f', '[\"*\"]', NULL, NULL, '2023-11-13 07:09:52', '2023-11-13 07:09:52'),
(51, 'App\\Models\\User', 1, 'authToken', 'c5765f041f956213863278794f92be603b0b5e1c7031cbb7291d425c6f38d408', '[\"*\"]', NULL, NULL, '2023-11-14 05:40:04', '2023-11-14 05:40:04'),
(52, 'App\\Models\\User', 1, 'authToken', '9a5e60de27fce7e5a0172b992adbd15fdfe525a5845bc93fea81989426403078', '[\"*\"]', NULL, NULL, '2023-11-14 06:06:33', '2023-11-14 06:06:33'),
(53, 'App\\Models\\User', 1, 'authToken', '26f7c3b8a1441bfa17800bed95697c28a208016887f64679b6d8fa4c10bb01ac', '[\"*\"]', NULL, NULL, '2023-11-14 06:07:11', '2023-11-14 06:07:11'),
(54, 'App\\Models\\User', 2, 'authToken', 'ae221f59073367dfe758513ed5d3bc214f5706cd26fc718d0d245400eac2d89e', '[\"*\"]', NULL, NULL, '2023-11-14 06:07:22', '2023-11-14 06:07:22'),
(55, 'App\\Models\\User', 1, 'authToken', '8eb1c8fc4c0e10d1a2da60bbaeb505679250d72b262d8dcbb0938e9d9bdf5ea0', '[\"*\"]', NULL, NULL, '2023-11-14 06:08:42', '2023-11-14 06:08:42'),
(56, 'App\\Models\\User', 1, 'authToken', '6e27f59ceacfede621980346a1a34dbdd39cbba2212215c1417a59f69a4a4b4b', '[\"*\"]', NULL, NULL, '2023-11-14 06:11:18', '2023-11-14 06:11:18'),
(57, 'App\\Models\\User', 1, 'authToken', 'e1d2dfa516fea1192e128170548d30d701024c1f359325adbb6773af7e0ac8bf', '[\"*\"]', NULL, NULL, '2023-11-14 06:14:59', '2023-11-14 06:14:59'),
(58, 'App\\Models\\User', 1, 'authToken', 'be6036e5c1135acb04eae00df7175a828639fcdcf93075e5a199d25d54de6a7e', '[\"*\"]', NULL, NULL, '2023-11-14 06:32:55', '2023-11-14 06:32:55'),
(59, 'App\\Models\\User', 1, 'authToken', 'e5e615243f690d9957d0512710b08bccec936a6d9128fbe885d1f2a2a4d4b4e4', '[\"*\"]', NULL, NULL, '2023-11-14 06:33:01', '2023-11-14 06:33:01'),
(60, 'App\\Models\\User', 1, 'authToken', '105bf4d8678f2d0ef82fed9cf468aeaa1fd237ac83cf77edad1e42d04249d53f', '[\"*\"]', NULL, NULL, '2023-11-14 06:33:25', '2023-11-14 06:33:25'),
(61, 'App\\Models\\User', 1, 'authToken', '23c9b1d940ece89da1586ca5612d351b06bbc3884de5d4bc157e68ad510a0a84', '[\"*\"]', NULL, NULL, '2023-11-14 06:35:43', '2023-11-14 06:35:43'),
(62, 'App\\Models\\User', 1, 'authToken', '5045de34f78d1fdc8cee1a054ba2c1de93c7d26a8798b59dcca5163fdf1d36a7', '[\"*\"]', NULL, NULL, '2023-11-14 06:37:23', '2023-11-14 06:37:23'),
(63, 'App\\Models\\User', 1, 'authToken', '5bf5140dd59678ad4706628c3159de250c6ed11df7357fab894b6c27e224bd13', '[\"*\"]', NULL, NULL, '2023-11-14 06:38:19', '2023-11-14 06:38:19'),
(64, 'App\\Models\\User', 1, 'authToken', 'a26989b8de6d6275a6a9118ddab97c64629819e3e05a5b640aff24b7453c9b10', '[\"*\"]', NULL, NULL, '2023-11-15 22:46:53', '2023-11-15 22:46:53'),
(65, 'App\\Models\\User', 1, 'authToken', '6e8cd1cc71533f5dcba44fd274f6dd986fdf02001ea88c7c0a60055e5c096be6', '[\"*\"]', NULL, NULL, '2023-11-15 22:47:23', '2023-11-15 22:47:23'),
(66, 'App\\Models\\User', 1, 'authToken', 'cc37af779ea877962bf035ec828edf4f59f7f87e998ccddd39cde2e5cac0db89', '[\"*\"]', NULL, NULL, '2023-11-15 22:48:52', '2023-11-15 22:48:52'),
(67, 'App\\Models\\User', 1, 'authToken', 'c50a67d75977e6e551d177dd1f5eb3eea343fc5eb08f0e9c181d292d65b58d49', '[\"*\"]', NULL, NULL, '2023-11-15 22:51:16', '2023-11-15 22:51:16'),
(68, 'App\\Models\\User', 1, 'authToken', '9e4adfb1e385c9f3b38fcf81aaad80af2228daa58db67cd38dd1fb05574dcaf5', '[\"*\"]', NULL, NULL, '2023-11-15 22:54:20', '2023-11-15 22:54:20'),
(69, 'App\\Models\\User', 1, 'authToken', '8f8358ded274a463c9f46734c23ec75d56727d37f25e6d31d40b8e75fa945380', '[\"*\"]', NULL, NULL, '2023-11-15 22:59:16', '2023-11-15 22:59:16'),
(70, 'App\\Models\\User', 1, 'authToken', '79d06ca3193d6fe34a499d9aa8fc274f5e744c8bd3bb7c1a6cc050d1e361284a', '[\"*\"]', NULL, NULL, '2023-11-15 23:09:57', '2023-11-15 23:09:57'),
(71, 'App\\Models\\User', 1, 'authToken', '99a40c4d87625caff5a3e826ae524377ecacb49b8d291bd700ec4e00203bfa3f', '[\"*\"]', NULL, NULL, '2023-11-15 23:09:57', '2023-11-15 23:09:57'),
(72, 'App\\Models\\User', 4, 'auth_token', '91dcaf0f352d0e88b0f0e5dc80e6308acc97cd993ea1002da5195f8a38a23be1', '[\"*\"]', NULL, NULL, '2023-11-16 02:40:32', '2023-11-16 02:40:32'),
(73, 'App\\Models\\User', 1, 'authToken', '776aa0978ffe53d6ca16eb020ee47a78abf426ffbe6e5df6b0d3a266724076ca', '[\"*\"]', NULL, NULL, '2023-11-16 02:42:59', '2023-11-16 02:42:59'),
(74, 'App\\Models\\User', 5, 'auth_token', 'eeeb034d1f5e970f964e53db0e9e93391c5d77a7bb8225ef95c673d6ccfb35e3', '[\"*\"]', NULL, NULL, '2023-11-16 02:55:04', '2023-11-16 02:55:04'),
(75, 'App\\Models\\User', 1, 'authToken', 'cbaef56f91b31c077b83e945ff1d004df45824ff4cbd0fc58540f1666de5c5b8', '[\"*\"]', NULL, NULL, '2023-11-16 02:55:48', '2023-11-16 02:55:48'),
(76, 'App\\Models\\User', 1, 'authToken', 'd319ec469735a074d389274820d2752eb4d088e998174ca868eb4bdcd5df03aa', '[\"*\"]', NULL, NULL, '2023-11-16 03:14:47', '2023-11-16 03:14:47'),
(77, 'App\\Models\\User', 2, 'authToken', 'c81cae1e866479ecc4ba3ddf62819e7246b91c0c64c24e31f8ad5ecb978da374', '[\"*\"]', NULL, NULL, '2023-11-16 04:22:49', '2023-11-16 04:22:49'),
(78, 'App\\Models\\User', 1, 'authToken', '7fa468af04f8c82f835571f9d718f27225568f85f8b0afc742a7759e53d8c104', '[\"*\"]', NULL, NULL, '2023-11-16 04:23:06', '2023-11-16 04:23:06'),
(79, 'App\\Models\\User', 1, 'authToken', 'd33f4f59826b19fc5c852592310dc53cd2a784f4bbd14f2ce801064149785755', '[\"*\"]', NULL, NULL, '2023-11-16 04:23:12', '2023-11-16 04:23:12'),
(80, 'App\\Models\\User', 1, 'authToken', 'ffca150506cca3bf9e0fb3867b7bfdca0822fcefd37b4d825af5d01850ef0947', '[\"*\"]', NULL, NULL, '2023-11-16 04:35:47', '2023-11-16 04:35:47'),
(81, 'App\\Models\\User', 1, 'authToken', 'ee066d0c928972b9384fda54379c76fbcc2b172a30d78060b0b21af3ffe1e1e1', '[\"*\"]', NULL, NULL, '2023-11-16 04:51:57', '2023-11-16 04:51:57'),
(82, 'App\\Models\\User', 1, 'authToken', '10cc9255efd57eca30763bae738fd1531476a8fbb18f33f7b18f5e7f766e8e41', '[\"*\"]', NULL, NULL, '2023-11-16 04:53:51', '2023-11-16 04:53:51'),
(83, 'App\\Models\\User', 1, 'authToken', '54e4dac5a069dcb2b2275554170e275563708c827acce0f44b1cda6513057a2d', '[\"*\"]', NULL, NULL, '2023-11-16 04:54:03', '2023-11-16 04:54:03'),
(84, 'App\\Models\\User', 6, 'auth_token', 'e479313484c06d3fa63b520a25ab5bbcf931297c86a7a515bdf4204c9e4d6cc8', '[\"*\"]', NULL, NULL, '2023-11-16 04:54:57', '2023-11-16 04:54:57'),
(85, 'App\\Models\\User', 1, 'authToken', 'ded8b3208921ce4a62a2594f62d769743bf15661863a294e86d5dec0fa8b73a1', '[\"*\"]', NULL, NULL, '2023-11-16 04:55:11', '2023-11-16 04:55:11'),
(86, 'App\\Models\\User', 1, 'authToken', 'e1f6068069ff925b603c2aa2d37e20d26ecc5b25d1fdf919d6e6b86f0c6cbc4c', '[\"*\"]', NULL, NULL, '2023-11-16 05:46:27', '2023-11-16 05:46:27'),
(87, 'App\\Models\\User', 1, 'authToken', '8ea72bd9cd963e65eba138978004f19b2302bde41758560004ba014df01d78fa', '[\"*\"]', NULL, NULL, '2023-11-16 05:46:28', '2023-11-16 05:46:28'),
(88, 'App\\Models\\User', 1, 'authToken', '744e5a711a4c162772367701c98f0fc7ca05f424e22e396d910e49dc27b7618b', '[\"*\"]', NULL, NULL, '2023-11-16 05:46:28', '2023-11-16 05:46:28'),
(89, 'App\\Models\\User', 1, 'authToken', '7c94e1a0e6bee96a5c942c4ade1574a84018265102c7e3a9bd2d7c1d649bc7d6', '[\"*\"]', NULL, NULL, '2023-11-16 07:10:03', '2023-11-16 07:10:03'),
(90, 'App\\Models\\User', 1, 'authToken', 'ce5cd3e1effa2e881afda40d9a55413d29cca973b99e7d1ee2c191ed6c1f5afe', '[\"*\"]', NULL, NULL, '2023-11-16 07:10:04', '2023-11-16 07:10:04'),
(91, 'App\\Models\\User', 1, 'authToken', '01b18eeb38e440500e1a9dfcdfbab6fd27f448c8729937ae91fc8b0675cdd5da', '[\"*\"]', NULL, NULL, '2023-11-16 07:10:20', '2023-11-16 07:10:20'),
(92, 'App\\Models\\User', 1, 'authToken', '536bd9d8fc5e8ad3caf30b48fe5e943638e3de536b73f9a695a53a5b7a11ac75', '[\"*\"]', NULL, NULL, '2023-11-16 07:13:21', '2023-11-16 07:13:21'),
(93, 'App\\Models\\User', 1, 'authToken', 'df12dd5d7e0ba9583cc505f6bce39d8dc3092a7a27d27792359cf34f760960b6', '[\"*\"]', NULL, NULL, '2023-11-16 07:15:09', '2023-11-16 07:15:09'),
(94, 'App\\Models\\User', 1, 'authToken', '68fbde22032895d6af3803256999855f460e3675269829c5dd101a405621ceb5', '[\"*\"]', NULL, NULL, '2023-11-16 07:15:11', '2023-11-16 07:15:11'),
(95, 'App\\Models\\User', 1, 'authToken', 'b06a8cb6bdd62f7d257e10fc689d2e068f95ec8209ddc74e55fb828c9ae4cf63', '[\"*\"]', NULL, NULL, '2023-11-16 07:16:42', '2023-11-16 07:16:42'),
(96, 'App\\Models\\User', 1, 'authToken', '100ad403540fb392fc05af231bbc4a5a60098b92926c2d1a851b8793a2cadfc9', '[\"*\"]', NULL, NULL, '2023-11-17 01:21:07', '2023-11-17 01:21:07'),
(97, 'App\\Models\\User', 7, 'auth_token', 'ca28293a81133aab77501187377186ce048be16f586fe2487fb69882f7d0587a', '[\"*\"]', NULL, NULL, '2023-11-17 01:29:15', '2023-11-17 01:29:15'),
(98, 'App\\Models\\User', 1, 'authToken', 'db8cb0f7cafc36cc01f49bbb44aad55a71e3545dc8e2f63f5e286bcc629ae851', '[\"*\"]', NULL, NULL, '2023-11-17 01:29:40', '2023-11-17 01:29:40'),
(99, 'App\\Models\\User', 8, 'auth_token', '778ca579d027050f869e56484ad2f3d4e4584c5b45a43f8979c60bf603067d2e', '[\"*\"]', NULL, NULL, '2023-11-17 02:15:16', '2023-11-17 02:15:16'),
(100, 'App\\Models\\User', 1, 'authToken', '7dd159389498a63055425e65dc2d196be3707b812226040d86971262f8b881e4', '[\"*\"]', NULL, NULL, '2023-11-17 02:17:56', '2023-11-17 02:17:56'),
(101, 'App\\Models\\User', 1, 'authToken', '7776043bf0a7e99d1cef86bc02bf5edf71c8088e29a9dafe226eb0e230f17f1d', '[\"*\"]', NULL, NULL, '2023-11-17 02:24:25', '2023-11-17 02:24:25'),
(102, 'App\\Models\\User', 9, 'auth_token', '76d3075608a12cde4add56ab9a99a311bf2ae5a30ea25d3d940ee862115eb627', '[\"*\"]', NULL, NULL, '2023-11-17 02:30:12', '2023-11-17 02:30:12'),
(103, 'App\\Models\\User', 1, 'authToken', '9f1931b50caa9de55d02f895f54408b81a9645e3ba787fcc579c29e167e88378', '[\"*\"]', NULL, NULL, '2023-11-17 03:21:20', '2023-11-17 03:21:20'),
(104, 'App\\Models\\User', 1, 'authToken', 'e1b3106596856ed76c9f93885bd57e395a8ada6bbd76a4ef7da363844dc09905', '[\"*\"]', NULL, NULL, '2023-11-17 03:53:25', '2023-11-17 03:53:25'),
(105, 'App\\Models\\User', 1, 'authToken', 'ee89d431801225e0288b62344537ccc1be5f17645311c45add6a56714efd0ecf', '[\"*\"]', NULL, NULL, '2023-11-17 04:56:20', '2023-11-17 04:56:20'),
(106, 'App\\Models\\User', 1, 'authToken', 'f9e8c8ee12f086d6f94eae95a5914ce1859c1749c341477b858b3ed5d1e2a9a6', '[\"*\"]', NULL, NULL, '2023-11-17 04:56:20', '2023-11-17 04:56:20'),
(107, 'App\\Models\\User', 1, 'authToken', '5e8d5cb3ac264ce62213a2d8d9b94c8458c8edee786e722d4bcfcb6fe0704cba', '[\"*\"]', NULL, NULL, '2023-11-17 05:18:35', '2023-11-17 05:18:35'),
(108, 'App\\Models\\User', 1, 'authToken', 'fb3c895e337800a32a749f5338b7baf017827f43d57f380324bda6f48107364e', '[\"*\"]', NULL, NULL, '2023-11-20 03:21:54', '2023-11-20 03:21:54'),
(109, 'App\\Models\\User', 10, 'auth_token', '1601111a4e90941b29dc719ea5eda51653585bead62bdeaedd1bb0227adb738b', '[\"*\"]', NULL, NULL, '2023-11-20 04:27:57', '2023-11-20 04:27:57'),
(110, 'App\\Models\\User', 1, 'authToken', 'c218a5dc9a7549ddc4fe7174378d489e2fce1e66a158e72fac5d2f00a4e11a23', '[\"*\"]', NULL, NULL, '2023-11-20 04:28:52', '2023-11-20 04:28:52'),
(111, 'App\\Models\\User', 1, 'authToken', 'c49ea7a4e0aabe1460f05ca4e476d2d460500f74a829abada953b08f8ee33f40', '[\"*\"]', NULL, NULL, '2023-11-20 04:33:19', '2023-11-20 04:33:19'),
(112, 'App\\Models\\User', 1, 'authToken', '842ebb7cb3680c83e5732a5ad7589165d05c42ea512a03f232440287571cfd3e', '[\"*\"]', NULL, NULL, '2023-11-20 05:23:27', '2023-11-20 05:23:27'),
(113, 'App\\Models\\User', 1, 'authToken', '13718c53e3fb1f1e241480ca4df5d6457a0c64c31ca5604d0a1d039fbc8fe008', '[\"*\"]', NULL, NULL, '2023-11-20 05:23:28', '2023-11-20 05:23:28');

-- --------------------------------------------------------

--
-- Struktur dari tabel `siswa`
--

CREATE TABLE `siswa` (
  `id` int(12) NOT NULL,
  `nisn` varchar(20) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `alamat` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data untuk tabel `siswa`
--

INSERT INTO `siswa` (`id`, `nisn`, `nama`, `alamat`) VALUES
(1, '111111', 'akhbar', 'batam'),
(2, '111112', 'hadi', 'jombang'),
(3, '111113', 'patrick star', 'Dibawah Batu, Jalan Keong No. 120 , bikini bottom'),
(4, '111114', 'Sheldon J. Plankton', 'Chum Bucket, Bikini Bottom, Samudra Pasifik'),
(5, '111115', 'Isnin bin Khamis', 'Kampung Durian Runtuh');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `id_staff` int(11) NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nama` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `jenis_kelamin` enum('Laki-laki','Perempuan') COLLATE utf8mb4_unicode_ci NOT NULL,
  `alamat` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `no_tlp` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `foto` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'null',
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('aktif','tidak-aktif') COLLATE utf8mb4_unicode_ci NOT NULL,
  `roles` enum('marketing','supervisor','leader','staff_gudang','kepala_gudang','admin') COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `id_staff`, `password`, `nama`, `jenis_kelamin`, `alamat`, `no_tlp`, `foto`, `email`, `status`, `roles`, `created_at`, `updated_at`) VALUES
(1, 123456, '$2y$12$6h6oKsom0eLy8IqbPVcvM.3UY8eWVXurERflATVhz2XiL5NDin5y.', 'Rois', 'Laki-laki', 'Kp Melayu', '081276111520', 'null', 'roismauludi72@gmail.com', 'aktif', 'admin', '2023-11-10 05:01:16', '2023-11-14 05:01:16'),
(2, 123457, '$2y$10$0DrTQMeEB6i9wOGwv2n54ud9ZtH6guUdBHfwz8a2q/LDwtDjqmluu', 'awa', 'Perempuan', 'batam', '081241242131', 'default-profile.jpg', 'awa@gmail.com', 'aktif', 'marketing', NULL, NULL),
(3, 1234578, '$2y$10$a.n2eI4KjPW5YNiGwptg/uV5el5h23V17RTeMzvEh6hnCR/qTAR5W', 'rois', 'Laki-laki', 'jodoh', '123874124131', 'default-profile.jpg', 'rois@gmail.com', 'aktif', 'staff_gudang', NULL, NULL),
(9, 121398, '$2y$12$ledLAdNdyui4imaBF0Yc/ucVm8X1QTB/tIhgdtiYstdPRza.42ds2', 'Roisa', 'Laki-laki', 'Kp Melayu', '0812761112', 'default-profile.jpg', 'roismauludi70@gmail.com', 'aktif', 'staff_gudang', '2023-11-17 02:30:12', '2023-11-17 02:30:12'),
(10, 1213982, '$2y$12$TFbR3awcPzoJOe8LFGkVUePC3uwCBQcfsHlvhPOTH/t01NJbW8RHK', 'Roisa', 'Laki-laki', 'Kp Melayu', '08127611122', 'default-profile.jpg', 'roismauludi90@gmail.com', 'aktif', 'staff_gudang', '2023-11-20 04:27:57', '2023-11-20 04:27:57');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `barang`
--
ALTER TABLE `barang`
  ADD PRIMARY KEY (`id_produk`);

--
-- Indeks untuk tabel `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indeks untuk tabel `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indeks untuk tabel `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indeks untuk tabel `siswa`
--
ALTER TABLE `siswa`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_id_staff_unique` (`id_staff`),
  ADD UNIQUE KEY `users_no_tlp_unique` (`no_tlp`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `barang`
--
ALTER TABLE `barang`
  MODIFY `id_produk` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT untuk tabel `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=114;

--
-- AUTO_INCREMENT untuk tabel `siswa`
--
ALTER TABLE `siswa`
  MODIFY `id` int(12) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
