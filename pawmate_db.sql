-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.30 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for pawmate_db
DROP DATABASE IF EXISTS `pawmate_db`;
CREATE DATABASE IF NOT EXISTS `pawmate_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `pawmate_db`;

-- Dumping structure for table pawmate_db.carts
DROP TABLE IF EXISTS `carts`;
CREATE TABLE IF NOT EXISTS `carts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `carts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `carts_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table pawmate_db.carts: ~0 rows (approximately)

-- Dumping structure for table pawmate_db.orders
DROP TABLE IF EXISTS `orders`;
CREATE TABLE IF NOT EXISTS `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `shipping_address` text NOT NULL,
  `status` enum('pending_payment','waiting_confirmation','paid','shipped','completed','cancelled') DEFAULT 'pending_payment',
  `cancel_reason` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table pawmate_db.orders: ~11 rows (approximately)
INSERT INTO `orders` (`id`, `user_id`, `total_price`, `shipping_address`, `status`, `cancel_reason`, `created_at`) VALUES
	(1, 2, 200000.00, 'aaaaaa', 'pending_payment', NULL, '2025-12-27 16:21:48'),
	(2, 2, 22000.00, 'vvvvvv', 'pending_payment', NULL, '2025-12-27 16:24:07'),
	(3, 2, 15000.00, 'nnn', 'pending_payment', NULL, '2025-12-27 17:59:46'),
	(4, 2, 120000.00, 'kkk', 'shipped', NULL, '2025-12-27 18:00:30'),
	(5, 2, 25000.00, 'jjj', 'cancelled', NULL, '2025-12-28 03:34:12'),
	(6, 2, 50000.00, 'hh', 'pending_payment', NULL, '2025-12-28 03:40:39'),
	(7, 2, 35000.00, 'jijio', 'cancelled', 'Salah pilih produk', '2025-12-28 05:57:57'),
	(8, 2, 12000.00, 'nnn', 'completed', NULL, '2025-12-28 06:18:12'),
	(9, 2, 65000.00, 'kokookkii', 'completed', NULL, '2025-12-28 07:07:26'),
	(10, 2, 15000.00, 'kompos', 'cancelled', 'Lupa memasukkan voucher', '2025-12-28 07:25:12'),
	(11, 2, 35000.00, 'nji', 'cancelled', NULL, '2025-12-28 07:25:36'),
	(12, 2, 12000.00, 'lop', 'cancelled', '[Admin] barang rusak', '2025-12-28 07:37:42'),
	(13, 2, 65000.00, 'gunung', 'completed', NULL, '2025-12-29 14:21:28');

-- Dumping structure for table pawmate_db.order_details
DROP TABLE IF EXISTS `order_details`;
CREATE TABLE IF NOT EXISTS `order_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL,
  `price_per_unit` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `order_details_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `order_details_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table pawmate_db.order_details: ~15 rows (approximately)
INSERT INTO `order_details` (`id`, `order_id`, `product_id`, `quantity`, `price_per_unit`) VALUES
	(1, 1, 1, 1, 25000.00),
	(2, 1, 7, 2, 10000.00),
	(3, 1, 4, 1, 35000.00),
	(4, 1, 6, 1, 120000.00),
	(5, 2, 8, 1, 12000.00),
	(6, 2, 7, 1, 10000.00),
	(7, 3, 5, 1, 15000.00),
	(8, 4, 6, 1, 120000.00),
	(9, 5, 1, 1, 25000.00),
	(10, 6, 1, 2, 25000.00),
	(11, 7, 4, 1, 35000.00),
	(12, 8, 8, 1, 12000.00),
	(13, 9, 2, 1, 65000.00),
	(14, 10, 5, 1, 15000.00),
	(15, 11, 4, 1, 35000.00),
	(16, 12, 8, 1, 12000.00),
	(17, 13, 2, 1, 65000.00);

-- Dumping structure for table pawmate_db.payments
DROP TABLE IF EXISTS `payments`;
CREATE TABLE IF NOT EXISTS `payments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `bank_name` varchar(50) NOT NULL,
  `va_number` varchar(50) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_status` varchar(50) DEFAULT 'pending',
  `payment_date` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table pawmate_db.payments: ~10 rows (approximately)
