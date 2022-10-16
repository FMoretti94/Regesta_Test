SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- --------------------------------------------------------
-- Database: regesta_test
-- --------------------------------------------------------

CREATE DATABASE IF NOT EXISTS `regestatest` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `regestatest`;

-- --------------------------------------------------------
-- Users
-- --------------------------------------------------------

GRANT USAGE ON *.* TO `test`@`localhost` IDENTIFIED BY PASSWORD '*D7E9291226A60CD096B30DC16140E2E480BB7C4A';
GRANT ALL PRIVILEGES ON `regestatest`.* TO `test`@`localhost` WITH GRANT OPTION;

-- --------------------------------------------------------
-- Procedures
-- --------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE `GetBestSupplier` (IN `itemID` INT, IN `quantity` INT, IN `orderdate` DATE)

BLOCK1: BEGIN

	DECLARE eoc1, eoc2 BOOLEAN DEFAULT FALSE;
	DECLARE suppIdRec, shipDaysRec INT;
	DECLARE suppBusinessName VARCHAR(50);
	DECLARE priceRec FLOAT;
	
	DECLARE discType VARCHAR(10);
	DECLARE discValue, discThreshold INT;
	DECLARE dateStart, dateEnd DATE;
	
	DECLARE tempTotal FLOAT;
	DECLARE TotDiscount INT;
	
	DECLARE shipDays INT;
	
	-- Get suppliers with item in stock (and quantity >= ordered quantity)
	DECLARE cSupplier CURSOR FOR
	SELECT suppliers.ID,
		suppliers.BUSINESS_NAME,
		suppliers.SHIP_DAYS,
		stock.PRICE
	FROM stock
	JOIN item
	ON stock.ITEM_ID = item.ID
	JOIN suppliers
	ON stock.SUPP_ID = suppliers.ID
	WHERE stock.ITEM_ID = itemID
	AND stock.QUANTITY >= quantity	
	ORDER BY suppliers.ID,
		item.BRAND,
		item.MODEL;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET eoc1 = TRUE;
	
	DROP TEMPORARY TABLE IF EXISTS purchase_order;
	CREATE TEMPORARY TABLE purchase_order (SUPP_ID INT, BUSINESS_NAME VARCHAR(50), SHIP_DAYS INT, ITEM_ID INT, QUANTITY INT, DISCOUNT_PCT INT, INITIAL_PRICE FLOAT(10,2), FINAL_PRICE FLOAT(10,2));
	
	OPEN cSupplier;
		getSupp: LOOP
			FETCH cSupplier INTO suppIdRec, suppBusinessName, shipDaysRec, priceRec;
			
			IF eoc1 THEN
				LEAVE getSupp;
			END IF;
			
			SET tempTotal = quantity * priceRec;
			SET shipDays = shipDaysRec;
			
			SET TotDiscount := 0;
			SET eoc2 = FALSE;
			
			BLOCK2: BEGIN
			
				-- Get discounts available for supplier
				DECLARE cDiscount CURSOR FOR
				SELECT discount.TYPE,
					discount.VALUE,
					discount.THRESHOLD,
					discount.DATE_START,
					discount.DATE_END
				FROM discount
				WHERE SUPP_ID = suppIdRec;
				
				DECLARE CONTINUE HANDLER FOR NOT FOUND SET eoc2 = TRUE;
				
				OPEN cDiscount;
				
					getDiscount: LOOP
						FETCH cDiscount Into discType, discValue, discThreshold, dateStart, dateEnd;
						IF eoc2 THEN
							LEAVE getDiscount;
						END IF;
						
						-- Discount on total value (check if order value is >= than threshold)
						IF (discType = 'ORD_VAL') THEN
							IF tempTotal >= discThreshold THEN
								SET TotDiscount = TotDiscount + discValue;
							END IF;
						-- Discount on quantity (check if item quantity is >= than threshold)
						ELSEIF (discType = 'QUANTITY') THEN
							IF quantity >= discThreshold THEN
								SET TotDiscount = TotDiscount + discValue;
							END IF;
						-- Discount on order date (check if order date is between start and end date)
						ELSEIF (discType = 'DATE') THEN
							IF orderdate BETWEEN dateStart AND dateEnd THEN
								SET TotDiscount = TotDiscount + discValue;
							END IF;
						END IF;	
						
					END LOOP getDiscount;			
				CLOSE cDiscount;
				
				SET tempTotal = tempTotal - (TotDiscount * tempTotal / 100);
						
				INSERT INTO purchase_order (SUPP_ID, BUSINESS_NAME, SHIP_DAYS, ITEM_ID, QUANTITY, DISCOUNT_PCT, INITIAL_PRICE, FINAL_PRICE)
				VALUES (suppIdRec, suppBusinessName, shipDaysRec, itemID, quantity, TotDiscount, (quantity * priceRec), tempTotal);
				
			END BLOCK2;		
		END LOOP getSupp;
	CLOSE cSupplier;

	SELECT BUSINESS_NAME,
		INITIAL_PRICE,
		DISCOUNT_PCT,
		FINAL_PRICE,
		SHIP_DAYS
	FROM purchase_order
	ORDER BY FINAL_PRICE,
		SHIP_DAYS;
	
	DROP TEMPORARY TABLE purchase_order;
	
