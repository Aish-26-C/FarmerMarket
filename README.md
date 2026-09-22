# 🌱 Farmer Market

A full-stack digital marketplace that directly connects **farmers and buyers**, allowing farmers to list their agricultural products and buyers to browse, purchase, and track their orders.

The application is designed to simplify agricultural product selling while providing a transparent and convenient buying experience.

---

## 📌 Project Overview

Farmer Market is a mobile-based agricultural marketplace developed using **Flutter** for the frontend, **Node.js + Express.js** for the backend, and **MongoDB** for data storage.

The platform provides separate experiences for:

- 👨‍🌾 Farmers
- 🛒 Buyers

Farmers can add and manage crops, while buyers can browse available crops, add products to a cart, place orders, and track delivery status.

The system also provides an order management workflow where farmers can update the status of buyer orders.

---

## ✨ Features

### 👨‍🌾 Farmer Features

- Farmer registration and login
- Farmer dashboard
- Add new crops
- Upload crop images
- Specify crop price
- Specify available quantity
- Specify measurement unit
- View personal crop listings
- Edit/manage crop information
- View buyer orders
- View order details
- Update order status
- Track order progress
- View order analytics

### 🛒 Buyer Features

- Buyer registration and login
- Buyer dashboard
- Browse available crops
- Search crops
- View farmer information
- View crop price
- View available quantity
- Add products to cart
- Increase/decrease cart quantity
- Remove products from cart
- View cart total
- Checkout
- Place orders
- Cash on Delivery support
- View previous orders
- View order details
- View delivery address
- Track order status
- Cancel eligible orders

---

## 📦 Order Management

The application supports a complete order lifecycle.

```text
Placed
   ↓
Confirmed
   ↓
Processing
   ↓
Shipped
   ↓
Out for Delivery
   ↓
Delivered