INSERT INTO `payments` (`id`, `order_id`, `bank_name`, `va_number`, `amount`, `payment_status`, `payment_date`, `created_at`) VALUES
	(1, 1, 'BNI', '8800971286', 200000.00, 'pending', NULL, '2025-12-27 16:21:48'),
	(2, 2, 'BCA', '8800347704', 22000.00, 'pending', NULL, '2025-12-27 16:24:07'),
	(3, 3, 'BCA', '6792-895652', 15000.00, 'pending', NULL, '2025-12-27 17:59:46'),
	(4, 4, 'MANDIRI', '6459-115236', 120000.00, 'confirmed', NULL, '2025-12-27 18:00:30'),
	(5, 5, 'BRI', '5444-411393', 25000.00, 'pending', NULL, '2025-12-28 03:34:12'),
	(6, 6, 'BCA', '6014-475334', 50000.00, 'pending', NULL, '2025-12-28 03:40:39'),
	(7, 7, 'BNI', '8712-157818', 35000.00, 'cancelled', NULL, '2025-12-28 05:57:57'),
	(8, 8, 'BCA', '7887-769185', 12000.00, 'confirmed', NULL, '2025-12-28 06:18:12'),
	(9, 9, 'BNI', '3769-610215', 65000.00, 'confirmed', NULL, '2025-12-28 07:07:26'),
	(10, 10, 'BCA', '3679-497246', 15000.00, 'cancelled', NULL, '2025-12-28 07:25:12'),
	(11, 11, 'BCA', '5709-781121', 35000.00, 'pending', NULL, '2025-12-28 07:25:36'),
	(12, 12, 'BCA', '9959-940843', 12000.00, 'cancelled', NULL, '2025-12-28 07:37:42'),
	(13, 13, 'BCA', '9683-685310', 65000.00, 'confirmed', NULL, '2025-12-29 14:21:28');

-- Dumping structure for table pawmate_db.products
DROP TABLE IF EXISTS `products`;
CREATE TABLE IF NOT EXISTS `products` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL,
  `stock` int NOT NULL DEFAULT '0',
  `category` varchar(100) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table pawmate_db.products: ~8 rows (approximately)
INSERT INTO `products` (`id`, `name`, `description`, `price`, `stock`, `category`, `image_url`, `created_at`) VALUES
	(1, 'Vitamin Kucing Sehat', 'Multivitamin lengkap untuk menjaga daya tahan tubuh dan nafsu makan anabul.', 25000.00, 50, 'Obat', 'assets/images/vitamins.jpeg', '2025-12-27 12:47:05'),
	(2, 'Whiskas Tuna 1kg', 'Makanan kucing kering rasa Tuna yang lezat dan bergizi tinggi.', 65000.00, 28, 'Makanan', 'assets/images/whiskas.jpeg', '2025-12-27 12:47:05'),
	(3, 'Royal Canin Adult', 'Makanan premium khusus kucing dewasa untuk kesehatan bulu dan pencernaan.', 150000.00, 20, 'Makanan', 'assets/images/royal_canin.jpeg', '2025-12-27 12:47:05'),
	(4, 'Shampo Anti Kutu', 'Shampo wangi diformulasikan khusus untuk membasmi kutu dan jamur.', 35000.00, 39, 'Perawatan', 'assets/images/shampoo.jpeg', '2025-12-27 12:47:05'),
	(5, 'Kalung Lonceng', 'Kalung kain lembut dengan lonceng nyaring, tersedia berbagai warna.', 15000.00, 50, 'Aksesoris', 'assets/images/kalung_lonceng.jpeg', '2025-12-27 12:47:05'),
	(6, 'Kandang Rio Medium', 'Kandang besi lipat ukuran medium, kuat dan cocok untuk travel.', 120000.00, 15, 'Aksesoris', 'assets/images/kandang_rio.jpeg', '2025-12-27 12:47:05'),
	(7, 'Mainan Tikus', 'Mainan bentuk tikus yang bisa bunyi cit-cit saat ditekan.', 10000.00, 60, 'Mainan', 'assets/images/mainan_tikus.jpeg', '2025-12-27 12:47:05'),
	(8, 'Bola Karet Gigit', 'Bola karet, aman untuk digigit anjing atau kucing.', 12000.00, 50, 'Mainan', 'assets/images/bola_karet.jpeg', '2025-12-27 12:47:05');

-- Dumping structure for table pawmate_db.users
DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('client','admin') DEFAULT 'client',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table pawmate_db.users: ~2 rows (approximately)
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `created_at`) VALUES
	(1, 'Rizky Aqil Hibatullah', 'aqil@gmail.com', '456', 'admin', '2025-12-27 11:01:01'),
	(2, 'Auril Putri Amanda', 'auril@gmail.com', '123', 'client', '2025-12-27 11:59:09');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