END BLOCK1$$

DELIMITER ;


-- --------------------------------------------------------
-- Tables
-- --------------------------------------------------------

-- Discount table
CREATE TABLE `discount` (
  `SUPP_ID` int(11) NOT NULL,
  `TYPE` set('ORD_VAL','QUANTITY','DATE') NOT NULL,
  `VALUE` int(11) NOT NULL,
  `THRESHOLD` int(11) DEFAULT NULL,
  `DATE_START` date DEFAULT NULL,
  `DATE_END` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `discount` (`SUPP_ID`, `TYPE`, `VALUE`, `THRESHOLD`, `DATE_START`, `DATE_END`) VALUES
(1, 'ORD_VAL', 5, 1000, NULL, NULL),
(3, 'ORD_VAL', 3, 800, NULL, NULL),
(2, 'QUANTITY', 3, 5, NULL, NULL),
(2, 'QUANTITY', 4, 10, NULL, NULL),
(3, 'QUANTITY', 5, 8, NULL, NULL),
(1, 'DATE', 4, NULL, '2022-10-01', '2022-10-31'),
(2, 'DATE', 3, NULL, '2022-10-01', '2022-10-31'),
(1, 'ORD_VAL', 3, 1500, NULL, NULL);


-- Item table
CREATE TABLE `item` (
  `ID` int(11) NOT NULL,
  `BRAND` varchar(30) NOT NULL,
  `MODEL` varchar(30) NOT NULL,
  `SPECS` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `item` (`ID`, `BRAND`, `MODEL`, `SPECS`) VALUES
(1, 'Samsung', 'SAM_MON_21', 'Monitor Samsung 21\"'),
(2, 'Samsung', 'SAM_MON_24', 'Monitor Samsung 24\"'),
(3, 'Samsung', 'SAM_MON_27', 'Monitor Samsung 27\"');

-- Stock table
CREATE TABLE `stock` (
  `SUPP_ID` int(11) NOT NULL,
  `ITEM_ID` int(11) NOT NULL,
  `QUANTITY` int(11) NOT NULL,
  `PRICE` float(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `stock` (`SUPP_ID`, `ITEM_ID`, `QUANTITY`, `PRICE`) VALUES
(1, 1, 6, 120.00),
(1, 2, 15, 150.00),
(2, 1, 10, 125.00),
(2, 3, 12, 185.00),
(3, 1, 7, 117.00),
(3, 2, 8, 145.00),
(3, 3, 5, 173.00);

-- Suppliers table
CREATE TABLE `suppliers` (
  `ID` int(11) NOT NULL,
  `BUSINESS_NAME` varchar(50) NOT NULL,
  `SHIP_DAYS` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `suppliers` (`ID`, `BUSINESS_NAME`, `SHIP_DAYS`) VALUES
(1, 'Monitor Store', 5),
(2, 'Tech Store', 4),
(3, 'Super Store', 3);


-- --------------------------------------------------------
-- Indexes
-- --------------------------------------------------------

ALTER TABLE `discount`
  ADD KEY `SUPP_ID` (`SUPP_ID`);

ALTER TABLE `item`
  ADD PRIMARY KEY (`ID`);

ALTER TABLE `stock`
  ADD PRIMARY KEY (`SUPP_ID`,`ITEM_ID`),
  ADD KEY `ITEM_ID` (`ITEM_ID`);

ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `BUSINESS_NAME` (`BUSINESS_NAME`);


-- --------------------------------------------------------
-- Foreign Keys
-- --------------------------------------------------------

ALTER TABLE `discount`
  ADD CONSTRAINT `discount_ibfk_1` FOREIGN KEY (`SUPP_ID`) REFERENCES `suppliers` (`ID`);

ALTER TABLE `stock`
  ADD CONSTRAINT `stock_ibfk_1` FOREIGN KEY (`SUPP_ID`) REFERENCES `suppliers` (`ID`),
  ADD CONSTRAINT `stock_ibfk_2` FOREIGN KEY (`ITEM_ID`) REFERENCES `item` (`ID`);
COMMIT;


/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;